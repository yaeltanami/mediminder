import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';
import '../providers/auth_provider.dart';
import '../screens/medications_management_screen.dart';

Future<void> removePatient({
  required BuildContext context,
  required String patientId,
}) async {
  final auth = Provider.of<AuthProvider>(context, listen: false);
  final caregiverId = auth.role?['_id'];
  final token = auth.token;

  try {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/caregivers/remove-patient'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'caregiverId': caregiverId,
        'patientId': patientId,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Patient removed")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to remove patient")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Server error")),
    );
  }
}

void showPatientActionsDialog({
  required BuildContext context,
  required Map patient,
  required VoidCallback fetchPatients,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.person, color: Color(0xFF208686)),
          const SizedBox(width: 8),
          Text(patient['name']),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MedicationsManagementScreen(patientId: patient['_id']),
                ),
              ).then((_) => fetchPatients());
            },
            icon: const Icon(Icons.medication),
            label: const Text("Edit Medications"),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF208686)),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await removePatient(context: context, patientId: patient['_id']);
              fetchPatients();
            },
            icon: const Icon(Icons.delete),
            label: const Text("Delete"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ],
    ),
  );
}

void showAddPatientDialog({
  required BuildContext context,
  required void Function() fetchPatients,
}) {
  final emailController = TextEditingController();
  String? patientId;
  bool? found;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Patient'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Enter patient email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                /// שורת Search + סטטוס
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty) return;

                        final uri = Uri.parse('${Config.baseUrl}/patients/by-email?email=$email');
                        final response = await http.get(uri);

                        if (response.statusCode == 200) {
                          final data = jsonDecode(response.body);
                          setState(() {
                            found = true;
                            patientId = data['_id'];
                          });
                        } else {
                          setState(() {
                            found = false;
                            patientId = null;
                          });
                        }
                      },
                      child: const Text(
                        "Search",
                        style: TextStyle(
                          color: Color(0xFF208686),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    if (found != null)
                      Row(
                        children: [
                          Icon(
                            found! ? Icons.check_circle : Icons.error,
                            color: found! ? Colors.green : Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            found! ? "Found" : "Not found",
                            style: TextStyle(
                              color: found! ? Colors.green : Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                if (found == true)
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text("Add", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF208686),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () async {
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        final caregiverId = auth.role?['_id'];
                        final token = auth.token;

                        final response = await http.post(
                          Uri.parse('${Config.baseUrl}/caregivers/add-patient'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer $token',
                          },
                          body: jsonEncode({
                            'caregiverId': caregiverId,
                            'patientId': patientId,
                          }),
                        );

                        if (response.statusCode == 200) {
                          Navigator.pop(context);
                          fetchPatients();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("✅ Patient added")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("❌ Failed to add patient")),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}
