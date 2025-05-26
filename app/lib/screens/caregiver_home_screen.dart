import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../providers/auth_provider.dart';
import '../widgets/medication_card.dart';
import '../widgets/weekday_selector.dart';
import 'caregiver_profile.dart';   

class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  List<dynamic> patients = [];
  dynamic selectedPatient;
  List<dynamic> medications = [];
  String selectedDay = DateTime.now().weekday == 7
      ? 'Sunday'
      : [
          'Monday', 'Tuesday', 'Wednesday',
          'Thursday', 'Friday', 'Saturday',
        ][DateTime.now().weekday - 1];

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }
  


Future<void> fetchPatients() async {
  final auth = Provider.of<AuthProvider>(context, listen: false);
  final caregiverId = auth.role?['_id'];
  final token = auth.token;

  if (caregiverId == null || token == null) return;

  final response = await http.get(
    Uri.parse('${Config.baseUrl}/caregivers/patients/$caregiverId'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> rawPatients = jsonDecode(response.body);
    print("patients are: ${rawPatients}");

    // טען לכל מטופל את פרטי היוזר שלו
    final List<dynamic> enrichedPatients = [];

    for (var patient in rawPatients) {
      final patientId = patient['_id'];
      final userResponse = await http.get(
        Uri.parse('${Config.baseUrl}/patients/$patientId/user'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (userResponse.statusCode == 200) {
        final userData = jsonDecode(userResponse.body);
        enrichedPatients.add({
          '_id': patientId,
          'name': userData['name'],
        });
      } else {
        enrichedPatients.add({
          '_id': patientId,
          'name': 'Unknown',
        });
      }
    }

    setState(() {
      patients = enrichedPatients;
    });
  }
}


  Future<void> fetchMedicationsForPatient() async {
    if (selectedPatient == null) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/medications/patient/${selectedPatient['_id']}/day/$selectedDay'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        medications = jsonDecode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final mainColor = const Color(0xFF208686);
    final username = auth.user?['name'] ?? "Caregiver";


    return Scaffold(
  backgroundColor: const Color(0xFFCEEAF5),
    appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    automaticallyImplyLeading: false,     // מבטל חץ חזור
    titleSpacing: 16,
    title: Row(
      children: [
        Text(
          'Welcome, ${username}!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF208686),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.person, color: Color(0xFF208686)),
onPressed: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const CaregiverProfileScreen(),
    ),
  );
  await fetchPatients(); // רענון הנתונים לאחר החזרה מהפרופיל
  // אם כבר נבחר מטופל, רענני גם את התרופות
  if (selectedPatient != null) {
    await fetchMedicationsForPatient();
  }
},

        ),
        const SizedBox(width: 4),
        Image.asset(
          'assets/images/welcome.png',
          width: 36,
          height: 36,
        ),
      ],
    ),
  ),
  body: SafeArea(

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<dynamic>(
                isExpanded: true,
                hint: const Text('Select a patient:'),
                value: selectedPatient,
                items: patients.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(p['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPatient = value;
                  });
                  fetchMedicationsForPatient();
                },
              ),
              const SizedBox(height: 16),
              if (selectedPatient != null) ...[
                WeekdaySelector(
                  selectedDay: selectedDay,
                  onDaySelected: (day) {
                    setState(() {
                      selectedDay = day;
                    });
                    fetchMedicationsForPatient();
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Medications for ${selectedPatient['name']} on $selectedDay:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: medications.isEmpty
                      ? const Center(child: Text("No medications"))
                      : ListView.builder(
                          itemCount: medications.length,
                          itemBuilder: (_, i) =>
                              MedicationCard(medication: medications[i]),
                        ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
