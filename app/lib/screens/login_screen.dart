import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_screen.dart';

const String baseUrl = 'http://10.100.102.14:5050/api'; // כתובת השרת

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// פונקציה ששולחת בקשת POST לשרת כדי לבדוק התחברות
  Future<void> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/users/login');

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
        print("\u2705 Login successful! Token: \${data['token']}");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(username: data['user']['name']),
          ),
        );
      } else {
        print('\u274C Login failed: \${response.body}');
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
