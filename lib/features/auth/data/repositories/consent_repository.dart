import 'package:gluqalc_app/features/auth/data/local/auth_local_storage.dart';
import 'package:gluqalc_app/features/auth/data/models/consent_response.dart';
import 'package:gluqalc_app/features/auth/data/remote/consent_remote_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'consent_repository.g.dart';

@Riverpod(keepAlive: true)
ConsentRepository consentRepository(Ref ref) {
  return ConsentRepository(
    ref.watch(consentRemoteApiProvider),
    ref.watch(authLocalStorageProvider),
  );
}

class ConsentRepository {
  ConsentRepository(this._remoteApi, this._localStorage);

  final ConsentRemoteApi _remoteApi;
  final AuthLocalStorage _localStorage;

  Future<List<ConsentResponse>> getPendingConsents() {
    return _remoteApi.getPendingConsents();
  }

  Future<void> acceptConsents(List<String> consentIds) async {
    final refreshToken = await _localStorage.getRefresh();
    if (refreshToken == null) {
      throw Exception('Refresh token not found.');
    }

    final tokenResponse = await _remoteApi.acceptConsents(
      consentDefinitionIds: consentIds,
      refreshToken: refreshToken,
    );

    await _localStorage.saveTokens(
      jwt: tokenResponse.jwtToken,
      refresh: tokenResponse.refreshToken,
    );
  }
}
