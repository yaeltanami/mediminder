import 'package:flutter/material.dart';

class ReminderScreen extends StatelessWidget {
  final String name;
  final String dose;
  final DateTime time;

  const ReminderScreen({
    super.key,
    required this.name,
    required this.dose,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}";
    final day = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
    ][time.weekday % 7];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // שורת אייקונים עליונה (ריק/אינפו + מחיקה)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.info_outline, color: Colors.amber),
                  Icon(Icons.delete_outline, color: Colors.red),
                ],
              ),

              const SizedBox(height: 12),

              const Text(
                'Pay attention!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Don't forget to take your medicine",
                style: TextStyle(fontSize: 20, color: Colors.blue),
              ),

              const SizedBox(height: 16),

              const Icon(Icons.local_pharmacy, size: 48, color: Colors.orange),

              const SizedBox(height: 16),

              Text(
                '$name',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    '$formattedTime, $day',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.description, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    dose,
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
