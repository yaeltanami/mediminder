class Config {

  static const String serverIp = '10.100.102.22'; // כתובת ה-IP של המחשב שלך

  static const int serverPort = 5050;

  static String get baseUrl => 'http://$serverIp:$serverPort/api';
}
