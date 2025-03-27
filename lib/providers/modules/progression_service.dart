// lib/providers/modules/progression_service.dart
import 'dart:math';
import '../../models/models.dart';
import 'workout_session.dart';

class ProgressionService {
  final WorkoutSession _workoutSession;
  final Function _notifyListeners;

  // State variables
  ProgressionSuggestion? _progressionSuggestion;
  String _progressionReason = '';

  // Constructor
  ProgressionService(this._workoutSession, this._notifyListeners);

  // ======== Getters ========
  ProgressionSuggestion? get progressionSuggestion => _progressionSuggestion;
  String get progressionReason => _progressionReason;

  // ======== Methods ========

  // Calculate progression suggestion
  void calculateProgressionSuggestion(
      String exerciseId, int setNumber, Exercise? currentExercise) {
    if (currentExercise == null) {
      _progressionSuggestion = null;
      _notifyListeners();
      return;
    }

    // First check if we have data in current workout
    SetLog? currentWorkoutData =
        _workoutSession.getCurrentWorkoutValues(exerciseId, setNumber);

    // Then check for data from previous workouts if needed
    SetLog? lastSetData = currentWorkoutData ??
        _workoutSession.getLastWorkoutValues(exerciseId, setNumber);

    // Check for missing data
    if (lastSetData == null) {
      // Set progression suggestion to null when there's no data
      _progressionSuggestion = null;
      _notifyListeners();
      return;
    }

    int targetMinReps = currentExercise.minReps;
    int targetMaxReps = currentExercise.maxReps;
    int targetRIR = currentExercise.targetRIR;

    double lastWeight = lastSetData.weight;
    int lastReps = lastSetData.reps;
    int lastRIR = lastSetData.rir;
    double lastOneRM = lastSetData.oneRM;

    // Case 1: If last RIR was significantly below target (more than 1 below target)
    // Focus on performance optimization - same weight, try to improve RIR
    if (lastRIR < targetRIR - 1) {
      _progressionSuggestion = ProgressionSuggestion(
        weight: lastWeight.toString(),
        reps: lastReps.toString(),
        rir: (min(lastRIR + 1, targetRIR)).toString(),
        reason:
            'Your last RIR ($lastRIR) was lower than target ($targetRIR). Focus on improving recovery.',
      );
    }
    // Case 2: RIR is at target or 1 below, and reps can be increased
    else if (lastReps < targetMaxReps) {
      _progressionSuggestion = ProgressionSuggestion(
        weight: lastWeight.toString(),
        reps: (lastReps + 1).toString(),
        rir: lastRIR.toString(),
        reason: 'You can increase your reps from $lastReps to ${lastReps + 1}.',
      );
    }
    // Case 3: Max reps reached, increase weight and reset reps to min
    else {
      // Calculate new weight based on same 1RM
      double? newWeight = _calculateWeightFrom1RM(
        lastOneRM,
        targetMinReps.toString(),
        targetRIR.toString(),
      );

      _progressionSuggestion = ProgressionSuggestion(
        weight: newWeight?.toString() ?? (lastWeight + 2.5).toString(),
        reps: targetMinReps.toString(),
        rir: targetRIR.toString(),
        reason:
            'You\'ve reached max reps ($targetMaxReps). Increase weight and restart at $targetMinReps reps.',
      );
    }

    print(
        'Calculated progression suggestion: ${_progressionSuggestion?.weight} kg, ${_progressionSuggestion?.reps} reps, ${_progressionSuggestion?.rir} RIR');
    _notifyListeners();
  }

  // Helper method to calculate weight from 1RM
  double? _calculateWeightFrom1RM(
      double oneRM, String targetRepsStr, String targetRIRStr) {
    if (oneRM <= 0 || targetRepsStr.isEmpty || targetRIRStr.isEmpty)
      return null;

    int? targetReps = int.tryParse(targetRepsStr);
    int? targetRIR = int.tryParse(targetRIRStr);

    if (targetReps == null || targetRIR == null || targetReps <= 0) return null;

    int effectiveReps = targetReps + targetRIR;

    // Reverse Brzycki formula: Weight = 1RM × ((37 - effective reps) / 36)
    double weight = oneRM * ((37 - effectiveReps) / 36);

    // Round to nearest 0.5 kg
    return (weight * 2).round() / 2;
  }

  // Accept progression suggestion for current set
  void acceptProgressionSuggestion(WorkoutSession session) {
    if (_progressionSuggestion != null) {
      session.applyProgressionSuggestion(_progressionSuggestion!);

      // Don't clear the progression suggestion here
      // Instead, we'll recalculate it when needed

      _notifyListeners();
    }
  }
}
