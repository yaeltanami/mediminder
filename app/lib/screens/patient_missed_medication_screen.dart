import 'package:flutter/material.dart';

class PatientMissedMedicationScreen extends StatelessWidget {
  final String userId;
  final String medicationName;
  final String slotNumber;

  const PatientMissedMedicationScreen({
    super.key,
    required this.userId,
    required this.medicationName,
    required this.slotNumber,
  });

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF208686);

    return Scaffold(
      backgroundColor: const Color(0xFFE6F1F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: mainColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reminder',
          style: TextStyle(
            color: mainColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Image.asset('assets/images/welcome.png', width: 140, height: 140),

            const SizedBox(height: 20),

            const Text(
              'You’re running late!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Please take your medication now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.schedule, color: mainColor),
                title: Text(
                  medicationName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('Slot: $slotNumber'),
              ),
            ),

            const Spacer(),

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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
