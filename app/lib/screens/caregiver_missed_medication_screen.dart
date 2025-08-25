import 'package:flutter/material.dart';

class CaregiverMissedMedicationScreen extends StatelessWidget {
  final String patientName;          // שם המטופל לתצוגה
  final String medicationName;       // שם התרופה שלא נלקחה

  const CaregiverMissedMedicationScreen({
    Key? key,
    required this.patientName,
    required this.medicationName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFF208686);

    return Scaffold(
      backgroundColor: const Color(0xFFE6F1F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // כמו במסך הקיים
        title: const Text(
          'Missed Medication',
          style: TextStyle(
            color: Color(0xFF208686),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            // משתמשים באותה תמונה כדי לשמר את העיצוב
            Image.asset('assets/images/welcome.png', width: 140, height: 140),
            const SizedBox(height: 30),
            Text(
               "It seems $patientName didn’t take a medication",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
            const SizedBox(height: 16),

            // כמו ברשימה במסך המקורי, אבל כאן יש תרופה אחת מרכזית
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFF208686),
                ),
                title: Text(
                  medicationName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const Spacer(),
            // כפתור אישור/סגירה כמו רוח העיצוב
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(context).pop(),
                label: const Text('OK'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
