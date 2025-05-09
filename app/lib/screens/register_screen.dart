/// RegisterScreen
/// מסך רישום עבור מטופלים ומטפלים.
/// כולל אימות שדות, סיסמה עם תנאים, התאמה לתפקיד, עיצוב תואם למסכי האפליקציה.

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import '../config.dart';

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _relationController =
      TextEditingController(); // למטפל
  final TextEditingController _ageController =
      TextEditingController(); // למטופל

  final _formKey = GlobalKey<FormState>();
  final Color mainColor = const Color.fromARGB(255, 32, 134, 134); // צבע אחיד

  Future<void> registerUser() async {
    final url = Uri.parse(
      '${Config.baseUrl}/${widget.role == 'patient' ? 'patients' : 'caregivers'}/register',
    );

    final Map<String, dynamic> requestData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    if (widget.role == 'caregiver') {
      requestData['relation'] = _relationController.text;
    } else if (widget.role == 'patient') {
      requestData['birthDate'] =
          '${_ageController.text}-01-01'; // קלט שנת לידה בלבד
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        Provider.of<AuthProvider>(context, listen: false).setUser(data['user']);
        Provider.of<AuthProvider>(
          context,
          listen: false,
        ).setToken(data['token']);
        if (widget.role == "caregiver") {
          Provider.of<AuthProvider>(
            context,
            listen: false,
          ).setRole(data['caregiver']);
        } else {
              Provider.of<AuthProvider>(
            context,
            listen: false,
          ).setRole(data['patient']);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration failed. Please try again."),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  /// בניית שדה ייחודי לפי סוג המשתמש
  Widget _buildAdditionalFields() {
    if (widget.role == 'caregiver') {
      return TextFormField(
        controller: _relationController,
        validator:
            (value) =>
                value == null || value.isEmpty ? 'Relation is required' : null,
        decoration: const InputDecoration(
          labelText: 'Relation to Patient',
          border: OutlineInputBorder(),
        ),
      );
    } else {
      return TextFormField(
        controller: _ageController,
        keyboardType: TextInputType.number,
        validator:
            (value) =>
                value == null || value.isEmpty
                    ? 'Birth year is required'
                    : null,
        decoration: const InputDecoration(
          labelText: 'Year of Birth',
          border: OutlineInputBorder(),
        ),
      );
    }
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40), // רווח מהחלק העליון
                TextFormField(
                  controller: _nameController,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Name is required'
                              : null,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  validator:
                      (value) =>
                          value == null || !value.contains('@')
                              ? 'Valid email required'
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
                      (value) =>
                          value == null || value.length < 6
                              ? 'Password must be at least 6 characters'
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
                      (value) =>
                          value != _passwordController.text
                              ? 'Passwords do not match'
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await registerUser();
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
      ),
    );
  }
}
