// קובץ Flutter משופר לרישום משתמשים לפי תפקיד

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart'; // ייבוא מסך ראשי


class RegisterScreen extends StatefulWidget {
  final String role; // "patient" or "caregiver"
  const RegisterScreen({super.key, required this.role});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> registerUser(String role, Map<String, dynamic> data) async {
    final url = Uri.parse(
        'http://10.100.102.14:5050/api/${role == 'patient' ? 'patients' : 'caregivers'}/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print('✅ Registration successful: $responseData');
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(username: data['name']), // העברת שם המשתמש למסך הבא
        ),
      );
    } else {
      print('❌ Registration failed: ${response.body}');
    }
  }

  Widget _buildAdditionalFields() {
    if (widget.role == 'caregiver') {
      return TextFormField(
        controller: _relationController,
        validator: (value) => value == null || value.isEmpty ? 'Relation is required' : null,
        decoration: const InputDecoration(
          labelText: 'Relation to Patient',
          border: OutlineInputBorder(),
        ),
      );
    } else if (widget.role == 'patient') {
      return TextFormField(
        controller: _ageController,
        keyboardType: TextInputType.number,
        validator: (value) => value == null || value.isEmpty ? 'Birth year is required' : null,
        decoration: const InputDecoration(
          labelText: 'Year of Birth',
          border: OutlineInputBorder(),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  validator: (value) => value == null || !value.contains('@') ? 'Valid email required' : null,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) =>
                      value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
                  decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                _buildAdditionalFields(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final data = {
                        'name': _nameController.text,
                        'email': _emailController.text,
                        'password': _passwordController.text,
                      };

                      if (widget.role == 'caregiver') {
                        data['relation'] = _relationController.text;
                      } else if (widget.role == 'patient') {
                        data['birthDate'] = '${_ageController.text}-01-01';
                      }

                      await registerUser(widget.role, data);
                    }
                  },
                  child: const Text('Register'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
