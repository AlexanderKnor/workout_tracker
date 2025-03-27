// lib/screens/home/components/plan_card/day_item.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../models/models.dart';
import '../../../../providers/workout_provider.dart';

class DayItem extends StatelessWidget {
  final TrainingDay day;
  final Function(TrainingDay) onTap; // Spezifischer Typ für den Callback

  const DayItem({
    Key? key,
    required this.day,
    required this.onTap,
  }) : super(key: key);

  // Neue Methode zum Überprüfen, ob ein Workout gestartet werden kann
  void _handleDayTap(BuildContext context, TrainingDay day) {
    final state = Provider.of<WorkoutTrackerState>(context, listen: false);

    // Wenn bereits ein Workout aktiv ist, zeige eine Warnung
    if (state.isWorkoutActive) {
      // Zeige Snackbar mit Hinweis
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Beende das aktive Workout, bevor du ein neues startest.'),
          backgroundColor: Color(0xFFF95738),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      return;
    }

    // Sonst normal fortsetzten
    HapticFeedback.selectionClick();
    onTap(day);
  }

  @override
  Widget build(BuildContext context) {
    final exercises = day.exercises;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return InkWell(
      onTap: () => _handleDayTap(context, day),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: 12, horizontal: isSmallScreen ? 12 : 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Day indicator
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2E4865),
              ),
              child: Center(
                child: Text(
                  day.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),

            // Day info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${exercises.length} ${exercises.length == 1 ? 'exercise' : 'exercises'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Start button with "Starten" text
            Container(
              // Use constraints to ensure button doesn't overflow
              constraints: BoxConstraints(
                maxWidth: isSmallScreen ? 80 : 90,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF44CF74),
                    Color(0xFF2AAB5A),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF44CF74).withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Starten',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
