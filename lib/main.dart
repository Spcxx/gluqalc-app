import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/app.dart';
import 'package:gluqalc_app/core/init/app_initializer.dart';
import 'package:gluqalc_app/core/logging/app_provider_observer.dart';
import 'package:gluqalc_app/core/logging/logger_provider.dart';

void main() async {
  final initResult = await AppInitializer.initialize();

  runApp(
    ProviderScope(
      observers: [AppProviderObserver(initResult.logger)],
      overrides: [
        loggerProvider.overrideWithValue(initResult.logger),
      ],
      child: const App(),
    ),
  );
}
