import 'package:gluqalc_app/features/auth/data/local/auth_local_storage.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:gluqalc_app/features/profile/data/models/device_session_model.dart';
import 'package:gluqalc_app/features/profile/data/remote/sessions_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sessions_controller.g.dart';

@riverpod
class SessionsController extends _$SessionsController {
  @override
  Future<List<DeviceSessionModel>> build() async {
    final api = ref.watch(sessionsApiProvider);
    return api.getMySessions();
  }

  Future<void> revokeSession(String deviceId) async {
    final api = ref.read(sessionsApiProvider);
    final storage = ref.read(authLocalStorageProvider);

    final currentDeviceId = await storage.getDeviceId();

    await api.revokeSession(deviceId);

    if (deviceId == currentDeviceId) {
      await ref.read(authStateControllerProvider.notifier).logout();
    } else {
      ref.invalidateSelf();
    }
  }

  Future<String> getCurrentDeviceId() async {
    return ref.read(authLocalStorageProvider).getDeviceId();
  }
}
