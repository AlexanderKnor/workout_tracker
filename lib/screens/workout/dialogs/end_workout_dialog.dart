// lib/screens/workout/dialogs/end_workout_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/workout_provider.dart';

class EndWorkoutDialog extends StatelessWidget {
  final VoidCallback onSaveAndFinish;
  final VoidCallback onDiscardAndFinish;

  const EndWorkoutDialog({
    Key? key,
    required this.onSaveAndFinish,
    required this.onDiscardAndFinish,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        // Überprüfen, ob bereits Sets geloggt wurden
        bool hasLoggedSets = state.workoutLog.isNotEmpty;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Color(0xFF1C2F49),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF95738).withOpacity(0.2),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: Color(0xFFF95738),
                  size: 28,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Workout beenden?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasLoggedSets
                    ? 'Möchtest du das Workout beenden? Du hast bereits Sets geloggt.'
                    : 'Möchtest du das Workout beenden? Du hast noch keine Sets geloggt.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              if (hasLoggedSets) ...[
                // Wenn Sets geloggt wurden, Optionen anzeigen
                ElevatedButton(
                  onPressed: onSaveAndFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF44CF74),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 0),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('SPEICHERN UND BEENDEN'),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onDiscardAndFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF95738),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 0),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('VERWERFEN UND BEENDEN'),
                ),
              ] else ...[
                // Wenn keine Sets geloggt wurden, nur eine Beenden-Option anzeigen
                ElevatedButton(
                  onPressed: onDiscardAndFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF95738),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 0),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('WORKOUT BEENDEN'),
                ),
              ],
              SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withOpacity(0.7),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  minimumSize: Size(double.infinity, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                ),
                child: Text('ABBRECHEN'),
              ),
            ],
          ),
        );
      },
    );
  }
}
