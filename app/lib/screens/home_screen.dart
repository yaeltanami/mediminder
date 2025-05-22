import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/auth_provider.dart';
import '../config.dart';
import '../widgets/weekday_selector.dart';
import '../widgets/medication_card.dart';

import 'message.dart';
import 'welcome_screen.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

/// מסך הבית הראשי של האפליקציה.
///
/// מציג למשתמש את שם המשתמש המחובר, מאפשר לבחור יום בשבוע,
/// ומציג את כל התרופות שעליו לקחת באותו היום.
/// בנוסף ניתן להוסיף תרופה חדשה דרך כפתור הפלוס.

import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // הגדרת היום הנבחר כברירת מחדל (היום הנוכחי)
  String selectedDay =
      DateTime.now().weekday == 7
          ? 'Sunday'
          : [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
          ][DateTime.now().weekday - 1];

  List<dynamic> medications = []; // רשימת התרופות שנשלפות מהשרת

  @override
  @override
  void initState() {
    super.initState();
    // טעינת תרופות
    fetchMedicationsForDay();
  }

  Future<void> fetchMedicationsForDay() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final patientId = authProvider.role?['_id'];
    final token = authProvider.token;

    if (patientId == null || token == null) return;

    try {
      final response = await http.get(
        Uri.parse(
          '${Config.baseUrl}/medications/patient/$patientId/day/$selectedDay',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          medications = jsonDecode(response.body);
        });
      } else {
        print('❌ Failed to load medications');
      }
    } catch (e) {
      print('❌ Error fetching medications: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final username = authProvider.user?['name'] ?? "Guest";
    final Color mainColor = const Color.fromARGB(255, 32, 134, 134);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 206, 236, 245),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // שורת פתיחה עם טקסט, אייקון ו־לוגו
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome, $username',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.person,
                          color: Color(0xFF208686),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                          fetchMedicationsForDay(); // ירענן את התרופות כשחוזרים
                        },
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/images/welcome.png',
                        width: 50,
                        height: 50,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  selectedDay,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              WeekdaySelector(
                selectedDay: selectedDay,
                onDaySelected: (day) {
                  setState(() {
                    selectedDay = day;
                  });
                  fetchMedicationsForDay();
                },
              ),
              const SizedBox(height: 32),

              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.medication,
                          size: 30,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${medications.length}/?',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: mainColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedDay,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Medications for selected day:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Expanded(
                child:
                    medications.isEmpty
                        ? const Text("No medications for this day.")
                        : ListView.builder(
                          itemCount: medications.length,
                          itemBuilder: (context, index) {
                            return MedicationCard(
                              medication: medications[index],
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
