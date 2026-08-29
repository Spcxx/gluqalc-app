import 'package:dio/dio.dart';
import 'package:gluqalc_app/features/auth/data/repositories/auth_repository.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verify_controller.g.dart';

@riverpod
class VerifyController extends _$VerifyController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> verifyCode({
    required String code,
    required AppLocalizations l10n,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      try {
        await repository.verify(code: code);
      } on DioException catch (e) {
        throw _mapDioError(e, l10n);
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

      if (msg.contains('user not found')) {
        return l10n.errorUserNotFound;
      }
    }

    switch (statusCode) {
      case 400:
        return l10n.errorValidationError;
      case 401:
        return l10n.errorInvalidVerificationCode;
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
