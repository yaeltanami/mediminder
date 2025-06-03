import 'package:flutter/material.dart';

class CaregiverReminderScreen extends StatelessWidget {
  final String patientName;
  final List<Map<String, dynamic>> medications;

  const CaregiverReminderScreen({
    Key? key,
    required this.patientName,
    required this.medications,
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
        automaticallyImplyLeading: false,
        title: const Text(
          'Patient Reminder',
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
            Image.asset('assets/images/welcome.png', width: 140, height: 140),
            const SizedBox(height: 30),
            Text(
             'Time to check on your patient',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
               "Make sure $patientName took their medications",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  final med = medications[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.medication, color: Color(0xFF208686)),
                      title: Text(med['medicationName'] ?? ''),
                      subtitle: Text('Slot: ${med['slotNumber'] ?? ''}'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            // ElevatedButton.icon(
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            //   icon: const Icon(Icons.check_circle_outline),
            //   label: const Text('Checked In'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.white,
            //     foregroundColor: mainColor,
            //     minimumSize: const Size.fromHeight(50),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(30),
            //       side: BorderSide(color: mainColor, width: 2),
            //     ),
            //     textStyle: const TextStyle(
            //       fontSize: 18,
            //       fontWeight: FontWeight.bold,
            //       fontFamily: 'Urbanist',
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
