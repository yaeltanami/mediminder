
import 'package:flutter/material.dart';

class WeekdaySelector extends StatelessWidget {
  final String selectedDay;
  final Function(String) onDaySelected;

  const WeekdaySelector({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  static const List<String> _days = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  String _getLabel(String day) {
    return day.substring(0, 3).toUpperCase();
  }

  String _getNumber(String day) {
    return (_days.indexOf(day) + 1).toString();
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color.fromARGB(255, 32, 134, 134);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _days.map((day) {
          final bool isSelected = day == selectedDay;
          return GestureDetector(
            onTap: () => onDaySelected(day),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? mainColor.withOpacity(0.2) : Colors.white,
                border: isSelected ? Border.all(color: mainColor, width: 2) : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _getNumber(day),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? mainColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getLabel(day),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? mainColor : Colors.black54,
                    ),
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
