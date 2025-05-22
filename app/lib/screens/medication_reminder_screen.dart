import 'package:flutter/material.dart';

class MedicationReminderScreen extends StatelessWidget {
  final String userId;
  final String medicationId;
  final String medicationName;
  final String slotNumber;

  const MedicationReminderScreen({
    super.key,
    required this.userId,
    required this.medicationId,
    required this.medicationName,
    required this.slotNumber,
  });

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color.fromARGB(255, 32, 134, 134);

    return Scaffold(
      backgroundColor: const Color(0xFFCEECF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Reminder',
          style: TextStyle(
            color: Color(0xFF208686),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Image.asset('assets/images/welcome.png', width: 140, height: 140),
            const SizedBox(height: 30),
            Text(
              'Time to take your medication!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Take $medicationName\nfrom slot $slotNumber',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: שלח אישור לשרת בעתיד
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('I took the medication'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: mainColor,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: mainColor, width: 2),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
