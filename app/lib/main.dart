import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/medication_reminder_screen.dart';
import 'screens/caregiver_reminder_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void setupFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final data = message.data;
    final action = data['action'];

    if (action == 'medication_reminder') {
      final userId = data['userId'];
      final medicationId = data['medicationId'];
      final medicationName = data['medicationName'];
      final slotNumber = data['slotNumber'];
      final timeToTake = data['timeToTake'];

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (context) => MedicationReminderScreen(
                userId: userId,
                medicationId: medicationId,
                medicationName: medicationName,
                slotNumber: slotNumber,
                timeToTake: timeToTake,
              ),
        ),
      );
    }
    if (action == 'caregiver_reminder') {
      final patientName = data['patientName'];
      final medicationId = data['medicationId'];
      final medicationName = data['medicationName'];

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (context) => CaregiverReminderScreen(
                patientName: patientName,
                medicationId: medicationId,
                medicationName: medicationName,
              ),
        ),
      );
    }

    // ניתן להוסיף כאן את טיפול ב-caregiver_reminder בעתיד
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final data = message.data;
    final action = data['action'];

    if (action == 'medication_reminder') {
      final userId = data['userId'];
      final medicationId = data['medicationId'];
      final medicationName = data['medicationName'];
      final slotNumber = data['slotNumber'];
      final timeToTake = data['timeToTake'];

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (context) => MedicationReminderScreen(
                userId: userId,
                medicationId: medicationId,
                medicationName: medicationName,
                slotNumber: slotNumber,
                timeToTake: timeToTake, 
              ),
        ),
      );
    }

    if (action == 'caregiver_reminder') {
      final patientName = data['patientName'];
      final medicationId = data['medicationId'];
      final medicationName = data['medicationName'];

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (context) => CaregiverReminderScreen(
                patientName: patientName,
                medicationId: medicationId,
                medicationName: medicationName,
              ),
        ),
      );
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // אתחול Firebase
  await Firebase.initializeApp();
  setupFirebaseMessaging();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ), // יצירת ה-Provider
      ],
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
