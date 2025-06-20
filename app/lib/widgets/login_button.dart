import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({required this.screenWidth, required this.screenHeight});
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: screenHeight * 0.69,
      left: screenWidth * 0.1,
      child: SizedBox(
        width: screenWidth * 0.8,
        height: screenHeight * 0.07,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 32, 134, 134),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Login',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontFamily: 'Urbanist',
            ),
          ),
        ),
      ),
    );
  }
}

