/// Build-time environment configuration.
///
/// Override at build/run time with:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8123/api --dart-define=WEB_BASE_URL=http://10.0.2.2:8123
///
/// Defaults point at the live production API so the app works out of the box
/// without requiring a local Laravel server to be running.
class Env {
  Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://learnquad.com/api',
  );

  static const String webBaseUrl = String.fromEnvironment(
    'WEB_BASE_URL',
    defaultValue: 'https://learnquad.com',
  );
}
