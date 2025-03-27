// lib/screens/workout/components/exercise_card/action_buttons.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/workout_provider.dart';

class ActionButtons extends StatelessWidget {
  final bool isSmallScreen;
  final VoidCallback onCalculatorPressed;

  const ActionButtons({
    Key? key,
    required this.isSmallScreen,
    required this.onCalculatorPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        bool isLastSetOfExercise =
            state.currentSetIndex == state.currentExerciseSets.length - 1;
        bool isCurrentSetCompleted =
            state.currentSetIndex < state.currentExerciseSets.length &&
                state.currentExerciseSets[state.currentSetIndex].completed;

        // Check if this is the last exercise AND all sets are completed
        bool isAllDone = state.isAllExercisesCompleted;
        bool isLastExercise = state.isLastExercise;

        return isSmallScreen
            ? _buildVerticalButtons(context, state, isLastSetOfExercise,
                isCurrentSetCompleted, isAllDone, isLastExercise)
            : _buildHorizontalButtons(context, state, isLastSetOfExercise,
                isCurrentSetCompleted, isAllDone, isLastExercise);
      },
    );
  }

  // Vertical layout for action buttons on small screens
  Widget _buildVerticalButtons(
      BuildContext context,
      WorkoutTrackerState state,
      bool isLastSetOfExercise,
      bool isCurrentSetCompleted,
      bool isAllDone,
      bool isLastExercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main action button (Log, Complete, or Finish)
        ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (isCurrentSetCompleted) {
              // Wir checken jetzt, ob alle Übungen abgeschlossen sind
              if (isAllDone) {
                state.finishWorkout();
              } else {
                // Die moveToNextExercise-Methode wird zur nächsten unvollständigen Übung wechseln
                state.safeMoveToNextExercise();
              }
            } else {
              state.safeLogCurrentSet();
            }
          },
          icon: Icon(
              isCurrentSetCompleted && isAllDone
                  ? Icons.check_circle
                  : Icons.check,
              size: 18),
          label: Text(
            isCurrentSetCompleted && isAllDone
                ? 'Finish Workout'
                : isCurrentSetCompleted && isLastSetOfExercise
                    ? 'Complete Exercise'
                    : 'Log Set',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrentSetCompleted && isAllDone
                ? Color(0xFF44CF74)
                : Color(0xFF3D85C6),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
        SizedBox(height: 12),

        // Calculator button
        ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.selectionClick();
            onCalculatorPressed();
          },
          icon: Icon(Icons.calculate, size: 18),
          label: Text(
            'Calculator',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1C2F49),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  // Horizontal layout for action buttons on larger screens
  Widget _buildHorizontalButtons(
      BuildContext context,
      WorkoutTrackerState state,
      bool isLastSetOfExercise,
      bool isCurrentSetCompleted,
      bool isAllDone,
      bool isLastExercise) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Calculator button
        ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.selectionClick();
            onCalculatorPressed();
          },
          icon: Icon(Icons.calculate, size: 18),
          label: Text(
            'Calculator',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1C2F49),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            elevation: 0,
          ),
        ),

        // Main action button (Log, Complete, or Finish)
        ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (isCurrentSetCompleted) {
              // Wir checken jetzt, ob alle Übungen abgeschlossen sind
              if (isAllDone) {
                state.finishWorkout();
              } else {
                // Die moveToNextExercise-Methode wird zur nächsten unvollständigen Übung wechseln
                state.safeMoveToNextExercise();
              }
            } else {
              state.safeLogCurrentSet();
            }
          },
          icon: Icon(
              isCurrentSetCompleted && isAllDone
                  ? Icons.check_circle
                  : Icons.check,
              size: 18),
          label: Text(
            isCurrentSetCompleted && isAllDone
                ? 'Finish Workout'
                : isCurrentSetCompleted && isLastSetOfExercise
                    ? 'Complete Exercise'
                    : 'Log Set',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrentSetCompleted && isAllDone
                ? Color(0xFF44CF74)
                : Color(0xFF3D85C6),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}
