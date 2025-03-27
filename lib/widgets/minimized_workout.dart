// lib/widgets/minimized_workout.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Import für ImageFilter
import '../providers/workout_provider.dart';

class MinimizedWorkout extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onEnd;

  const MinimizedWorkout({
    Key? key,
    required this.onResume,
    required this.onEnd,
  }) : super(key: key);

  // Helper: Timer-Zeit formatieren
  String _formatTime(int seconds) {
    if (seconds <= 0) return "0:00";

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        final exerciseName = state.currentExercise?.name ?? 'Workout';
        final dayName = state.currentDay?.name ?? '';

        // Berechne Fortschritt basierend auf geloggten Sets
        int totalSets = 0;
        int completedSets = 0;

        if (state.currentDay != null) {
          for (var exercise in state.currentDay!.exercises) {
            totalSets += exercise.sets;
            final loggedSets = state.workoutLog
                .where((log) => log.exerciseId == exercise.id)
                .length;
            completedSets += loggedSets;
          }
        }

        double progressPercentage =
            totalSets > 0 ? completedSets / totalSets : 0.0;
        final bool timerActive = state.showRestTimer;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 0.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onResume();
                      },
                      splashColor: Colors.white.withOpacity(0.1),
                      highlightColor: Colors.white.withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            // Timer or Workout icon
                            timerActive
                                ? ValueListenableBuilder<int>(
                                    valueListenable: state.timerNotifier,
                                    builder: (context, timeValue, _) {
                                      return _buildTimerIndicator(timeValue);
                                    },
                                  )
                                : _buildWorkoutIndicator(progressPercentage),

                            SizedBox(width: 12),

                            // Exercise info
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exerciseName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    timerActive
                                        ? 'Satzpause läuft'
                                        : dayName.isNotEmpty
                                            ? dayName
                                            : '${(progressPercentage * 100).toInt()}% abgeschlossen',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Action buttons
                            Row(
                              children: [
                                // Resume button with text
                                OutlinedButton(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    onResume();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    minimumSize: Size(0, 0),
                                  ),
                                  child: Text('Öffnen',
                                      style: TextStyle(fontSize: 12)),
                                ),

                                SizedBox(width: 8),

                                // End button - more subtle
                                IconButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    onEnd();
                                  },
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 18,
                                  ),
                                  splashRadius: 20,
                                  padding: EdgeInsets.all(4),
                                  constraints: BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Modernerer Timer-Indikator
  Widget _buildTimerIndicator(int remainingSeconds) {
    final Color timerColor = remainingSeconds <= 0
        ? Colors.redAccent
        : remainingSeconds < 5
            ? Colors.amber
            : Colors.blue;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular progress
          CircularProgressIndicator(
            value: remainingSeconds <= 0 ? 1 : remainingSeconds / 150,
            strokeWidth: 2,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(timerColor),
          ),

          // Timer text
          Text(
            _formatTime(remainingSeconds),
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Workout-Icon mit Fortschrittsanzeige
  Widget _buildWorkoutIndicator(double progress) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular progress for completion
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 2,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),

          // Icon
          Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }
}
