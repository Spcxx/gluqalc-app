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
  static const String githubApiUrl = String.fromEnvironment('GITHUB_API_URL');
  static const String githubAppUrl = String.fromEnvironment('GITHUB_APP_URL');

  static void validate() {
    if (apiUrl.isEmpty) {
      throw StateError(
        '[AppConfig] API_URL is empty; environment may be not set',
      );
    }
    if (githubApiUrl.isEmpty) {
      throw StateError(
        '[AppConfig] GITHUB_API_URL is empty; environment may be not set',
      );
    }
    if (githubAppUrl.isEmpty) {
      throw StateError(
        '[AppConfig] GITHUB_APP_URL is empty; environment may be not set',
      );
    }
  }
}
