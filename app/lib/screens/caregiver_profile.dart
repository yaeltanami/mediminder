import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'medications_management_screen.dart';

class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  State<CaregiverProfileScreen> createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
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
      Uri.parse('${Config.baseUrl}/caregivers/$caregiverId/patients'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> patientList = jsonDecode(response.body);

      // טוען את שמות המטופלים
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

  Future<void> _addPatientByEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter patient email")),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final caregiverId = auth.role?['_id'];
    final token = auth.token;

    try {
      final findResponse = await http.get(
        Uri.parse('${Config.baseUrl}/patients/by-email?email=$email'),
      );

      if (findResponse.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Patient not found")),
        );
        return;
      }

      final patientData = jsonDecode(findResponse.body);
      final patientId = patientData['_id'];

      final addResponse = await http.post(
        Uri.parse('${Config.baseUrl}/caregivers/$caregiverId/add-patient'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'patientId': patientId}),
      );

      if (addResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Patient added successfully")),
        );
        _emailController.clear();
        fetchPatients(); // רענון
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Failed to add patient")),
        );
      }
    } catch (e) {
      print("Error adding patient: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFF208686);
    final user = Provider.of<AuthProvider>(context).user;
    final name = user?['name'] ?? 'N/A';
    final email = user?['email'] ?? 'N/A';

    return Scaffold(
      backgroundColor: const Color(0xFFCEECF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Caregiver Profile', style: TextStyle(color: Color(0xFF208686))),
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
                  Text("Name: $name", style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  Text("Email: $email", style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 30),
                  const Text("My Patients:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  ...patients.map((p) => Card(
                        child: ListTile(
                          title: Text(p['name']),
                          trailing: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MedicationsManagementScreen(patientId: p['_id']),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text("Edit Medications"),
                          ),
                        ),
                      )),

                  const SizedBox(height: 30),
                  const Text("Add Patient by Email:", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Patient Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFF208686)),
                        onPressed: _addPatientByEmail,
                      )
                    ],
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
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
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
