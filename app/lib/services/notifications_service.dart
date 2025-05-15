import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

  Future<void> sendFcmToken(String jwt) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();

    print('🔄 מנסה לשלוח את ה-FCM Token לאחר התחברות: $fcmToken');

    if (fcmToken == null) {
      print('⚠️ FCM Token is null');
      return;
    }

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/users/save-token'), // עדכון לנתיב הנכון
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({'fcmToken': fcmToken}),
    );

    if (response.statusCode == 200) {
      print('✅ FCM Token נשלח ונקשר למשתמש בהצלחה');
    } else {
      print('❌ שגיאה בשליחת הטוקן: ${response.body}');
    }
  }

  static Future<void> removeFcmToken(String jwt) async {
    print('logout');
    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      print('⚠️ No FCM token found');
      return;
    }

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/users/remove-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({'fcmToken': fcmToken}),
    );

    if (response.statusCode == 200) {
      print('✅ FCM token removed from server');
    } else {
      print('❌ Failed to remove FCM token: ${response.body}');
    }
  }
}
