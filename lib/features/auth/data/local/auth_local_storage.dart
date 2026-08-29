import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'auth_local_storage.g.dart';

@Riverpod(keepAlive: true)
AuthLocalStorage authLocalStorage(Ref ref) {
  const storage = FlutterSecureStorage();
  return AuthLocalStorage(storage);
}

class AuthLocalStorage {
  AuthLocalStorage(this._storage);
  final FlutterSecureStorage _storage;

  static const _keyJwt = 'jwt_token';
  static const _keyRefresh = 'refresh_token';
  static const _keyDeviceId = 'device_id';

  Future<void> saveTokens({
    required String jwt,
    required String refresh,
  }) async {
    try {
      await _storage.write(key: _keyJwt, value: jwt);
      await _storage.write(key: _keyRefresh, value: refresh);
    } on Object catch (_) {}
  }

  Future<String?> getJwt() async {
    try {
      return await _storage.read(key: _keyJwt);
    } on Object catch (_) {
      return null;
    }
  }

  Future<String?> getRefresh() async {
    try {
      return await _storage.read(key: _keyRefresh);
    } on Object catch (_) {
      return null;
    }
  }

  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _keyJwt);
      await _storage.delete(key: _keyRefresh);
    } on Object catch (_) {}
  }

  Future<String> getDeviceId() async {
    try {
      var deviceId = await _storage.read(key: _keyDeviceId);
      if (deviceId != null) return deviceId;

      final deviceInfo = DeviceInfoPlugin();

      if (kIsWeb) {
        deviceId = 'web-${const Uuid().v4()}';
      } else if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceId = 'android-${android.model}-${android.id}';
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        deviceId =
            'ios-${ios.utsname.machine}-${ios.identifierForVendor ?? const Uuid().v4()}';
      } else {
        deviceId = 'desktop-${const Uuid().v4()}';
      }

      await _storage.write(key: _keyDeviceId, value: deviceId);
      return deviceId;
    } on Object catch (_) {
      return 'fallback-device-id-${const Uuid().v4()}';
    }
  }
}
