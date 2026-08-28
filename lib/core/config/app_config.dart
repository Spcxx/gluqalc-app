import 'package:envied/envied.dart';

part 'app_config.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class AppSecrets {
  @EnviedField(varName: 'TODO', obfuscate: true)
  static final String todo = _AppSecrets.todo;
}

class AppConfig {
  static const String apiUrl = String.fromEnvironment('API_URL');
  static const bool isProd = bool.fromEnvironment('IS_PROD');

  static void validate() {
    if (apiUrl.isEmpty) {
      throw StateError(
        '[AppConfig] API_URL is empty; environment may be not set',
      );
    }
  }
}
