import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    return Positioned(
      left: screenWidth * 0.2,
      top: screenHeight * 0.1,
      child: Container(
        width: screenWidth * 0.6,
        height: screenWidth * 0.6,
        decoration: ShapeDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/images/medi_logo.png"),  // השתמש ב-AssetImage
            fit: BoxFit.cover,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.3),
          ),
        ),
      ),
    );
  }
}
