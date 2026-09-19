import 'package:gluqalc_app/features/profile/data/models/profile_models.dart';
import 'package:gluqalc_app/features/profile/data/repositories/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'biometrics_history_controller.g.dart';

@riverpod
class BiometricsHistoryController extends _$BiometricsHistoryController {
  @override
  FutureOr<List<BiometricsHistoryResponse>> build() async {
    return ref.read(profileRepositoryProvider).getProfileHistory();
  }

  Future<void> refreshHistory() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(profileRepositoryProvider).getProfileHistory(),
    );
  }
}
