// lib/main.dart
import 'package:flutter/material.dart';
import 'login_screen.dart'; // הוספת ייבוא של המסך LoginScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Welcome(), // המסך הראשי
    );
  }
}

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // רוחב המסך
    double screenHeight = MediaQuery.of(context).size.height; // גובה המסך

    return Column(
      children: [
        Container(
          width: screenWidth,
          height: screenHeight,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
            ),
          ),
          child: Stack(
            children: [
              // הוספת כיתוב "Welcome to" בצבע צהוב
              Positioned(
                left: screenWidth * 0.1,
                top: screenHeight * 0.35,
                child: SizedBox(
                  width: screenWidth * 0.8,
                  child: const Text(
                    'Welcome to',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 30,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              // כיתוב "MediMinder"
              Positioned(
                left: screenWidth * 0.1,
                top: screenHeight * 0.42,
                child: SizedBox(
                  width: screenWidth * 0.7,
                  child: const Text(
                    'MediMinder',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF196EB0), // צבע כחול
                      fontSize: 50,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              // כפתור Login
              Positioned(
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
                      // פעולת המעבר למסך LoginScreen
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
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
              ),
              // כפתור Register (כפי שהיה קודם)
              Positioned(
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
              ),
              // תמונה (כפי שהיה קודם)
              Positioned(
                left: screenWidth * 0.2,
                top: screenHeight * 0.1,
                child: Container(
                  width: screenWidth * 0.6,
                  height: screenWidth * 0.6,
                  decoration: ShapeDecoration(
                    image: const DecorationImage(
                      image: NetworkImage("https://placehold.co/255x254"),
                      fit: BoxFit.cover,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
