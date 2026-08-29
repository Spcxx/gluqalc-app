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
}
