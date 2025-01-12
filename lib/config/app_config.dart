class AppConfig {
  static late String _currentUserLogin;
  static late DateTime _currentUtcTime;

  static String get currentUserLogin => _currentUserLogin;
  static DateTime get currentUtcTime => _currentUtcTime;

  static void initialize({
    required String currentUserLogin,
    required DateTime currentUtcTime,
  }) {
    _currentUserLogin = currentUserLogin;
    _currentUtcTime = currentUtcTime;
  }
}