import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../config.dart';

class CaregiversScreen extends StatefulWidget {
  const CaregiversScreen({super.key});

  @override
  State<CaregiversScreen> createState() => _CaregiversScreenState();
}

class _CaregiversScreenState extends State<CaregiversScreen> {
  List<dynamic> caregivers = [];

  @override
  void initState() {
    super.initState();
    fetchCaregivers();
  }

  Future<void> fetchCaregivers() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final patientId = authProvider.role?['_id'];
    final token = authProvider.token;

    if (patientId == null || token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/patients/caregivers/$patientId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          caregivers = jsonDecode(response.body);
        });
      } else {
        print("Failed to fetch caregivers");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFF208686);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Caregivers'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF208686)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset('assets/images/welcome.png', width: 40, height: 40),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 230, 241, 244),
      body: caregivers.isEmpty
          ? const Center(child: Text("No caregivers found."))
          : ListView.builder(
              itemCount: caregivers.length,
              itemBuilder: (context, index) {
                final caregiver = caregivers[index];
                return ListTile(
                  title: Text(caregiver['name']),
                  subtitle: Text(caregiver['email']),
                  leading: const Icon(Icons.person),
                );
              },
            ),
    );
  }
}
