import 'package:gluqalc_app/features/auth/data/local/auth_local_storage.dart';
import 'package:gluqalc_app/features/auth/data/models/auth_user_model.dart';
import 'package:gluqalc_app/features/auth/data/remote/auth_remote_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(authRemoteApiProvider),
    ref.watch(authLocalStorageProvider),
  );
}

class AuthRepository {
  AuthRepository(this._remoteApi, this._localStorage);

  final AuthRemoteApi _remoteApi;
  final AuthLocalStorage _localStorage;

  Future<AuthUserModel> register({
    required String email,
    required String password,
  }) async {
    return _remoteApi.register(email: email, password: password);
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
    } on Object catch (_) {
    } finally {
      await _localStorage.clearTokens();
    }
  }

  Future<String> getDeviceId() async {
    return _localStorage.getDeviceId();
  }
}
