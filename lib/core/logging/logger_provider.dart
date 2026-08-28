import 'package:gluqalc_app/core/config/app_config.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger_provider.g.dart';

Logger createLogger() {
  const isProduction = AppConfig.isProd;

  return Logger(
    level: isProduction ? Level.warning : Level.all,
    printer: isProduction
        ? SimplePrinter(
            printTime: true,
            colors: false,
          )
        : PrettyPrinter(),
    filter: _ProductionLogFilter(isProduction: isProduction),
  );
}

@Riverpod(keepAlive: true)
Logger logger(Ref ref) {
  return createLogger();
}

class _ProductionLogFilter extends LogFilter {
  _ProductionLogFilter({required this.isProduction});

  final bool isProduction;

  @override
  bool shouldLog(LogEvent event) {
    if (isProduction) return event.level.index >= Level.warning.index;
    return true;
  }
}
