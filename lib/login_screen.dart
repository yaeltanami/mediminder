// lib/login_screen.dart
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});  // הוספת key

  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // פונקציה שמבצעת את הפעולה כשלוחצים על כפתור ההתחברות
  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // כאן נוסיף את הלוגיקה לוודא שהמשתמש והסיסמה נכונים
    // לדוגמה, נוכל להציג הודעה אם הם נכונים או לא
    if (username == "test" && password == "password") {
      // במקרה של התחברות מוצלחת, אנחנו פשוט מציגים הודעה
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful!")),
      );
    } else {
      // במקרה של כישלון בהתחברות
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid username or password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // שדה להזנת שם משתמש
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              
              // שדה להזנת סיסמה
              TextField(
                controller: _passwordController,
                obscureText: true, // כדי להסתיר את הסיסמה
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // כפתור התחברות
              ElevatedButton(
                onPressed: _login, // הפונקציה שתופעל בעת לחיצה
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
