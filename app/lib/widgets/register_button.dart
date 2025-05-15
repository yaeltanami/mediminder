import 'package:flutter/material.dart';
import '../screens/role_selection_screen.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({required this.screenWidth, required this.screenHeight});
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: screenHeight * 0.79,
      left: screenWidth * 0.1,
      child: SizedBox(
        width: screenWidth * 0.8,
        height: screenHeight * 0.07,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RoleSelectionScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color.fromARGB(255, 32, 134, 134), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Register',
            style: TextStyle(
              fontSize: 22,
              color: Color.fromARGB(255, 32, 134, 134),
              fontWeight: FontWeight.w700,
              fontFamily: 'Urbanist',
            ),
          ),
        ),
      ),
    );
  }
}
