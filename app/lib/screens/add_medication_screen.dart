import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config.dart';
import 'package:flutter/services.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final List<Map<String, dynamic>> _times = [];

  final Map<String, bool> _days = {
    'Sunday': false,
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
  };

  String? _daysError;

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  void _addTimeField() {
    setState(() {
      _times.add({'time': '', 'pillsCount': ''});
    });
  }

  Future<void> _submitForm() async {
    setState(() => _daysError = null);

    if (!_formKey.currentState!.validate()) return;

    final selectedDays =
        _days.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    if (selectedDays.isEmpty) {
      setState(() {
        _daysError = 'Please select at least one day';
      });
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = authProvider.token;
    // final String? userId = authProvider.user?['_id'];

    final String? patientId = authProvider.role?['_id'];

    if (patientId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: User not logged in.")),
      );
      return;
    }

    final List<Map<String, dynamic>> formattedTimes =
        _times
            .where(
              (entry) =>
                  entry['time'].isNotEmpty && entry['pillsCount'].isNotEmpty,
            )
            .map(
              (entry) => {
                'time': entry['time'],
                'pillsCount': int.parse(entry['pillsCount']),
              },
            )
            .toList();

    if (formattedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one time entry.")),
      );
      return;
    }

    final medicationData = {
      'patientId': patientId,
      'name': _nameController.text,
      'dose': _doseController.text,
      'times': formattedTimes,
      'days': selectedDays,
    };

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/medications/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(medicationData),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        showSlotDialog(_nameController.text, responseBody['slotNumber']);
      } else {
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseBody['message']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  void showSlotDialog(String medicationName, int slotNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Medication Added",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF208686),
            ),
          ),
          content: Text(
            "Please insert '$medicationName' into slot number $slotNumber.",
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Medication added successfully!'),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text(
                "OK",
                style: TextStyle(fontSize: 16, color: Color(0xFF208686)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCEECF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Add Medication',
          style: TextStyle(color: Color(0xFF208686)),
        ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                _nameController,
                'Medication Name',
                'Enter medication name',
              ),
              const SizedBox(height: 16),
              _buildTextField(_doseController, 'Dose', 'e.g. 500mg'),
              const SizedBox(height: 24),
              const Text(
                'Times of the day',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Column(
                children:
                    _times.asMap().entries.map((entry) {
                      int index = entry.key;
                      return Row(
                        children: [
                          Expanded(
                            child: _buildTimeField(
                              _times[index]['time'],
                              (value) => _times[index]['time'] = value,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildNumberField(
                              _times[index]['pillsCount'],
                              (value) => _times[index]['pillsCount'] = value,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _times.removeAt(index);
                              });
                            },
                          ),
                        ],
                      );
                    }).toList(),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF208686),
                  foregroundColor: Colors.white,
                ),
                onPressed: _addTimeField,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add Time',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Days of the week',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _days.updateAll((key, value) => true);
                      });
                    },
                    child: const Text(
                      'Select All',
                      style: TextStyle(color: Color(0xFF208686)),
                    ),
                  ),
                ],
              ),
              Column(
                children:
                    _days.keys.map((day) {
                      return CheckboxListTile(
                        title: Text(day),
                        value: _days[day],
                        onChanged: (value) {
                          setState(() {
                            _days[day] = value ?? false;
                          });
                        },
                      );
                    }).toList(),
              ),
              if (_daysError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 10),
                  child: Text(
                    _daysError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF208686),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _submitForm,
                  child: const Text(
                    'Save Medication',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildTimeField(String initialValue, Function(String) onChanged) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.datetime,
      decoration: const InputDecoration(
        labelText: 'Time (HH:MM)',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null ||
            !RegExp(r'^(?:[01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
          return 'Enter a valid time';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  Widget _buildNumberField(String initialValue, Function(String) onChanged) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Pills',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        final intVal = int.tryParse(value);
        if (intVal == null || intVal <= 0) return 'Enter a valid number > 0';
        return null;
      },
      onChanged: onChanged,
    );
  }
}
