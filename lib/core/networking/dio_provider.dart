import 'package:dio/dio.dart';
import 'package:gluqalc_app/core/config/app_config.dart';
import 'package:gluqalc_app/core/logging/logger_provider.dart';
import 'package:gluqalc_app/features/auth/data/local/auth_local_storage.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dioInstance = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dioInstance.interceptors.add(
    AuthInterceptor(dioInstance, ref),
  );

  if (!AppConfig.isProd) {
    dioInstance.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
      ),
    );
  }

  return dioInstance;
}

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  Future<void>? _refreshTokenFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final storage = _ref.read(authLocalStorageProvider);
    final jwt = await storage.getJwt();

    if (jwt != null) {
      options.headers['Authorization'] = 'Bearer $jwt';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final shouldIgnore401 = err.requestOptions.extra['ignore401'] == true;

    if (err.response?.statusCode == 401 && !shouldIgnore401) {
      final storage = _ref.read(authLocalStorageProvider);

      var newRefresh = false;
      if (_refreshTokenFuture == null) {
        newRefresh = true;
        _refreshTokenFuture = _performRefresh(storage);
      }

      try {
        await _refreshTokenFuture;

        final newJwt = await storage.getJwt();
        err.requestOptions.headers['Authorization'] = 'Bearer $newJwt';
        final retryResponse = await _dio.fetch<dynamic>(err.requestOptions);

        return handler.resolve(retryResponse);
      } on Object catch (e, st) {
        _ref
            .read(loggerProvider)
            .e(
              'Token refresh loop failed, forcing logout',
              error: e,
              stackTrace: st,
            );
        if (newRefresh) {
          await _ref.read(authStateControllerProvider.notifier).logout();
        }
        return handler.next(err);
      } finally {
        if (newRefresh) {
          _refreshTokenFuture = null;
        }
      }
    }

    return handler.next(err);
  }

  Future<void> _performRefresh(AuthLocalStorage storage) async {
    final refreshToken = await storage.getRefresh();
    if (refreshToken == null) {
      throw Exception('No refresh token found');
    }

    final refreshDio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final response = await refreshDio.post<Map<String, dynamic>>(
      '/api/v1/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final newJwt = data?['jwtToken'] as String?;
      final newRefresh = data?['refreshToken'] as String?;

      if (newJwt == null || newRefresh == null) {
        throw Exception('Invalid refresh response');
      }

      await storage.saveTokens(jwt: newJwt, refresh: newRefresh);
    } else {
      throw Exception('Refresh failed with status ${response.statusCode}');
    }
  }
}
