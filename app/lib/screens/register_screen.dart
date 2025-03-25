import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final String role; // תפקיד שהועבר מהמסך הקודם (מטפל או מטופל)

  const RegisterScreen({required this.role});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _relationController = TextEditingController(); // Relation למטפל
  final TextEditingController _experienceController = TextEditingController(); // ניסיון למטפל
  final TextEditingController _ageController = TextEditingController(); // גיל למטופל
  final TextEditingController _medicalHistoryController = TextEditingController(); // מחלות רקע למטופל

  // פונקציה לבניית שדות הרשמה לפי תפקיד
  Widget _buildAdditionalFields() {
    if (widget.role == 'caregiver') {
      // שדות למטפל
      return Column(
        children: [
          TextField(
            controller: _relationController, // שדה הקשר למטופל
            decoration: const InputDecoration(
              labelText: 'Relation to Patient',
              hintText: 'Enter your relation to the patient',
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: _experienceController, // שדה שנות ניסיון
            decoration: const InputDecoration(
              labelText: 'Experience (Years)',
              hintText: 'Enter your years of experience',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    } else if (widget.role == 'patient') {
      // שדות למטופל
      return Column(
        children: [
          TextField(
            controller: _ageController, // שדה גיל
            decoration: const InputDecoration(
              labelText: 'Age',
              hintText: 'Enter your age',
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: _medicalHistoryController, // שדה מחלות רקע
            decoration: const InputDecoration(
              labelText: 'Medical History',
              hintText: 'Enter any medical background',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    } else {
      // לא נבחר תפקיד, לא מציגים שדות
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // שדות משותפים לכולם
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // שדות נוספים לפי התפקיד שנבחר
            _buildAdditionalFields(),

            const SizedBox(height: 20),

            // כפתור הרשמה
            ElevatedButton(
              onPressed: () {
                // הוספת לוגיקה לשמירת הנתונים
                print('Name: ${_nameController.text}');
                print('Username: ${_usernameController.text}');
                print('Password: ${_passwordController.text}');
                print('Role: ${widget.role}');
                if (widget.role == 'caregiver') {
                  print('Relation: ${_relationController.text}');
                  print('Experience: ${_experienceController.text}');
                  // הוסף פעולות רישום נוספות עבור מטפל
                } else if (widget.role == 'patient') {
                  print('Age: ${_ageController.text}');
                  print('Medical History: ${_medicalHistoryController.text}');
                  // הוסף פעולות רישום נוספות עבור מטופל
                }
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
