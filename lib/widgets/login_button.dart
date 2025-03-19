import 'package:flutter/material.dart';
import '../screens/login_screen.dart';  // ייבוא המסך של התחברות

class LoginButton extends StatelessWidget {
  const LoginButton({required this.screenWidth, required this.screenHeight});
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: screenWidth * 0.1,
      top: screenHeight * 0.75,
      child: Container(
        width: screenWidth * 0.8,
        height: screenHeight * 0.07,
        decoration: ShapeDecoration(
          color: const Color(0xFF196EB0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: ElevatedButton(
          onPressed: () {
            // ניווט למסך ה-login
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()), // מעבר למסך login_screen.dart
            );
          },
          child: const Center(
            child: Text(
              'Login',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
