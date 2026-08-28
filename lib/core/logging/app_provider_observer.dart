import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

base class AppProviderObserver extends ProviderObserver {
  AppProviderObserver(this._logger);

  final Logger _logger;

  @override
  void didAddProvider(
    ProviderObserverContext context,
    Object? value,
  ) {
    _logger.d(
      '[Riverpod] Created: ${_providerName(context)} | Value: $value',
    );
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    _logger.i(
      '[Riverpod] Updated: ${_providerName(context)}\n'
      '  Prev: $previousValue\n'
      '  Next: $newValue',
    );
  }

  @override
  void didDisposeProvider(
    ProviderObserverContext context,
  ) {
    _logger.d(
      '[Riverpod] Disposed: ${_providerName(context)}',
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _logger.e(
      '[Riverpod] Failed: ${_providerName(context)}',
      error: error,
      stackTrace: stackTrace,
    );
  }

  String _providerName(ProviderObserverContext context) {
    return context.provider.name ?? context.provider.runtimeType.toString();
  }
}
