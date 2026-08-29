import 'package:dio/dio.dart';
import 'package:gluqalc_app/core/networking/dio_provider.dart';
import 'package:gluqalc_app/features/profile/data/models/profile_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(ref.watch(dioProvider));
}

class ProfileRepository {
  ProfileRepository(this._dio);
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
}
