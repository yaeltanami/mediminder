/// WelcomeScreen
/// This is the first screen of the app. It displays the MediMinder logo,
/// welcoming text, and buttons to Login or Register.

import 'package:flutter/material.dart';
import '../widgets/login_button.dart';
import '../widgets/register_button.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 206, 236, 245), // תכלת בהיר
      body: Stack(
        children: [
          // לוגו מעוגל ללא רקע לבן
          Positioned(
            top: screenHeight * 0.15,
            left: screenWidth * 0.125,
            child: Container(
              width: screenWidth * 0.7,
              height: screenWidth * 0.7,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/welcome.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // טקסט אחיד: Welcome to MediMinder
          _buildText(
            context,
            'Welcome to\n',
            screenWidth,
            screenHeight * 0.50,
            const Color.fromARGB(255, 32, 134, 134), 
            32,
          ),
          _buildText(
            context,
            'MediMinder',
            screenWidth,
            screenHeight * 0.55,
            const Color.fromARGB(255, 32, 134, 134),
            48,
          ),
          // כפתורים
          LoginButton(screenWidth: screenWidth, screenHeight: screenHeight),
          RegisterButton(screenWidth: screenWidth, screenHeight: screenHeight),
        ],
      ),
    );
  }

  Widget _buildText(BuildContext context, String text, double width, double top, Color color, double fontSize) {
    return Positioned(
      top: top,
      left: width * 0.1,
      child: SizedBox(
        width: width * 0.8,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: FontWeight.bold,
            fontFamily: 'Urbanist',
          ),
        ),
      ),
    );
  }
}
