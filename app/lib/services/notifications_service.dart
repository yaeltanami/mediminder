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
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendFcmToken(String jwt) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      print(' FCM Token is null');
      return;
    }

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/users/save-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({'fcmToken': fcmToken}),
    );
  }

  static Future<void> logoutUser(String jwt) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      print(' No FCM token found');
      return;
    }

    // שליחת בקשה לשרת להסרת ה־Token מהמשתמש
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/users/remove-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({'fcmToken': fcmToken}),
    );

    //  הסרת ה־Token מהמכשיר המקומי
    try {
      await FirebaseMessaging.instance.deleteToken();
      print(' FCM token deleted locally');
    } catch (e) {
      print('Failed to delete FCM token locally: $e');
    }
  }
}
