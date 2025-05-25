class Config {
  static const String serverIp = '192.168.1.201'; // כתובת ה-IP של המחשב שלך

  static const int serverPort = 5050;

  static String get baseUrl => 'http://$serverIp:$serverPort/api';
}
