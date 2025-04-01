import 'package:flutter/material.dart';

/// ווידג'ט להצגת שורת ימים לבחירה (Sunday–Saturday)
/// מאפשר למשתמש לבחור יום, ומעדכן את המצב במסך ההורה (למשל HomeScreen)
class WeekdaySelector extends StatelessWidget {
  final String selectedDay; // היום שנבחר כרגע (מהמסך הראשי)
  final Function(String) onDaySelected; // פונקציה שמתבצעת כשנלחץ יום אחר

  const WeekdaySelector({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  // רשימת כל הימים בשבוע לפי סדר
  static const List<String> _days = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  // החזרת קיצור ליום – לדוגמה 'MON' במקום 'Monday'
  String _getLabel(String day) {
    switch (day) {
      case 'Sunday': return 'SUN';
      case 'Monday': return 'MON';
      case 'Tuesday': return 'TUE';
      case 'Wednesday': return 'WED';
      case 'Thursday': return 'THU';
      case 'Friday': return 'FRI';
      case 'Saturday': return 'SAT';
      default: return '';
    }
  }

  // החזרת מספר סידורי ליום (Sunday = 1, Monday = 2, ...)
  String _getNumber(String day) {
    return (_days.indexOf(day) + 1).toString();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _days.map((day) {
          final bool isSelected = day == selectedDay; // בודק אם זה היום הנבחר
          return GestureDetector(
            onTap: () => onDaySelected(day), // כשנלחץ – מפעיל את הפונקציה מהמסך ההורה
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _getNumber(day), // מספר סידורי של היום
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getLabel(day), // קיצור של היום
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
