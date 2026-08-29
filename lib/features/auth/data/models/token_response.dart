import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_response.freezed.dart';
part 'token_response.g.dart';

@freezed
abstract class TokenResponse with _$TokenResponse {
  const factory TokenResponse({
    required String jwtToken,
    required String refreshToken,
    required int expiresIn,
    required String deviceId,
  }) = _TokenResponse;

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);
}
