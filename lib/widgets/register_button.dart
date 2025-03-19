import 'package:flutter/material.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({required this.screenWidth, required this.screenHeight});
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: screenWidth * 0.1,
      top: screenHeight * 0.85,
      child: Container(
        width: screenWidth * 0.8,
        height: screenHeight * 0.07,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFF196EB0),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Center(
          child: Text(
            'Register',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF196EB0),
              fontSize: 22,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
