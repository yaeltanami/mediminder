// import 'package:flutter/material.dart';
// import '../screens/login_screen.dart';  // ייבוא המסך של התחברות

// class LoginButton extends StatelessWidget {
//   const LoginButton({required this.screenWidth, required this.screenHeight});
//   final double screenWidth;
//   final double screenHeight;

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: screenWidth * 0.1,
//       top: screenHeight * 0.75,
//       child: SizedBox(
//         width: screenWidth * 0.8,
//         height: screenHeight * 0.07,
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF196EB0), // הגדרת צבע הרקע
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//           ),
//           onPressed: () {
//             // ניווט למסך ה-login
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const LoginScreen()), // מעבר למסך login_screen.dart
//             );
//           },
//           child: const Center(
//             child: Text(
//               'Login',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontFamily: 'Urbanist',
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// 📄 login_button.dart
// A styled login button that navigates to the login screen

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

