import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // נייבא את AuthProvider
import 'add_medication_screen.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'dart:convert';




// ... (imports כמו אצלך בדיוק)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedDay = 'Sunday';
  List<dynamic> medications = [];

  @override
  void initState() {
    super.initState();
    fetchMedicationsForDay();
  }

  Future<void> fetchMedicationsForDay() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final patientId = authProvider.user?['_id'];
    final token = authProvider.token;

    if (patientId == null || token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/medications/patient/$patientId/day/$selectedDay'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          medications = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('❌ Error fetching medications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final username = authProvider.user?['name'] ?? "Guest";

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddMedicationScreen()));
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ברכת ברוכים הבאים
              Text(
                'Welcome, $username',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Today',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // תצוגת ימים עם בחירה
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _dayList.map((day) {
                    final isSelected = day == selectedDay;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceChip(
                        label: Text(day.substring(0, 3).toUpperCase()),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => selectedDay = day);
                          fetchMedicationsForDay();
                        },
                        selectedColor: Colors.blue.shade200,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // עיגול גדול - מספר תרופות ליום
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.medication, size: 30, color: Colors.orange),
                      const SizedBox(height: 8),
                      Text(
                        '0/${medications.length}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedDay,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Today\'s Medications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: medications.isEmpty
                    ? const Center(child: Text("No medications for this day."))
                    : ListView.builder(
                        itemCount: medications.length,
                        itemBuilder: (context, index) {
                          final med = medications[index];
                          final times = (med['times'] as List)
                              .map((t) => '${t['time']} (${t['pillsCount']} pills)')
                              .join(', ');

                          return Card(
                            elevation: 2,
                            child: ListTile(
                              leading: const Icon(Icons.medication),
                              title: Text(med['name']),
                              subtitle: Text('Dose: ${med['dose']}\nTimes: $times'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> get _dayList => const [
        'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
      ];
}
