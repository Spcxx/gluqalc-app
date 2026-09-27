import 'package:gluqalc_app/features/profile/data/models/profile_models.dart';
import 'package:gluqalc_app/features/profile/data/remote/profile_remote_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(ref.watch(profileRemoteApiProvider));
}

class ProfileRepository {
  ProfileRepository(this._remoteApi);
  final ProfileRemoteApi _remoteApi;

  Future<ProfileResponse> getProfile() async {
    return _remoteApi.getProfile();
  }

  Future<ProfileResponse> updateProfile(ProfileRequest request) async {
    return _remoteApi.updateProfile(request);
  }

  Future<List<BiometricsHistoryResponse>> getProfileHistory() async {
    return _remoteApi.getProfileHistory();
  }

  Future<ProfileResponse> updateBiometrics(
    UpdateBiometricsRequest request,
  ) async {
    return _remoteApi.updateBiometrics(request);
  }

  Future<ProfileTargets> calculateTargets(ProfileRequest request) async {
    return _remoteApi.calculateTargets(request);
  }
}
