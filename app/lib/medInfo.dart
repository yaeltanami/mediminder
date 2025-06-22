import 'package:flutter/material.dart';

class Medinfo extends StatelessWidget {
  const Medinfo({super.key}); //  הוספנו את ה-Key

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 430,
          height: 932,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(21),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 1,
                top: 0,
                child: Container(
                  width: 430,
                  height: 44,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: const Center(
                    child: Text(
                      '9:41',
                      style: TextStyle(
                        color: Color(0xFF090A0A),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 19,
                top: 161,
                child: Container(
                  width: 394,
                  height: 664,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFEFFAFF),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1.75,
                        color: Color(0xFFD8D9E0),
                      ),
                      borderRadius: BorderRadius.circular(41.96),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 111,
                        top: 291.05,
                        child: Container(
                          width: 118.32,
                          height: 106.12,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://placehold.co/118x106",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 27,
                        top: 354,
                        child: const Text(
                          'Lipitor capsule',
                          style: TextStyle(
                            color: Color(0xFF196EB0),
                            fontSize: 47,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            height: 0.34,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 53,
                        top: 443,
                        child: const Text(
                          '06:13 PM, Wednesday',
                          style: TextStyle(
                            color: Color(0xFF196EB0),
                            fontSize: 32,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 0.78,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 53,
                        top: 558,
                        child: const Text(
                          '1 capsule, 50mg',
                          style: TextStyle(
                            color: Color(0xFF196EB0),
                            fontSize: 32,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 0.78,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 22,
                top: 284,
                child: Container(
                  width: 391,
                  height: 30,
                  child: const Text.rich(
                    TextSpan(
                      text: "Pay attention!\n", // ✅ תיקון הגרש הכפול
                      style: TextStyle(
                        color: Color(0xFFF61B1B),
                        fontSize: 36,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.20,
                      ),
                      children: [
                        TextSpan(
                          text: "Don't forget to take your medicine",
                          style: TextStyle(
                            color: Color(0xFF196EB0),
                            fontSize: 27,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.20,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
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
