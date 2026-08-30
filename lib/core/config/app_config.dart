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
  static const String contactEmail = String.fromEnvironment('CONTACT_EMAIL');
  static const String tosUrl = String.fromEnvironment('TOS_URL');
  static const String privacyUrl = String.fromEnvironment('PRIVACY_URL');
  static const String disclaimerUrl = String.fromEnvironment('DISCLAIMER_URL');

  static void _require(String value, String envName) {
    if (value.isEmpty) {
      throw StateError(
        '[AppConfig] $envName is empty; environment may be not set',
      );
    }
  }

  static void validate() {
    _require(apiUrl, 'API_URL');
    _require(githubApiUrl, 'GITHUB_API_URL');
    _require(githubAppUrl, 'GITHUB_APP_URL');
    _require(contactEmail, 'CONTACT_EMAIL');
    _require(tosUrl, 'TOS_URL');
    _require(privacyUrl, 'PRIVACY_URL');
    _require(disclaimerUrl, 'DISCLAIMER_URL');
  }
}
