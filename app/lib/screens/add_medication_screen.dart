import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config.dart'; // קובץ שמחזיק את כתובת ה-API
import /'package:flutter/services.dart'; // נדרש בשביל ה- TextInputFormatter

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final List<Map<String, dynamic>> _times = []; // רשימת שעות נטילה

  // ימים בשבוע
  final Map<String, bool> _days = {
    'Sunday': false, 'Monday': false, 'Tuesday': false, 
    'Wednesday': false, 'Thursday': false, 'Friday': false, 'Saturday': false,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  /// הוספת שעת נטילה לרשימה
  void _addTimeField() {
    setState(() {
      _times.add({'time': '', 'pillsCount': ''}); // הוספת זמן ריק עם מספר כדורים ריק
    });
  }

  /// שליחת הנתונים לשרת
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = authProvider.token;
    final String? patientId = authProvider.user?['_id']; // קבלת מזהה המטופל

    if (patientId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: User not logged in.")),
      );
      return;
    }

    final List<String> selectedDays =
        _days.entries.where((entry) => entry.value).map((entry) => entry.key).toList();

    final List<Map<String, dynamic>> formattedTimes = _times
        .where((entry) => entry['time'].isNotEmpty && entry['pillsCount'].isNotEmpty)
        .map((entry) => {
              'time': entry['time'],
              'pillsCount': int.parse(entry['pillsCount'])
            })
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
      'days': selectedDays
    };

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/medications/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(medicationData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication added successfully!')),
        );
        Navigator.pop(context);
      } else {
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseBody['message']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameController, 'Medication Name', 'Enter medication name'),
              const SizedBox(height: 16),
              _buildTextField(_doseController, 'Dose', 'e.g. 500mg'),
              const SizedBox(height: 24),

              const Text('Times of the day', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Column(
                children: _times.asMap().entries.map((entry) {
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
                onPressed: _addTimeField,
                icon: const Icon(Icons.add),
                label: const Text('Add Time'),
              ),

              const SizedBox(height: 24),
              const Text('Days of the week', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Column(
                children: _days.keys.map((day) {
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
              const SizedBox(height: 32),

              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Save Medication'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// שדה להזנת טקסט רגיל
  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()),
      validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  /// שדה להזנת שעה בפורמט HH:MM בלבד
  Widget _buildTimeField(String initialValue, Function(String) onChanged) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.datetime,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}:?\d{0,2}$'))],
      decoration: const InputDecoration(labelText: 'Time (HH:MM)', border: OutlineInputBorder()),
      validator: (value) {
        if (value == null || !RegExp(r'^(?:[01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
          return 'Enter a valid time';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  /// שדה להזנת מספר
  Widget _buildNumberField(String initialValue, Function(String) onChanged) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(labelText: 'Pills', border: OutlineInputBorder()),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      onChanged: onChanged,
    );
  }
}
