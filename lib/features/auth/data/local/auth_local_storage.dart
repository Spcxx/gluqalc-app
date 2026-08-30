import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
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
  static const _keyEmail = 'user_email';

  Future<void> saveTokens({
    required String jwt,
    required String refresh,
  }) async {
    try {
      await _storage.write(key: _keyJwt, value: jwt);
      await _storage.write(key: _keyRefresh, value: refresh);
    } on Object catch (_) {}
  }

  Future<void> saveEmail(String email) async {
    try {
      await _storage.write(key: _keyEmail, value: email);
    } on Object catch (_) {}
  }

  Future<String?> getEmail() async {
    try {
      return await _storage.read(key: _keyEmail);
    } on Object catch (_) {
      return null;
    }
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
      await _storage.delete(
        key: _keyEmail,
      );
    } on Object catch (_) {}
  }

  Future<String> getDeviceId() async {
    try {
      var deviceId = await _storage.read(key: _keyDeviceId);
      if (deviceId != null) return deviceId;

      final deviceInfoPlugin = DeviceInfoPlugin();
      String rawIdentifier;

      if (kIsWeb) {
        final web = await deviceInfoPlugin.webBrowserInfo;
        rawIdentifier = 'web-${web.browserName.name}-${const Uuid().v4()}';
      } else if (Platform.isAndroid) {
        final android = await deviceInfoPlugin.androidInfo;
        rawIdentifier = 'android-${android.model}-${android.id}';
      } else if (Platform.isIOS) {
        final ios = await deviceInfoPlugin.iosInfo;
        rawIdentifier =
            'ios-${ios.utsname.machine}-${ios.identifierForVendor ?? const Uuid().v4()}';
      } else if (Platform.isWindows) {
        final windows = await deviceInfoPlugin.windowsInfo;
        rawIdentifier = 'windows-${windows.computerName}-${windows.deviceId}';
      } else if (Platform.isLinux) {
        final linux = await deviceInfoPlugin.linuxInfo;
        rawIdentifier =
            'linux-${linux.name}-${linux.machineId ?? const Uuid().v4()}';
      } else if (Platform.isMacOS) {
        final mac = await deviceInfoPlugin.macOsInfo;
        rawIdentifier =
            'macos-${mac.computerName}-${mac.systemGUID ?? const Uuid().v4()}';
      } else {
        rawIdentifier = 'unknown-${const Uuid().v4()}';
      }

      final bytes = utf8.encode(rawIdentifier);
      final digest = sha256.convert(bytes);

      final prefix = rawIdentifier.split('-').first;
      deviceId = '$prefix-$digest';

      await _storage.write(key: _keyDeviceId, value: deviceId);
      return deviceId;
    } on Object catch (_) {
      try {
        var fallbackId = await _storage.read(key: _keyDeviceId);
        if (fallbackId != null) return fallbackId;

        fallbackId = 'fallback-${const Uuid().v4()}';
        await _storage.write(key: _keyDeviceId, value: fallbackId);
        return fallbackId;
      } on Object catch (_) {
        return 'critical-fallback-${const Uuid().v4()}';
      }
    }
  }
}
