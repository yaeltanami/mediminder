import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; // ייבוא של מסך ה-Welcome

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: WelcomeScreen(),  // הצגת מסך ה-Welcome
    );
  }
}
