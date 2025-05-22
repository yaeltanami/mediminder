import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'medications_management_screen.dart';
import 'caregivers_screen.dart';
import 'login_screen.dart';
import '../services/notifications_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFF208686);
    final user = Provider.of<AuthProvider>(context).user;
    final role = Provider.of<AuthProvider>(context).role;

    final name = user?['name'] ?? 'N/A';
    final email = user?['email'] ?? 'N/A';
    final birthDateStr = role?['birthDate'];
    final birthDate =
        birthDateStr != null ? DateTime.tryParse(birthDateStr) : null;
    final age =
        birthDate != null
            ? DateTime.now().year -
                birthDate.year -
                (DateTime.now().month < birthDate.month ||
                        (DateTime.now().month == birthDate.month &&
                            DateTime.now().day < birthDate.day)
                    ? 1
                    : 0)
            : 'N/A';

    return Scaffold(
      backgroundColor: const Color(0xFFCEECF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF208686)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset(
              'assets/images/welcome.png',
              width: 40,
              height: 40,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "My Profile",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF208686),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person,
                        size: 20,
                        color: Color(0xFF208686),
                      ),
                      const SizedBox(width: 8),
                      Text("Name: $name", style: const TextStyle(fontSize: 22)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.email,
                        size: 20,
                        color: Color(0xFF208686),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Email: $email",
                        style: const TextStyle(fontSize: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cake,
                        size: 20,
                        color: Color(0xFF208686),
                      ),
                      const SizedBox(width: 8),
                      Text("Age: $age", style: const TextStyle(fontSize: 22)),
                    ],
                  ),

                  const SizedBox(height: 50),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.medication, color: Colors.white),
                    label: const Text(
                      "My Medications",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 30,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MedicationsManagementScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.group, color: Colors.white),
                    label: const Text(
                      "My Caregivers",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 30,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CaregiversScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: OutlinedButton.icon(
              icon: Icon(Icons.logout, color: mainColor),
              label: Text("Logout", style: TextStyle(color: mainColor)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: mainColor, width: 2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await NotificationsService.logoutUser(
                  authProvider.token!,
                ); // הוספת !
                authProvider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
