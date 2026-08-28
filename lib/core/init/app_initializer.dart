import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gluqalc_app/core/config/app_config.dart';
import 'package:gluqalc_app/core/logging/logger_provider.dart';
import 'package:logger/logger.dart';

class AppInitializationResult {
  const AppInitializationResult({required this.logger});
  final Logger logger;
}

class AppInitializer {
  static Future<AppInitializationResult> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    AppConfig.validate();

    final logger = createLogger();

    _setupErrorHandlers(logger);

    logger.i(
      'Application core initialized. Current environment: ${AppConfig.isProd ? "PROD" : "DEV"}',
    );
    return AppInitializationResult(logger: logger);
  }

  static void _setupErrorHandlers(Logger logger) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      logger.e(
        '[Critical UI Error]',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      logger.e(
        '[Unhandled Async Error]',
        error: error,
        stackTrace: stack,
      );
      return true;
    };
  }
}
