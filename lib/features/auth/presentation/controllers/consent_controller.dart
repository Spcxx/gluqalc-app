import 'package:gluqalc_app/features/auth/data/models/consent_response.dart';
import 'package:gluqalc_app/features/auth/data/repositories/consent_repository.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'consent_controller.g.dart';

@riverpod
class ConsentController extends _$ConsentController {
  @override
  FutureOr<List<ConsentResponse>> build() async {
    final isAuthFuture = await ref.watch(authStateControllerProvider.future);
    if (!isAuthFuture) {
      return [];
    }
    return _fetchPendingConsents();
  }

  Future<List<ConsentResponse>> _fetchPendingConsents() async {
    return ref.read(consentRepositoryProvider).getPendingConsents();
  }

  Future<List<ConsentResponse>> getAllConsents() async {
    return ref.read(consentRepositoryProvider).getConsents();
  }

  Future<void> acceptConsents(List<String> consentIds) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(consentRepositoryProvider).acceptConsents(consentIds);
      return _fetchPendingConsents();
    });
  }
}
