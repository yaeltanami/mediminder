import 'package:flutter/material.dart';

// קבלת השם של המשתמש שיתחבר
class HomeScreen extends StatelessWidget {
  final String username; // משתנה שמקבל את שם המשתמש שהועבר ממסך ההתחברות

  const HomeScreen({super.key, required this.username}); // קונסטרוקטור שמקבל את שם המשתמש

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Text(
          'Welcome, $username!', // הצגת שם המשתמש על המסך הראשי
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
