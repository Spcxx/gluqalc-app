import 'package:dio/dio.dart';
import 'package:gluqalc_app/features/auth/data/repositories/auth_repository.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> submitForm({
    required String email,
    required String password,
    required bool isLogin,
    required AppLocalizations l10n,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);

      if (isLogin) {
        try {
          final deviceId = await repository.getDeviceId();
          await repository.login(
            email: email,
            password: password,
            deviceId: deviceId,
          );
          await ref.read(authStateControllerProvider.notifier).checkAuth();
        } on DioException catch (e) {
          throw _mapDioError(e, l10n);
        }
      } else {
        try {
          await repository.register(email: email, password: password);
        } on DioException catch (e) {
          throw _mapDioError(e, l10n);
        }
      }
    });
  }

  Exception _mapDioError(DioException e, AppLocalizations l10n) {
    final data = e.response?.data;
    final statusCode = e.response?.statusCode;
    String? rawServerMessage;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];

      if (message is String) {
        rawServerMessage = message;
      } else if (message is Map) {
        rawServerMessage = message.values.join(' ');
      } else if (data.containsKey('errors')) {
        rawServerMessage = data['errors'].toString();
      }
    }

    final localizedMessage = _getLocalizedMessage(
      rawServerMessage,
      statusCode,
      l10n,
    );
    return Exception(localizedMessage);
  }

  String _getLocalizedMessage(
    String? serverMsg,
    int? statusCode,
    AppLocalizations l10n,
  ) {
    if (serverMsg != null) {
      final msg = serverMsg.toLowerCase();

      if (msg.contains('invalid email or password')) {
        return l10n.errorInvalidCredentials;
      }
      if (msg.contains('registered via external provider') ||
          msg.contains('registered via different provider')) {
        return l10n.errorExternalProvider;
      }
      if (msg.contains('account is not verified')) {
        return l10n.errorAccountNotVerified;
      }
      if (msg.contains('account is locked')) return l10n.errorAccountLocked;
      if (msg.contains('user not found')) return l10n.errorUserNotFound;

      if (msg.contains('password is too common')) {
        return l10n.errorPasswordTooCommon;
      }
      if (msg.contains('too many repeating characters')) {
        return l10n.errorPasswordRepeatingChars;
      }
      if (msg.contains('appeared in a data breach')) {
        return l10n.errorPasswordPwned;
      }
      if (msg.contains('password is already set')) {
        return l10n.errorPasswordAlreadySet;
      }

      if (msg.contains('invalid google id token') ||
          msg.contains('google authentication failed')) {
        return l10n.errorGoogleAuthFailed;
      }
      if (msg.contains('google email does not match profile email')) {
        return l10n.errorGoogleEmailMismatch;
      }
      if (msg.contains('google account is already linked')) {
        return l10n.errorGoogleAlreadyLinked;
      }
    }

    switch (statusCode) {
      case 400:
        return l10n.errorValidationError;
      case 401:
        return l10n.errorUnauthorized;
      case 403:
        return l10n.errorForbidden;
      case 404:
        return l10n.errorNotFound;
      case 409:
        return l10n.errorConflict;
      case 429:
        return l10n.errorTooManyRequests;
      case 500:
      case 502:
      case 503:
        return l10n.errorServerError;
      default:
        if (serverMsg != null && serverMsg.isNotEmpty) {
          return serverMsg;
        }
        return l10n.errorUnknown(statusCode?.toString() ?? 'no connection');
    }
  }
}
