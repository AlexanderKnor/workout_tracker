// lib/screens/workout/components/workout_completed_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WorkoutCompletedCard extends StatelessWidget {
  final VoidCallback onFinishWorkout;

  const WorkoutCompletedCard({
    Key? key,
    required this.onFinishWorkout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: Color(0xFF14253D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Color(0xFF44CF74).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Success icon
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF44CF74).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Color(0xFF44CF74),
                size: 48,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Workout completed! 🎉',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF44CF74),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'All sets have been successfully logged.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onFinishWorkout();
              },
              icon: Icon(Icons.check, size: 18),
              label: Text('FINISH WORKOUT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF44CF74),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
