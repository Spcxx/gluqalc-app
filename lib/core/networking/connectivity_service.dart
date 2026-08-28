import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

enum AppConnectionState { loading, online, offlineStartup, offlineRuntime }

@Riverpod(keepAlive: true)
class ConnectivityService extends _$ConnectivityService {
  StreamSubscription<InternetStatus>? _subscription;
  bool _isStartup = true;

  @override
  AppConnectionState build() {
    _init();
    ref.onDispose(() => _subscription?.cancel());
    return AppConnectionState.loading;
  }

  void _init() {
    unawaited(_subscription?.cancel());
    _subscription = InternetConnection().onStatusChange.listen((status) {
      final isConnected = status == InternetStatus.connected;

      if (_isStartup) {
        _isStartup = false;
        state = isConnected
            ? AppConnectionState.online
            : AppConnectionState.offlineStartup;
      } else {
        state = isConnected
            ? AppConnectionState.online
            : AppConnectionState.offlineRuntime;
      }
    });
  }

  void retry() {
    _isStartup = true;
    state = AppConnectionState.loading;
    _init();
  }
}
