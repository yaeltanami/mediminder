import 'package:flutter/material.dart';

class CaregiverMedicationTakenScreen extends StatelessWidget {
  final String patientName;
  final String medicationName;

  const CaregiverMedicationTakenScreen({
    Key? key,
    required this.patientName,
    required this.medicationName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF208686);

    return Scaffold(
      backgroundColor: const Color(0xFFE6F1F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // כמו במסך המקורי
        title: const Text(
          'Medication Taken',
          style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            // שומר על אותה שפה עיצובית/תמונה כמו המסך הקיים
            Image.asset('assets/images/welcome.png', width: 140, height: 140),
            const SizedBox(height: 30),
             Text(
              "$patientName took a medication",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: mainColor),
                title: Text(
                  medicationName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.close),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(context).pop(),
                label: const Text('Close'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
