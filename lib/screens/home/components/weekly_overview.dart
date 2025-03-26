// lib/screens/home/components/weekly_overview.dart
import 'package:flutter/material.dart';

class WeeklyOverview extends StatelessWidget {
  const WeeklyOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THIS WEEK',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Color(0xFF14253D),
              border: Border.all(
                color: Color(0xFF2E4865),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final isToday = index + 1 == today.weekday;
                final isPast = index + 1 < today.weekday;

                return Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday ? Color(0xFF2196F3) : Colors.transparent,
                        border: isToday
                            ? null
                            : Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                      ),
                      child: Center(
                        child: Text(
                          days[index],
                          style: TextStyle(
                            color: isToday
                                ? Colors.white
                                : Colors.white.withOpacity(isPast ? 0.5 : 0.8),
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      (startOfWeek.day + index).toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isToday
                            ? Colors.white
                            : Colors.white.withOpacity(isPast ? 0.5 : 0.8),
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
