import 'package:flutter/material.dart';
import 'package:mediminder/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicationReminderScreen extends StatefulWidget {
  final String userId;
  final String medicationId;
  final String medicationName;
  final String slotNumber;
  final String timeToTake;

  const MedicationReminderScreen({
    super.key,
    required this.userId,
    required this.medicationId,
    required this.medicationName,
    required this.slotNumber,
    required this.timeToTake,
  });

  @override
  State<MedicationReminderScreen> createState() =>
      _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  final Color mainColor = const Color(0xFF208686);

  // 🟡 פונקציה חדשה ששולחת את הלוג לשרת
  Future<void> markAsTaken() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/medicationLog/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patientId': authProvider.role?['_id'],
          'medicationId': widget.medicationId,
          'date':
              DateTime.now().toIso8601String().split('T').first, // ✅ רק תאריך
          'time': widget.timeToTake,
        }),
      );

      if (response.statusCode == 201) {
        // 🟡 הודעת הצלחה
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication logged as taken ✅')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to log medication');
      }
    } catch (e) {
      // 🟡 הודעת שגיאה
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color.fromARGB(255, 32, 134, 134);

    return Scaffold(
      backgroundColor: const Color(0xFFCEECF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF208686)),
          onPressed: () => Navigator.pop(context),
        ),
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
              'Take ${widget.medicationName}\nfrom slot ${widget.slotNumber}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: markAsTaken,
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
