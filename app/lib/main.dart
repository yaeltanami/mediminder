import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

// Providers
import 'providers/auth_provider.dart';

// Screens
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/medication_reminder_screen.dart';
import 'screens/caregiver_reminder_screen.dart';
import 'screens/caregiver_missed_medication_screen.dart';
import 'screens/patient_missed_medication_screen.dart';
import 'screens/caregiver_medication_taken_screen.dart';

// Utils
import 'navigation_observer.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void setupFirebaseMessaging() {
  // כשהאפליקציה פתוחה
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final data = message.data;
    final action = data['action'];

    if (action == 'medication_reminder') {
      final userId = data['userId'];
      final timeToTake = data['timeToTake'];
      final medicationsJson = data['medications'];

      List<Map<String, dynamic>> medicationsList = [];

      if (medicationsJson != null) {
        final decoded = jsonDecode(medicationsJson);
        if (decoded is List) {
          medicationsList =
              decoded.map<Map<String, dynamic>>((item) {
                if (item is Map<String, dynamic>) return item;
                return <String, dynamic>{};
              }).toList();
        }
      }

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (context) => MedicationReminderScreen(
                userId: userId,
                timeToTake: timeToTake,
                medications: medicationsList,
              ),
        ),
      );
    }

    if (action == 'caregiver_reminder') {
      final patientName = data['patientName'];
      final medicationsJson = data['medications'];

      List<Map<String, dynamic>> medicationsList = [];

      if (medicationsJson != null) {
        final decoded = jsonDecode(medicationsJson);
        if (decoded is List) {
          medicationsList =
              decoded.map<Map<String, dynamic>>((item) {
                if (item is Map<String, dynamic>) return item;
                return <String, dynamic>{};
              }).toList();
        }
      }

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (context) => CaregiverReminderScreen(
                patientName: patientName,
                medications: medicationsList,
              ),
        ),
      );
    }

    if (action == 'medication_taken_cargiver') {
      final patientName = data['patientName'] ?? '';
      final medicationName = data['medicationName'] ?? '';
      final medicationId = data['medicationId'] ?? '';

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (context) => CaregiverMedicationTakenScreen(
                patientName: patientName,
                medicationName: medicationName,
              ),
        ),
      );
    }

    if (action == 'late_medication_alert') {
      final userId = data['userId'] ?? '';
      final medicationName = data['medicationName'] ?? '';
      final slotNumber = data['slotNumber'] ?? '';

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (context) => PatientMissedMedicationScreen(
                userId: userId,
                medicationName: medicationName,
                slotNumber: slotNumber,
              ),
        ),
      );
    }
  });

  // כשהאפליקציה נפתחת דרך התראה מהרקע
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final data = message.data;
    final action = data['action'];

    if (action == 'medication_reminder') {
      final userId = data['userId'];
      final timeToTake = data['timeToTake'];
      final medicationsJson = data['medications'];

      List<Map<String, dynamic>> medicationsList = [];

      if (medicationsJson != null) {
        final decoded = jsonDecode(medicationsJson);
        if (decoded is List) {
          medicationsList =
              decoded.map<Map<String, dynamic>>((item) {
                if (item is Map<String, dynamic>) return item;
                return <String, dynamic>{};
              }).toList();
        }
      }

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (context) => MedicationReminderScreen(
                userId: userId,
                timeToTake: timeToTake,
                medications: medicationsList,
              ),
        ),
      );
    }

    if (action == 'caregiver_reminder') {
      final patientName = data['patientName'];
      final medicationsJson = data['medications'];

      List<Map<String, dynamic>> medicationsList = [];

      if (medicationsJson != null) {
        final decoded = jsonDecode(medicationsJson);
        if (decoded is List) {
          medicationsList =
              decoded.map<Map<String, dynamic>>((item) {
                if (item is Map<String, dynamic>) return item;
                return <String, dynamic>{};
              }).toList();
        }
      }

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (context) => CaregiverReminderScreen(
                patientName: patientName,
                medications: medicationsList,
              ),
        ),
      );
    }

    if (action == 'medication_taken_cargiver') {
      final patientName = data['patientName'] ?? '';
      final medicationName = data['medicationName'] ?? '';
      final medicationId = data['medicationId'] ?? '';

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (context) => CaregiverMedicationTakenScreen(
                patientName: patientName,
                medicationName: medicationName,
              ),
        ),
      );
    }

    if (action == 'late_medication_alert') {
      final userId = data['userId'] ?? '';
      final medicationId = data['medicationId'] ?? '';
      final medicationName = data['medicationName'] ?? '';
      final slotNumber = data['slotNumber'] ?? '';

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (context) => PatientMissedMedicationScreen(
                userId: userId,
                medicationName: medicationName,
                slotNumber: slotNumber,
              ),
        ),
      );
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupFirebaseMessaging();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(scaffoldBackgroundColor: Colors.white),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return authProvider.user != null ? HomeScreen() : WelcomeScreen();
        },
      ),
    );
  }
}
