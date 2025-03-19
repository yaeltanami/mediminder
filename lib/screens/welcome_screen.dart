import 'package:flutter/material.dart';
import '../widgets/login_button.dart';  // ייבוא כפתור התחברות
import '../widgets/register_button.dart';  // ייבוא כפתור רישום
import '../widgets/app_logo.dart';  // ייבוא תמונת הלוגו

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: screenWidth * 0.1,
            top: screenHeight * 0.35,
            child: SizedBox(
              width: screenWidth * 0.8,
              child: const Text(
                'Welcome to',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 215, 141, 21),
                  fontSize: 30,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.1,
            top: screenHeight * 0.42,
            child: SizedBox(
              width: screenWidth * 0.7,
              child: const Text(
                'MediMinder',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF196EB0),
                  fontSize: 50,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          AppLogo(), // תמונת הלוגו
          LoginButton(screenWidth: screenWidth, screenHeight: screenHeight), // כפתור התחברות
          RegisterButton(screenWidth: screenWidth, screenHeight: screenHeight), // כפתור רישום
        ],
      ),
    );
  }
}
