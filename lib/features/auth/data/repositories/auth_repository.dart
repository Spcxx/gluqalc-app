import 'package:gluqalc_app/core/logging/logger_provider.dart';
import 'package:gluqalc_app/features/auth/data/local/auth_local_storage.dart';
import 'package:gluqalc_app/features/auth/data/models/auth_user_model.dart';
import 'package:gluqalc_app/features/auth/data/remote/auth_remote_api.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(authRemoteApiProvider),
    ref.watch(authLocalStorageProvider),
    ref.watch(loggerProvider),
  );
}

class AuthRepository {
  AuthRepository(this._remoteApi, this._localStorage, this._logger);

  final AuthRemoteApi _remoteApi;
  final AuthLocalStorage _localStorage;
  final Logger _logger;

  Future<AuthUserModel> register({
    required String email,
    required String password,
    required List<String> acceptedConsents,
  }) async {
    return _remoteApi.register(
      email: email,
      password: password,
      acceptedConsents: acceptedConsents,
    );
  }

  Future<void> verify({required String code}) async {
    return _remoteApi.verify(code: code);
  }

  Future<void> login({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    final data = await _remoteApi.login(
      email: email,
      password: password,
      deviceId: deviceId,
    );

    final jwt = data['jwtToken'] as String?;
    final refresh = data['refreshToken'] as String?;

    if (jwt == null || refresh == null) {
      _logger.e('Login failed: Tokens are missing in response');
      throw Exception('Invalid login response: missing tokens');
    }

    await _localStorage.saveTokens(jwt: jwt, refresh: refresh);
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _localStorage.getRefresh();
      if (refreshToken != null) {
        await _remoteApi.logout(refreshToken: refreshToken);
      }
    } on Object catch (e, st) {
      _logger.w(
        'Remote logout failed, clearing local tokens anyway',
        error: e,
        stackTrace: st,
      );
    } finally {
      await _localStorage.clearTokens();
    }
  }

  Future<String> getDeviceId() async {
    return _localStorage.getDeviceId();
  }

  Future<void> changeUnverifiedEmail({
    required String oldEmail,
    required String password,
    required String newEmail,
  }) async {
    await _remoteApi.changeUnverifiedEmail(
      oldEmail: oldEmail,
      password: password,
      newEmail: newEmail,
    );
  }

  Future<void> requestVerifiedEmailChange({
    required String newEmail,
    required String password,
  }) async {
    await _remoteApi.requestVerifiedEmailChange(
      newEmail: newEmail,
      password: password,
    );
  }

  Future<void> confirmVerifiedEmailChange({
    required String newEmail,
    required String code,
  }) async {
    await _remoteApi.confirmVerifiedEmailChange(
      newEmail: newEmail,
      code: code,
    );
  }

  Future<void> requestPasswordReset({
    required String email,
  }) async {
    await _remoteApi.requestPasswordReset(email: email);
  }

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _remoteApi.confirmPasswordReset(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  Future<void> requestAccountDeletion() async {
    await _remoteApi.requestAccountDeletion();
  }

  Future<void> confirmAccountDeletion({required String code}) async {
    await _remoteApi.confirmAccountDeletion(code: code);
  }
}
