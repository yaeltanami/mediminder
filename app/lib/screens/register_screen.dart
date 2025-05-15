import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import '../config.dart';
import '../services/notifications_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class RegisterScreen extends StatefulWidget {
  final String role;

  const RegisterScreen({super.key, required this.role});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class PatientField {
  final TextEditingController controller;
  bool? isValid;

  PatientField({required this.controller, this.isValid});
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color mainColor = const Color.fromARGB(255, 32, 134, 134);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();

  final List<PatientField> _patientFields = [];

  @override
  void initState() {
    super.initState();
    if (widget.role == 'caregiver') {
      _addPatientField();
    }
  }

  void _addPatientField() {
    setState(() {
      _patientFields.add(PatientField(controller: TextEditingController()));
    });
  }

  Future<void> _validatePatient(int index) async {
    final email = _patientFields[index].controller.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter patient email")),
      );
      return;
    }

    try {
      final uri = Uri.parse('${Config.baseUrl}/patients/by-email?email=$email');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          _patientFields[index].isValid = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Patient found")));
      } else {
        setState(() {
          _patientFields[index].isValid = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("❌ Patient not found")));
      }
    } catch (e) {
      print("❌ Error validating patient: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error checking patient")));
    }
  }

  Future<void> _registerUser() async {
    final role = widget.role;

    final validPatientEmails =
        role == 'caregiver'
            ? _patientFields
                .where((f) => f.isValid == true)
                .map((f) => f.controller.text.trim())
                .toList()
            : [];

    final url = Uri.parse(
      '${Config.baseUrl}/${role == 'patient' ? 'patients' : 'caregivers'}/register',
    );

    final requestData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      if (role == 'caregiver') 'patientsEmails': validPatientEmails,
      if (role == 'patient')
        'birthDate': '${_birthYearController.text.trim()}-01-01',
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setUser(data['user']);
        authProvider.setToken(data['token']);
         await NotificationsService().sendFcmToken(data['token']); 

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Registration failed.")));
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("An error occurred.")));
    }
  }

  Widget _buildPatientFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text('Patients:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ..._patientFields.asMap().entries.map((entry) {
          int index = entry.key;
          PatientField field = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: field.controller,
                    decoration: InputDecoration(
                      labelText: 'Patient Email ${index + 1}',
                      border: const OutlineInputBorder(),
                      suffixIcon:
                          field.isValid == true
                              ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                              : field.isValid == false
                              ? const Icon(Icons.error, color: Colors.red)
                              : null,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Check if patient exists',
                  onPressed: () => _validatePatient(index),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _patientFields.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add Patient'),
            onPressed: _addPatientField,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalFields() {
    if (widget.role == 'caregiver') {
      return _buildPatientFields();
    } else if (widget.role == 'patient') {
      return TextFormField(
        controller: _birthYearController,
        keyboardType: TextInputType.number,
        validator:
            (val) => val == null || val.isEmpty ? "Birth year required" : null,
        decoration: const InputDecoration(
          labelText: 'Year of Birth',
          border: OutlineInputBorder(),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 206, 236, 245),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: mainColor),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 40),
              TextFormField(
                controller: _nameController,
                validator:
                    (val) =>
                        val == null || val.isEmpty ? "Name required" : null,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                validator:
                    (val) =>
                        val == null || !val.contains('@')
                            ? "Valid email required"
                            : null,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator:
                    (val) =>
                        val == null || val.length < 6
                            ? "Min 6 characters"
                            : null,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                validator:
                    (val) =>
                        val != _passwordController.text
                            ? "Passwords do not match"
                            : null,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              _buildAdditionalFields(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _registerUser();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthYearController.dispose();
    for (var field in _patientFields) {
      field.controller.dispose();
    }
    super.dispose();
  }
}
