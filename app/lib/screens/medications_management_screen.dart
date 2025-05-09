import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../config.dart';
import '../providers/auth_provider.dart';
import 'add_medication_screen.dart';

class MedicationsManagementScreen extends StatefulWidget {
  const MedicationsManagementScreen({super.key});

  @override
  State<MedicationsManagementScreen> createState() => _MedicationsManagementScreenState();
}

class _MedicationsManagementScreenState extends State<MedicationsManagementScreen> {
  List<dynamic> medications = [];

  @override
  void initState() {
    super.initState();
    fetchMedications();
  }

  Future<bool> updateMedication(String id, List times, List days) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token ?? '';
    try {
      final response = await http.put(
        Uri.parse('${Config.baseUrl}/medications/update/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'times': times, 'days': days}),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("Error updating medication: $e");
    }
    return false;
  }

  Future<void> fetchMedications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final patientId = authProvider.role?['_id'];
    final token = authProvider.token;

    if (patientId == null || token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/medications/patient/$patientId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          medications = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print("Error fetching medications: $e");
    }
  }

  Future<void> deleteMedication(String id) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token ?? '';
    try {
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/medications/delete/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (e) {
      print("Error deleting medication: $e");
    }
  }

  void showEditDialog(BuildContext context, Map med) {
    List times = List.from(med['times']);
    List days = List.from(med['days'] ?? []);
    String? errorText;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text("Edit ${med['name']}"),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...times.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      return Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: item['time'],
                              decoration: const InputDecoration(labelText: 'Time'),
                              onChanged: (value) => times[idx]['time'] = value,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: item['pillsCount'].toString(),
                              decoration: const InputDecoration(labelText: 'Pills'),
                              keyboardType: TextInputType.number,
                              onChanged: (value) => times[idx]['pillsCount'] = int.tryParse(value),
                            ),
                          ),
                          if (times.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  times.removeAt(idx);
                                });
                              },
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          times.add({'time': '', 'pillsCount': 1});
                        });
                      },
                      child: const Text("+ Add Time"),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Days:"),
                        ...['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
                            .map((day) => CheckboxListTile(
                                  title: Text(day),
                                  value: days.contains(day),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        days.add(day);
                                      } else {
                                        days.remove(day);
                                      }
                                    });
                                  },
                                ))
                      ],
                    ),
                    if (errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          errorText!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  await deleteMedication(med['_id']);
                  Navigator.of(context).pop();
                  fetchMedications();
                },
              ),
              ElevatedButton(
                child: const Text("Save"),
                onPressed: () async {
                  bool hasEmptyTime = times.any((t) => t['time'] == null ||
                      !RegExp(r'^(?:[01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(t['time'].toString()));
                  bool hasInvalidPills = times.any((t) =>
                      t['pillsCount'] == null ||
                      t['pillsCount'] is! int ||
                      t['pillsCount'] <= 0);
                  if (hasEmptyTime || hasInvalidPills || days.isEmpty) {
                    setState(() {
                      errorText = "Please fill in valid times, pills > 0 and select at least one day";
                    });
                    return;
                  }
                  bool success = await updateMedication(med['_id'], times, days);
                  if (success) {
                    Navigator.of(context).pop();
                    fetchMedications();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color.fromARGB(255, 32, 134, 134);
    return Scaffold(
      backgroundColor: const Color(0xFFCEECF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Medications',
          style: TextStyle(color: Color(0xFF208686)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF208686)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset('assets/images/welcome.png', width: 40),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final med = medications[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(med['name'] ?? ''),
              subtitle: Text("Dose: ${med['dose']}"),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF208686)),
                onPressed: () => showEditDialog(context, med),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
            );
            fetchMedications();
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add Medication", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
    );
  }
}
