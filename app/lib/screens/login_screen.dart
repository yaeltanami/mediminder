
/// LoginScreen
/// מסך התחברות לאפליקציית MediMinder.
/// המשתמש מזין אימייל וסיסמה, ואם הפרטים נכונים – מתבצעת התחברות ומעבר למסך הבית.
/// העיצוב מותאם למסך הראשי בצבעי טורקיז ונראות אחידה.

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import '../config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'welcome_screen.dart';

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

  Future<void> loginUser(String email, String password) async {
    final url = Uri.parse('${Config.baseUrl}/users/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setUser(data['user']);
        authProvider.setToken(data['token']);

        final userRole = data['user']['role'];
        final userId = data['user']['_id'];

        try {
          Uri roleUrl;

          if (userRole == 'patient') {
            roleUrl = Uri.parse('${Config.baseUrl}/patients/by-user/$userId');
          } else {
            roleUrl = Uri.parse('${Config.baseUrl}/caregivers/by-user/$userId');
          }

          final roleResponse = await http.get(roleUrl, headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${data['token']}',
          });

          if (roleResponse.statusCode == 200) {
            final roleData = jsonDecode(roleResponse.body);
            authProvider.setRole(roleData);
          } else {
            print("Failed to fetch role data: ${roleResponse.statusCode}");
          }
        } catch (e) {
          print("Error fetching role data: $e");
        }

        try {
          await sendFcmToken(data['token']);
        } catch (e) {
          print('🚨 שגיאה בשליחת FCM Token: $e');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect email or password. Please try again.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred.")),
      );
    }
  }

  Future<void> sendFcmToken(String jwt) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('lllllllll $fcmToken');

    if (fcmToken == null) {
      print('⚠️ FCM Token is null');
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

    if (response.statusCode == 200) {
      print('✅ FCM Token נשלח ונקשר למשתמש בהצלחה');
    } else {
      print('❌ שגיאה בשליחת הטוקן: ${response.body}');
    }
  }

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
    final Color mainColor = const Color.fromARGB(255, 32, 134, 134);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 206, 236, 245),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Color.fromARGB(255, 32, 134, 134),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => WelcomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/welcome.png',
                    width: 170,
                    height: 170,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const SizedBox(height: 40),
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
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: _login,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
