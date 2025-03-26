// lib/screens/workout/components/exercise_card/action_buttons.dart
import 'package:flutter/material.dart';
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

        return isSmallScreen
            ? _buildVerticalButtons(
                context, state, isLastSetOfExercise, isCurrentSetCompleted)
            : _buildHorizontalButtons(
                context, state, isLastSetOfExercise, isCurrentSetCompleted);
      },
    );
  }

  // Vertical layout for action buttons on small screens
  Widget _buildVerticalButtons(BuildContext context, WorkoutTrackerState state,
      bool isLastSetOfExercise, bool isCurrentSetCompleted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: isCurrentSetCompleted
              ? (isLastSetOfExercise ? state.safeMoveToNextExercise : null)
              : state.safeLogCurrentSet,
          icon: Icon(
              isCurrentSetCompleted && isLastSetOfExercise
                  ? Icons.check_circle
                  : Icons.check,
              size: 18),
          label: Text(isCurrentSetCompleted && isLastSetOfExercise
              ? 'Complete Exercise'
              : 'Log Set'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrentSetCompleted && isLastSetOfExercise
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
        ElevatedButton.icon(
          onPressed: onCalculatorPressed,
          icon: Icon(Icons.calculate, size: 18),
          label: Text('Calculator'),
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
      bool isCurrentSetCompleted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: onCalculatorPressed,
          icon: Icon(Icons.calculate, size: 18),
          label: Text('Calculator'),
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
        ElevatedButton.icon(
          onPressed: isCurrentSetCompleted
              ? (isLastSetOfExercise ? state.safeMoveToNextExercise : null)
              : state.safeLogCurrentSet,
          icon: Icon(
              isCurrentSetCompleted && isLastSetOfExercise
                  ? Icons.check_circle
                  : Icons.check,
              size: 18),
          label: Text(isCurrentSetCompleted && isLastSetOfExercise
              ? 'Complete Exercise'
              : 'Log Set'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrentSetCompleted && isLastSetOfExercise
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
