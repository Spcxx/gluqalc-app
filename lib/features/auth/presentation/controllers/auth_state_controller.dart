import 'package:gluqalc_app/features/auth/data/local/auth_local_storage.dart';
import 'package:gluqalc_app/features/auth/data/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthStateController extends _$AuthStateController {
  @override
  Future<bool> build() async {
    try {
      final storage = ref.watch(authLocalStorageProvider);
      final jwt = await storage.getJwt();
      return jwt != null;
    } on Object catch (_) {
      return false;
    }
  }

  Future<void> checkAuth() async {
    try {
      final storage = ref.read(authLocalStorageProvider);
      final jwt = await storage.getJwt();
      state = AsyncData(jwt != null);
    } on Object catch (_) {
      state = const AsyncData(false);
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading<bool>();

    final repository = ref.read(authRepositoryProvider);
    await repository.logout();

    await ref.read(authLocalStorageProvider).clearTokens();

    ref.invalidate(currentUserEmailProvider);

    state = const AsyncData(false);
  }
}

@Riverpod(keepAlive: true)
Future<String?> currentUserEmail(Ref ref) async {
  final storage = ref.watch(authLocalStorageProvider);
  return storage.getEmail();
}
