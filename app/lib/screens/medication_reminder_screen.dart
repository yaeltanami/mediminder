import 'package:flutter/material.dart';
import 'package:mediminder/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicationReminderScreen extends StatefulWidget {
  final String userId;
  final List<Map<String, dynamic>> medications;
  final String timeToTake;

  const MedicationReminderScreen({
    super.key,
    required this.userId,
    required this.medications,
    required this.timeToTake,
  });

  @override
  State<MedicationReminderScreen> createState() =>
      _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  final Color mainColor = const Color(0xFF208686);

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color.fromARGB(255, 32, 134, 134);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 241, 244),
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
          mainAxisAlignment: MainAxisAlignment.start, // מתחילים מהחלק העליון
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80), // ⬅️ כאן שולטים כמה נמוך להתחיל
            Image.asset('assets/images/welcome.png', width: 140, height: 140),

            const SizedBox(height: 20),

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

            Column(
              children:
                  widget.medications.map((med) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Take ${med['medicationName']} from slot ${med['slotNumber']}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
