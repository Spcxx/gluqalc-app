import 'package:dio/dio.dart';
import 'package:gluqalc_app/core/networking/dio_provider.dart';
import 'package:gluqalc_app/features/profile/data/models/profile_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_remote_api.g.dart';

@Riverpod(keepAlive: true)
ProfileRemoteApi profileRemoteApi(Ref ref) {
  return ProfileRemoteApi(ref.watch(dioProvider));
}

class ProfileRemoteApi {
  ProfileRemoteApi(this._dio);
  final Dio _dio;

  Future<ProfileResponse> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/profile');

    if (response.data == null) {
      throw Exception('Server returned an empty response');
    }

    return ProfileResponse.fromJson(response.data!);
  }

  Future<ProfileResponse> updateProfile(ProfileRequest request) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/profile',
      data: request.toJson(),
    );

    if (response.data == null) {
      throw Exception('Server returned an empty response upon update');
    }

    return ProfileResponse.fromJson(response.data!);
  }

  Future<List<BiometricsHistoryResponse>> getProfileHistory() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/profile/history');

    if (response.data == null) return [];

    return response.data!
        .whereType<Map<String, dynamic>>()
        .map(BiometricsHistoryResponse.fromJson)
        .toList();
  }

  Future<ProfileResponse> updateBiometrics(UpdateBiometricsRequest req) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/v1/profile/biometrics',
      data: req.toJson(),
    );

    if (response.data == null) {
      throw Exception('Server returned empty response on biometrics update');
    }

    return ProfileResponse.fromJson(response.data!);
  }

  Future<ProfileTargets> calculateTargets(ProfileRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/profile/calculate',
      data: request.toJson(),
    );
    return ProfileTargets.fromJson(response.data!);
  }
}
