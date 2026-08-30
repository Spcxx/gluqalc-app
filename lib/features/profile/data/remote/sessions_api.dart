import 'package:dio/dio.dart';
import 'package:gluqalc_app/core/networking/dio_provider.dart';
import 'package:gluqalc_app/features/profile/data/models/device_session_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sessions_api.g.dart';

@Riverpod(keepAlive: true)
SessionsApi sessionsApi(Ref ref) {
  return SessionsApi(ref.watch(dioProvider));
}

class SessionsApi {
  SessionsApi(this._dio);
  final Dio _dio;

  Future<List<DeviceSessionModel>> getMySessions() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/users/me/sessions');
    final data = response.data;
    if (data == null) return [];

    return data
        .map(
          (dynamic e) => DeviceSessionModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> revokeSession(String deviceId) async {
    await _dio.delete<dynamic>('/api/v1/users/me/sessions/$deviceId');
  }
}
