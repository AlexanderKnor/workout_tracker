// lib/screens/workout/components/workout_header.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/models.dart';

class WorkoutHeader extends StatelessWidget {
  final bool showElevation;
  final VoidCallback onBackPressed;
  final TrainingPlan? currentPlan;
  final TrainingDay? currentDay;

  const WorkoutHeader({
    Key? key,
    required this.showElevation,
    required this.onBackPressed,
    required this.currentPlan,
    required this.currentDay,
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
          // Back button
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
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

          // Title - centered with Expanded
          Expanded(
            child: Column(
              children: [
                Text(
                  "ACTIVE WORKOUT",
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

          // Spacer for balance
          SizedBox(width: 40),
        ],
      ),
    );
  }
}
