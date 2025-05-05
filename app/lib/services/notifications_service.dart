import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class NotificationsService {
  static Future<void> sendTokenToServer(String token) async {
    final url = Uri.parse('${Config.baseUrl}/save-token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_AUTH_TOKEN', // אם את משתמשת ב־JWT
        },
        body: jsonEncode({'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        print('✅ FCM Token נשלח לשרת בהצלחה');
      } else {
        print('❌ בעיה בשליחה לשרת: ${response.body}');
      }
    } catch (e) {
      print('❌ שגיאה: $e');
    }
  }
}
