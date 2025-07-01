import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'patient_home_screen.dart';
import 'caregiver_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.user?['role']; 
    if (role == 'caregiver') {
      return const CaregiverHomeScreen();
    } else {
      return const PatientHomeScreen();
    }
  }
}
