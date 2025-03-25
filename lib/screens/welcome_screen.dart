import 'package:flutter/material.dart';
// import '../screens/login_screen.dart';  // ייבוא מסך התחברות
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
          // כיתוב "Welcome to"
          _buildText(
            context, 'Welcome to', screenWidth, screenHeight * 0.45, 
            Color.fromARGB(255, 214, 147, 40), 40,
          ),
          
          // כיתוב "MediMinder"
          _buildText(
            context, 'MediMinder', screenWidth, screenHeight * 0.52, 
            Color(0xFF196EB0), 55,
          ),

          // תמונת הלוגו
          AppLogo(),

          // כפתור התחברות - כעת משתמשים בכפתור שמייבאים מ-login_button.dart
          LoginButton(screenWidth: screenWidth, screenHeight: screenHeight), // כפתור התחברות

          // כפתור רישום - כעת משתמשים בכפתור שמייבאים מ-register_button.dart
          RegisterButton(screenWidth: screenWidth, screenHeight: screenHeight), // כפתור רישום
        ],
      ),
    );
  }

  // פונקציה לבניית טקסט ממורכז
  Widget _buildText(BuildContext context, String text, double screenWidth, double top, Color color, double fontSize) {
    return Positioned(
      left: screenWidth * 0.1,
      top: top,
      child: SizedBox(
        width: screenWidth * 0.8,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
