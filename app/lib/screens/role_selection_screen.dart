import 'package:flutter/material.dart';
import 'register_screen.dart'; // ייבוא מסך הרשמה

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Role'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose your role',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // ניווט למסך הרשמה עם בחירת תפקיד מטופל
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterScreen(role: 'patient'),
                  ),
                );
              },
              child: const Text('Register as Patient'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // ניווט למסך הרשמה עם בחירת תפקיד מטפל
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterScreen(role: 'caregiver'),
                  ),
                );
              },
              child: const Text('Register as Caregiver'),
            ),
          ],
        ),
      ),
    );
  }
}
