import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../services/notifications_service.dart';
import '../widgets/caregiver_actions.dart';
import '../config.dart';
import 'dart:convert';


class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  State<CaregiverProfileScreen> createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  List<Map<String, dynamic>> patients = [];

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }
  

  Future<void> fetchPatients() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final caregiverId = auth.role?['_id'];
    final token = auth.token;

    if (caregiverId == null || token == null) return;

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/caregivers/patients/$caregiverId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> patientList = jsonDecode(response.body);

      final List<Map<String, dynamic>> enriched = [];
      for (var p in patientList) {
        final patientId = p['_id'];
        final userResponse = await http.get(
          Uri.parse('${Config.baseUrl}/patients/$patientId/user'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (userResponse.statusCode == 200) {
          final userData = jsonDecode(userResponse.body);
          enriched.add({'_id': patientId, 'name': userData['name']});
        }
      }
      setState(() {
        patients = enriched;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFF208686);
    final user = Provider.of<AuthProvider>(context).user;
    final name = user?['name'] ?? 'N/A';
    final email = user?['email'] ?? 'N/A';

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 241, 244),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF208686)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset('assets/images/welcome.png', width: 40),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Color(0xFF208686), size: 28),
                      const SizedBox(width: 10),
                      Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.email, color: Color(0xFF208686), size: 26),
                      const SizedBox(width: 10),
                      Text(email, style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text("My Patients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final p = patients[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 28,
                                backgroundColor: Color(0xFF208686),
                                child: Icon(Icons.person, color: Colors.white, size: 30),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  p['name'],
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Color(0xFF208686)),
                                    tooltip: 'Edit options',
                                    onPressed: () => showPatientActionsDialog(
                                      context: context,
                                      patient: p,
                                      fetchPatients: fetchPatients,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF208686),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Add Patient", style: TextStyle(color: Colors.white)),
                      onPressed: () => showAddPatientDialog(
                        context: context,
                        fetchPatients: fetchPatients,
                      ),
                    ),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await NotificationsService.logoutUser(authProvider.token!);
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
