import 'package:flutter/material.dart';
import '../screens/RoleSelectionScreen.dart';  // ייבוא מסך ההרשמה

class RegisterButton extends StatelessWidget {
  const RegisterButton({required this.screenWidth, required this.screenHeight});
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: screenWidth * 0.1,
      top: screenHeight * 0.85,
      child: SizedBox(
        width: screenWidth * 0.8,
        height: screenHeight * 0.07,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // רקע לבן
            side: const BorderSide(color: Color(0xFF196EB0), width: 2), // מסגרת כחולה
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // קצוות מעוגלים
            ),
          ),
          onPressed: () {
            // ניווט למסך ההרשמה
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RoleSelectionScreen()), // מעבר למסך RoleSelectionScreen
            );
          },
          child: const Center(
            child: Text(
              'Register',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF196EB0), // טקסט כחול
                fontSize: 22,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
