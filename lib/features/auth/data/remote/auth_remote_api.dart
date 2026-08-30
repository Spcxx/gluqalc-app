import 'package:dio/dio.dart';
import 'package:gluqalc_app/core/networking/dio_provider.dart';
import 'package:gluqalc_app/features/auth/data/models/auth_user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_remote_api.g.dart';

@Riverpod(keepAlive: true)
AuthRemoteApi authRemoteApi(Ref ref) {
  return AuthRemoteApi(ref.watch(dioProvider));
}

class AuthRemoteApi {
  AuthRemoteApi(this._dio);
  final Dio _dio;

  Future<AuthUserModel> register({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/register',
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthUserModel.fromJson(response.data!);
  }

  Future<void> verify({required String code}) async {
    await _dio.post<dynamic>(
      '/api/v1/auth/verify',
      data: {
        'code': code,
      },
      options: Options(extra: {'ignore401': true}),
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: {
        'email': email,
        'password': password,
        'deviceId': deviceId,
      },
      options: Options(extra: {'ignore401': true}),
    );
    return response.data!;
  }

  Future<void> logout({required String refreshToken}) async {
    await _dio.post<dynamic>(
      '/api/v1/auth/logout',
      data: {
        'refreshToken': refreshToken,
      },
    );
  }

  Future<void> changeUnverifiedEmail({
    required String oldEmail,
    required String password,
    required String newEmail,
  }) async {
    await _dio.post<dynamic>(
      '/api/v1/auth/change-email',
      data: {
        'oldEmail': oldEmail,
        'password': password,
        'newEmail': newEmail,
      },
      options: Options(extra: {'ignore401': true}),
    );
  }

  Future<void> requestVerifiedEmailChange({
    required String newEmail,
    required String password,
  }) async {
    await _dio.post<dynamic>(
      '/api/v1/change-email/request',
      data: {
        'newEmail': newEmail,
        'password': password,
      },
      options: Options(extra: {'ignore401': true}),
    );
  }

  Future<void> confirmVerifiedEmailChange({
    required String newEmail,
    required String code,
  }) async {
    await _dio.post<dynamic>(
      '/api/v1/change-email/confirm',
      data: {
        'newEmail': newEmail,
        'code': code,
      },
      options: Options(extra: {'ignore401': true}),
    );
  }

  Future<void> requestPasswordReset({
    required String email,
  }) async {
    await _dio.post<dynamic>(
      '/api/v1/reset-password/request',
      data: {'email': email},
    );
  }

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _dio.post<dynamic>(
      '/api/v1/reset-password/confirm',
      data: {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      },
      options: Options(extra: {'ignore401': true}),
    );
  }

  Future<void> requestAccountDeletion() async {
    await _dio.post<dynamic>('/api/v1/users/me/delete/request');
  }

  Future<void> confirmAccountDeletion({required String code}) async {
    await _dio.post<dynamic>(
      '/api/v1/users/me/delete/confirm',
      data: {'code': code},
      options: Options(extra: {'ignore401': true}),
    );
  }
}
