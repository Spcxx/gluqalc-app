import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_session_model.freezed.dart';
part 'device_session_model.g.dart';

@freezed
abstract class DeviceSessionModel with _$DeviceSessionModel {
  const factory DeviceSessionModel({
    required String deviceId,
    required String ipAddress,
    required String userAgent,
    required DateTime lastAccessedAt,
    required DateTime expiresAt,
  }) = _DeviceSessionModel;

  factory DeviceSessionModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceSessionModelFromJson(json);
}
