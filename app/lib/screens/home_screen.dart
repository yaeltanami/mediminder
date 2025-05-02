import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/auth_provider.dart';
import 'add_medication_screen.dart';
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

    // מאזין להתראות מהשרת כשהאפליקציה פתוחה
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📲 FCM message received!');

      if (message.data.isNotEmpty) {
        final action = message.data['action'];

        if (action == 'medication_reminder') {
          final userId = message.data['userId'];
          final medicationId = message.data['medicationId'];
          final medicationName = message.data['medicationName'];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => MessageScreen(
                    userId: userId,
                    medicationId: medicationId,
                    medicationName: medicationName,
                    isCaregiver: false, // מטופל
                  ),
            ),
          );
        } else if (action == 'caregiver_reminder') {
          final patientUserId = message.data['patientUserId'];
          final medicationId = message.data['medicationId'];
          final medicationName = message.data['medicationName'];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => MessageScreen(
                    userId: patientUserId,
                    medicationId: medicationId,
                    medicationName: medicationName,
                    isCaregiver: true, // מטפל
                  ),
            ),
          );
        } else if (action == 'medication_taken') {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            print('✅ Closed message screen: medication taken.');
          }
        } else {
          print('⚠️ Unknown action received: $action');
        }
      }
    });
  }

  // שליפת תרופות מהשרת לפי היום והמשתמש המחובר
  Future<void> fetchMedicationsForDay() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final patientId = authProvider.user?['_id'];
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

  Future<void> logoutUser(String jwt) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      print('⚠️ No FCM token found');
      return;
    }

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/users/remove-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({'fcmToken': fcmToken}),
    );

    if (response.statusCode == 200) {
      print('✅ FCM token removed from server');
    } else {
      print('❌ Failed to remove FCM token: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final username =
        authProvider.user?['name'] ?? "Guest"; // הצגת שם המשתמש המחובר

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ניווט למסך הוספת תרופה, ואז רענון התרופות
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
          );
          fetchMedicationsForDay();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      'Welcome, $username',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    ),
    IconButton(
      icon: const Icon(Icons.logout, color: Colors.red),
      tooltip: 'Logout',
      onPressed: () async {
        final token = authProvider.token;
        if (token != null) {
          await logoutUser(token);
        }

        authProvider.setUser(null);
        authProvider.setToken(null);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => WelcomeScreen()),
        );
      },
    ),
  ],
),

              const SizedBox(height: 24),

              const Center(
                child: Text(
                  'Today',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),

              // בחירת יום
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

              // עיגול המציג מידע על מספר התרופות
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
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
                          '${medications.length}/?', // כמה תרופות יש ליום הזה
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
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

              // כותרת לרשימת התרופות
              const Text(
                'Medications for selected day:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // הצגת התרופות או הודעה שאין
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
