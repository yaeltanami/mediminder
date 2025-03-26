import 'package:flutter/material.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();

  // ימים בשבוע
  final Map<String, bool> _days = {
    'Sunday': false,
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
  };

  // בוקר / צהריים / ערב
  String _selectedTimeOfDay = 'Morning';
  final List<String> _timeOptions = ['Morning', 'Afternoon', 'Evening'];

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final selectedDays = _days.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      final medicationData = {
        'name': _nameController.text,
        'days': selectedDays,
        'timeOfDay': _selectedTimeOfDay,
        'dose': _doseController.text,
      };

      debugPrint('Medication added: $medicationData');

      // אפשר להוסיף כאן ניווט חזרה עם הנתונים או לשמור ברשימה מקומית
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication added')),
      );

      Navigator.pop(context); // חוזר למסך הבית
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // שם התרופה
              const Text(
                'Medication Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter medication name',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a name' : null,
              ),

              const SizedBox(height: 24),

              // ימים בשבוע
              const Text(
                'Days of the week',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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

              const SizedBox(height: 16),

              // זמן ביום
              const Text(
                'Time of day',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTimeOfDay,
                items: _timeOptions.map((time) {
                  return DropdownMenuItem<String>(
                    value: time,
                    child: Text(time),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTimeOfDay = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              // מינון / כמות
              const Text(
                'Dose',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _doseController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 1 capsule',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the dose'
                    : null,
              ),

              const SizedBox(height: 32),

              // כפתור שמירה
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
}
