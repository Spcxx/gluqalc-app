import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:gluqalc_app/core/networking/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_health_service.g.dart';

enum ServerHealthState { loading, online, warning, offline }

@Riverpod(keepAlive: true)
class ServerHealthService extends _$ServerHealthService
    with WidgetsBindingObserver {
  Timer? _timer;
  int _failCount = 0;

  @override
  ServerHealthState build() {
    WidgetsBinding.instance.addObserver(this);

    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _timer?.cancel();
    });

    _startPingTimer();
    return ServerHealthState.loading;
  }

  void _startPingTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _pingServer());
    unawaited(_pingServer());
  }

  void _stopPingTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _pingServer() async {
    try {
      final dio = ref.read(dioProvider);

      final response = await dio.get<void>(
        '/api/v1/system/ping',
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );

      if (response.statusCode == 200) {
        _failCount = 0;
        if (state != ServerHealthState.online) {
          state = ServerHealthState.online;
        }
      } else {
        _handleFailure();
      }
    } on Object catch (_) {
      _handleFailure();
    }
  }

  void _handleFailure() {
    _failCount++;
    if (_failCount == 1) {
      state = ServerHealthState.warning;
    } else if (_failCount > 1) {
      state = ServerHealthState.offline;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_pingServer());
      _startPingTimer();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopPingTimer();
    }
  }
}
