import 'package:dio/dio.dart';
import 'package:gluqalc_app/core/networking/dio_provider.dart';
import 'package:gluqalc_app/features/auth/data/models/consent_response.dart';
import 'package:gluqalc_app/features/auth/data/models/token_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'consent_remote_api.g.dart';

@Riverpod(keepAlive: true)
ConsentRemoteApi consentRemoteApi(Ref ref) {
  return ConsentRemoteApi(ref.watch(dioProvider));
}

class ConsentRemoteApi {
  ConsentRemoteApi(this._dio);
  final Dio _dio;

  Future<List<ConsentResponse>> getConsents() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/consents');
    final data = response.data;
    if (data == null) return [];

    return data
        .map((e) => ConsentResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ConsentResponse>> getPendingConsents() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/consents/pending');
    final data = response.data;
    if (data == null) return [];

    return data
        .map((e) => ConsentResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TokenResponse> acceptConsents({
    required List<String> consentDefinitionIds,
    required String refreshToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/consents/accept',
      data: {
        'consentDefinitionIds': consentDefinitionIds,
        'refreshToken': refreshToken,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception(
        'Server returned an empty response during consent acceptance',
      );
    }
    return TokenResponse.fromJson(data);
  }
}
