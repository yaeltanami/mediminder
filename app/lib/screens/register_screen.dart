import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import '../config.dart';

class RegisterScreen extends StatefulWidget {
  final String role; // מטפל או מטופל

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

  /// פונקציה לרישום משתמש חדש בשרת
  Future<void> registerUser() async {
    final url = Uri.parse('${Config.baseUrl}/${widget.role == 'patient' ? 'patients' : 'caregivers'}/register',
    );

    final Map<String, dynamic> requestData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    if (widget.role == 'caregiver') {
      requestData['relation'] = _relationController.text;
    } else if (widget.role == 'patient') {
      requestData['birthDate'] = '${_ageController.text}-01-01'; // קלט שנת לידה בלבד
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('✅ Registration successful: $responseData');

        // שמירת נתוני המשתמש ב-Provider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setUser(responseData['user']); // שמירת פרטי המשתמש
        authProvider.setToken(responseData['token']); // שמירת הטוקן

        // מעבר למסך הבית
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        print('❌ Registration failed: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration failed. Please try again.")),
        );
      }
    } catch (error) {
      print("❌ Error registering user: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  /// בניית שדות ייחודיים לפי תפקיד (מטופל או מטפל)
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
    }
    return Container(); // אם אין תפקיד מוגדר
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
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  validator: (value) => value == null || !value.contains('@') ? 'Valid email required' : null,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                _buildAdditionalFields(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await registerUser();
                    }
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
