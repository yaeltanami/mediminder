import 'package:flutter/material.dart';

/// כרטיס להצגת פרטי תרופה אחת (שם, מינון, שעות נטילה)
/// משמש ברשימת התרופות במסך הבית
class MedicationCard extends StatelessWidget {
  final Map<String, dynamic> medication; // אובייקט תרופה שהתקבל מהשרת

  const MedicationCard({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    // עיבוד רשימת זמני הנטילה לפורמט  – "08:00 (2 pills), 20:00 (1 pills)"
    final times = (medication['times'] as List)
        .map((t) => '${t['time']} (${t['pillsCount']} pills)')
        .join(', ');

    return Card(
      elevation: 2, 
      child: ListTile(
        leading: const Icon(Icons.medication), // אייקון קבוע של תרופה
        title: Text(medication['name']), // שם התרופה
        subtitle: Text('Dose: ${medication['dose']}\nTimes: $times'), // מידע נוסף: מינון + שעות
      ),
    );
  }
}
