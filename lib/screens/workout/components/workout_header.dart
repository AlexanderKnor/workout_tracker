// lib/screens/workout/components/workout_header.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/models.dart';

class WorkoutHeader extends StatelessWidget {
  final bool showElevation;
  final VoidCallback onBackPressed;
  final VoidCallback? onEndPressed; // Neu: Callback für Beenden-Button
  final TrainingPlan? currentPlan;
  final TrainingDay? currentDay;

  const WorkoutHeader({
    Key? key,
    required this.showElevation,
    required this.onBackPressed,
    required this.currentPlan,
    required this.currentDay,
    this.onEndPressed, // Neu: Optional, da in älteren Implementierungen nicht vorhanden
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: BoxDecoration(
        color: showElevation ? Color(0xFF0F1A2A) : Colors.transparent,
        boxShadow: showElevation
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Zurück-Button (jetzt zum Minimieren des Workouts)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onBackPressed();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.remove, // Geändert zu "Minimieren"-Icon
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

          // Titel - zentriert mit Expanded
          Expanded(
            child: Column(
              children: [
                Text(
                  "AKTIVES WORKOUT",
                  style: TextStyle(
                    color: Color(0xFF44CF74),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  currentPlan?.name ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                if (currentDay != null)
                  Text(
                    currentDay!.name,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // NEU: Workout-Beenden-Button
          if (onEndPressed != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onEndPressed!();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF95738).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFFF95738).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Color(0xFFF95738),
                    size: 16,
                  ),
                ),
              ),
            )
          else
            // Platzhalter für die Balance, wenn kein Beenden-Button angezeigt wird
            SizedBox(width: 40),
        ],
      ),
    );
  }
}
