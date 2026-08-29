import 'package:gluqalc_app/features/auth/data/models/consent_response.dart';
import 'package:gluqalc_app/features/auth/data/repositories/consent_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'consent_controller.g.dart';

@riverpod
class ConsentController extends _$ConsentController {
  @override
  FutureOr<List<ConsentResponse>> build() async {
    return _fetchPendingConsents();
  }

  Future<List<ConsentResponse>> _fetchPendingConsents() async {
    return ref.read(consentRepositoryProvider).getPendingConsents();
  }

  Future<void> acceptConsents(List<String> consentIds) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(consentRepositoryProvider).acceptConsents(consentIds);
      return ref.read(consentRepositoryProvider).getPendingConsents();
    });
  }
}
