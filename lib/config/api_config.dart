class ApiConfig {
  // Local (same Wi-Fi)
  static const String localUrl = 'http://192.168.31.100:5001';

  // Ngrok (any network)
  static const String ngrokUrl =
      'https://thieveless-vadose-justine.ngrok-free.dev';

  // SWITCH ONLY THIS
  static const bool useNgrok = true;

  static String get baseUrl => useNgrok ? ngrokUrl : localUrl;
}