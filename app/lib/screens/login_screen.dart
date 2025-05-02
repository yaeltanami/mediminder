import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart'; // הוספת Provider
import '../providers/auth_provider.dart'; // ייבוא מחלקת ה-AuthProvider
import 'home_screen.dart';
import '../config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

    @override
  void initState() {
    super.initState();
    printInitialFcmToken(); // הדפסת הטוקן כשהמסך עולה
  }

    void printInitialFcmToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('📱 FCM Token כשהמסך נטען (לפני התחברות): $fcmToken');
  }

  /// פונקציה ששולחת בקשת POST לשרת כדי לבדוק התחברות
  Future<void> loginUser(String email, String password) async {
    final url = Uri.parse('${Config.baseUrl}/users/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("\u2705 Login successful! Token: ${data['token']}");

        // עדכון הנתונים ב-AuthProvider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setUser(data['user']); // שמירת פרטי המשתמש
        authProvider.setToken(data['token']); // שמירת הטוקן
        await sendFcmToken(data['token']);//שליחת הטוקן לשרת


        // מעבר למסך הבית
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        print('\u274C Login failed: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed. Please try again.")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred.")),
      );
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

  /// פונקציה שתופעל בעת לחיצה על כפתור ההתחברות
  void _login() {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      loginUser(email, password);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
