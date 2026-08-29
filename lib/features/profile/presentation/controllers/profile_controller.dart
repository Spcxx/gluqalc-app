import 'package:dio/dio.dart';
import 'package:gluqalc_app/features/profile/data/models/profile_models.dart';
import 'package:gluqalc_app/features/profile/data/repositories/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<ProfileResponse?> build() async {
    try {
      return await ref.read(profileRepositoryProvider).getProfile();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> submitProfile(ProfileRequest request) async {
    state = const AsyncLoading();

    try {
      final updatedProfile = await ref
          .read(profileRepositoryProvider)
          .updateProfile(request);

      state = AsyncData(updatedProfile);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
