import 'package:freezed_annotation/freezed_annotation.dart';

part 'consent_response.freezed.dart';
part 'consent_response.g.dart';

@freezed
abstract class ConsentResponse with _$ConsentResponse {
  const factory ConsentResponse({
    required String id,
    required String code,
    required String description,
    required String version,
    required bool required,
  }) = _ConsentResponse;

  factory ConsentResponse.fromJson(Map<String, dynamic> json) =>
      _$ConsentResponseFromJson(json);
}
