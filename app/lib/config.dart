class Config {
  static const String serverIp = '10.100.102.34'; // כתובת ה-IP של המחשב שלך

  static const int serverPort = 5050;

  static String get baseUrl => 'http://$serverIp:$serverPort/api';
}
