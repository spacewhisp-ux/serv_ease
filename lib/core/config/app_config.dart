class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://47.82.121.213:3001/v1/',
  );
}
