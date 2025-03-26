// lib/screens/workout/components/exercise_card/exercise_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/models.dart';
import '../../../../providers/workout_provider.dart';
import 'sets_table.dart';
import 'action_buttons.dart';
import '../../dialogs/strength_calculator_dialog.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise currentExercise;

  const ExerciseCard({
    Key? key,
    required this.currentExercise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        return Container(
          margin: EdgeInsets.only(top: 20, bottom: 16),
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
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise header with target info badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF3D85C6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: Color(0xFF3D85C6),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentExercise.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFF1C2F49),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Target: ${currentExercise.minReps}-${currentExercise.maxReps} reps @ ${currentExercise.targetRIR} RIR',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Track Sets Section - Core focus area
                SizedBox(height: 24),
                Text(
                  'TRACK SETS',
                  style: TextStyle(
                    color: Color(0xFF3D85C6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 12),

                // Sets table component
                SetsTable(
                  exercise: currentExercise,
                ),

                SizedBox(height: 24),

                // Action buttons component
                ActionButtons(
                  isSmallScreen: isSmallScreen,
                  onCalculatorPressed: () {
                    state.safeOpenStrengthCalculator();
                    showDialog(
                      context: context,
                      builder: (context) => StrengthCalculatorDialog(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
