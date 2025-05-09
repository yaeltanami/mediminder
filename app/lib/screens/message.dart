import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  final String userId;
  final String medicationId;
  final String medicationName;
  final bool isCaregiver;

  const MessageScreen({
    super.key,
    required this.userId,
    required this.medicationId,
    required this.medicationName,
    this.isCaregiver = false,
  });

  @override
  Widget build(BuildContext context) {
    final String message =
        isCaregiver
            ? "Hey, your patient (ID: $userId) needs to take: $medicationName"
            : "Hi! It's time to take your medication: $medicationName";

    return Scaffold(
      appBar: AppBar(title: const Text('Reminder')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                message,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
