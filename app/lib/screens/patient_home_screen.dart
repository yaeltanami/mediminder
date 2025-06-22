import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/auth_provider.dart';
import '../config.dart';
import '../widgets/weekday_selector.dart';
import '../widgets/medication_card.dart';
import '../navigation_observer.dart';

import 'profile_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> with RouteAware {

  String selectedDay =
      DateTime.now().weekday == 7
          ? 'Sunday'
          : [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
          ][DateTime.now().weekday - 1];

  List<dynamic> medications = []; 
  List<dynamic> takenLogs = [];
  int totalIntakeCount = 0;

  @override
  @override
  void initState() {
    super.initState();
    fetchMedicationsForDay();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
    fetchMedicationsForDay(); 
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    fetchMedicationsForDay();
  }

  Future<void> fetchMedicationsForDay() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final patientId = authProvider.role?['_id'];
    final token = authProvider.token;
    final date = DateTime.now().toIso8601String().split('T').first;

    if (patientId == null || token == null) return;

    try {
      final medsResponse = await http.get(
        Uri.parse(
          '${Config.baseUrl}/medications/patient/$patientId/day/$selectedDay',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      final logsResponse = await http.get(
        Uri.parse('${Config.baseUrl}/medicationLog/$patientId/$date'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (medsResponse.statusCode == 200) {
        final medsData = jsonDecode(medsResponse.body);
        if (mounted) {
          setState(() {
            medications = medsData['medications'];
            totalIntakeCount = medsData['totalIntakeCount'];
          });
        }
      }

      if (logsResponse.statusCode == 200) {
        if (mounted) {
          setState(() {
            takenLogs = jsonDecode(logsResponse.body);
          });
        }
      }
    } catch (e) {
      print('❌ Error fetching medications or logs: $e');
    }
  }

  bool isTodaySelected() {
    final today =
        DateTime.now().weekday == 7
            ? 'Sunday'
            : [
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday',
            ][DateTime.now().weekday - 1];

    return selectedDay == today;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final username = authProvider.user?['name'] ?? "Guest";
    final Color mainColor = const Color.fromARGB(255, 32, 134, 134);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 241, 244),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome, $username',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFB2D8D8), 
                          border: Border.all(
                            color: Color(0xFF208686),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                              fetchMedicationsForDay();
                            },
                            child: const Icon(
                              Icons.person,
                              size: 20,
                              color: Color(0xFF208686),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/images/welcome.png',
                        width: 50,
                        height: 50,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  selectedDay,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              WeekdaySelector(
                selectedDay: selectedDay,
                onDaySelected: (day) {
                  setState(() {
                    selectedDay = day;
                  });
                  fetchMedicationsForDay();
                },
              ),
              const SizedBox(height: 32),

              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border:
                        (isTodaySelected() &&
                                takenLogs.length == totalIntakeCount)
                            ? Border.all(color: Colors.green, width: 8)
                            : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.center, 

                      children: [
                        const Icon(
                          Icons.medication,
                          size: 30,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 8),
                        isTodaySelected()
                            ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Taken',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: mainColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${takenLogs.length}/${totalIntakeCount}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                            : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$totalIntakeCount',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'medications',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: mainColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),

                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

        
              const SizedBox(height: 10),
              Expanded(
                child:
                    medications.isEmpty
                        ? const Text("No medications for this day.")
                        : ListView.builder(
                          itemCount: medications.length,
                          itemBuilder: (context, index) {
                            return MedicationCard(
                              medication: medications[index],
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
}
