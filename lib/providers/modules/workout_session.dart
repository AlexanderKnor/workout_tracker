// lib/providers/modules/workout_session.dart
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/database_service.dart';

class WorkoutSession {
  final DatabaseService _databaseService;
  final Function _notifyListeners;

  // Current workout data
  TrainingPlan? _currentPlan;
  TrainingDay? _currentDay;
  Exercise? _currentExercise;
  List<SetLog> _workoutLog = [];
  List<WorkoutLog> _savedWorkouts = [];

  // Exercise set data
  List<ExerciseSetData> _currentExerciseSets = [];
  int _currentSetIndex = 0;

  // Text controllers for each set's inputs
  List<TextEditingController> _weightControllers = [];
  List<TextEditingController> _repsControllers = [];
  List<TextEditingController> _rirControllers = [];

  // Neue Eigenschaften für den Rest Timer
  bool _showRestTimer = false;
  int _currentRestTime = 0; // Aktuelle Pausenzeit in Sekunden

  // Constructor
  WorkoutSession(this._databaseService, this._notifyListeners);

  // ======== Getters ========
  TrainingPlan? get currentPlan => _currentPlan;
  TrainingDay? get currentDay => _currentDay;
  Exercise? get currentExercise => _currentExercise;
  List<SetLog> get workoutLog => _workoutLog;
  List<WorkoutLog> get savedWorkouts => _savedWorkouts;
  List<ExerciseSetData> get currentExerciseSets => _currentExerciseSets;
  int get currentSetIndex => _currentSetIndex;
  List<TextEditingController> get weightControllers => _weightControllers;
  List<TextEditingController> get repsControllers => _repsControllers;
  List<TextEditingController> get rirControllers => _rirControllers;

  // Rest Timer Getters
  bool get showRestTimer => _showRestTimer;
  int get currentRestTime => _currentRestTime;

  // Check if all exercises in the day are completed
  bool get isAllExercisesCompleted {
    if (_currentDay == null) return false;

    // Prüfe alle Übungen, nicht nur die aktuelle
    for (var exercise in _currentDay!.exercises) {
      // Finde alle Sets für diese Übung in den Logs
      List<SetLog> exerciseLogs =
          _workoutLog.where((log) => log.exerciseId == exercise.id).toList();

      // Wenn die Anzahl der Logs nicht mit der Anzahl der erwarteten Sets übereinstimmt,
      // ist die Übung nicht vollständig abgeschlossen
      if (exerciseLogs.length < exercise.sets) {
        return false;
      }
    }

    // Alle Übungen haben die erwartete Anzahl von Sets im Log
    return true;
  }

  // Check if current exercise is the last one
  bool get isLastExercise {
    if (_currentDay == null || _currentExercise == null) return false;
    int currentIndex = _currentDay!.exercises
        .indexWhere((ex) => ex.id == _currentExercise!.id);
    return currentIndex == _currentDay!.exercises.length - 1;
  }

  // ======== Methods ========

  // Load workout logs from database
  Future<void> loadWorkoutLogs() async {
    try {
      _savedWorkouts = await _databaseService.getWorkoutLogs();
    } catch (e) {
      print('Error loading workout logs: $e');
      _savedWorkouts = [];
    }
  }

  // Start a workout with a specific plan and day
  void startWorkout(TrainingPlan plan, TrainingDay day) {
    _currentPlan = plan;
    _currentDay = day;

    Exercise? firstExercise =
        day.exercises.isNotEmpty ? day.exercises[0] : null;
    _currentExercise = firstExercise;
    _workoutLog = [];

    // If there's a first exercise, load the last values for all sets
    if (firstExercise != null) {
      _initializeExerciseSets(firstExercise);
    }

    _notifyListeners();
  }

  // Öffentliche Methode für das Initialisieren der Sets einer Übung
  // Dies wird von WorkoutTrackerState aufgerufen
  void initializeExerciseSetsPublic(Exercise exercise) {
    _initializeExerciseSets(exercise);
  }

  // Finish and save workout
  Future<void> finishWorkout() async {
    if (_workoutLog.isNotEmpty && _currentPlan != null && _currentDay != null) {
      WorkoutLog completedWorkout = WorkoutLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        planId: _currentPlan!.id,
        planName: _currentPlan!.name,
        dayId: _currentDay!.id,
        dayName: _currentDay!.name,
        sets: _workoutLog,
      );

      _savedWorkouts.add(completedWorkout);

      // Save to database
      try {
        await _databaseService.saveWorkoutLog(completedWorkout);
      } catch (e) {
        print('Error saving workout log: $e');
      }
    }

    // Reset states
    _workoutLog = [];
    _currentPlan = null;
    _currentDay = null;
    _currentExercise = null;
    _currentExerciseSets = [];
    _showRestTimer = false;
    _disposeControllers();

    _notifyListeners();
  }

  // Dispose controllers to prevent memory leaks
  void _disposeControllers() {
    for (var controller in _weightControllers) {
      controller.dispose();
    }
    for (var controller in _repsControllers) {
      controller.dispose();
    }
    for (var controller in _rirControllers) {
      controller.dispose();
    }
    _weightControllers = [];
    _repsControllers = [];
    _rirControllers = [];
  }

  // Set current exercise by index
  void setCurrentExerciseByIndex(int index) {
    if (_currentDay == null ||
        index < 0 ||
        index >= _currentDay!.exercises.length) return;

    Exercise selectedExercise = _currentDay!.exercises[index];

    // If the current exercise is already selected, do nothing
    if (_currentExercise?.id == selectedExercise.id) return;

    // Save data of current exercise if needed
    if (_currentExercise != null) {
      // Optional: Save incomplete sets before switching
    }

    _currentExercise = selectedExercise;
    _currentSetIndex = 0; // Focus on first set
    _showRestTimer = false; // Hide rest timer when switching exercises

    // Initialize sets for new exercise
    _initializeExerciseSets(selectedExercise);

    _notifyListeners();
  }

  // Initialize set data for an exercise - ÜBERARBEITETE METHODE
  void _initializeExerciseSets(Exercise exercise) {
    _currentExerciseSets = [];
    _currentSetIndex = 0; // Start with the first set

    // First check if we already have data for this exercise in the current workout
    List<SetLog> existingLogs =
        _workoutLog.where((log) => log.exerciseId == exercise.id).toList();

    // If we have existing logs for this exercise in the current workout, use that data
    if (existingLogs.isNotEmpty) {
      // Sort logs by set number
      existingLogs.sort((a, b) => a.set.compareTo(b.set));

      // Populate sets based on existing logs
      for (int i = 1; i <= exercise.sets; i++) {
        // Try to find an existing log for this set
        SetLog? existingLog;
        try {
          existingLog = existingLogs.firstWhere((log) => log.set == i);
        } catch (e) {
          existingLog = null;
        }

        if (existingLog != null) {
          // If we have a log for this set, use its values and mark as completed
          _currentExerciseSets.add(ExerciseSetData(
            weight: existingLog.weight.toString(),
            reps: existingLog.reps.toString(),
            rir: existingLog.rir.toString(),
            completed: true, // Mark as completed since it's already logged
          ));
        } else {
          // Otherwise create a new set with default values
          _currentExerciseSets.add(ExerciseSetData(
            weight: '',
            reps: exercise.minReps.toString(),
            rir: exercise.targetRIR.toString(),
            completed: false,
          ));
        }
      }
    } else {
      // Check workout history for each set if we don't have current logs
      for (int i = 1; i <= exercise.sets; i++) {
        // Check workout history for each set
        SetLog? lastValues = getLastWorkoutValues(exercise.id, i);

        if (lastValues != null) {
          _currentExerciseSets.add(ExerciseSetData(
            weight: lastValues.weight.toString(),
            reps: lastValues.reps.toString(),
            rir: lastValues.rir.toString(),
            completed: false, // All sets start as incomplete
          ));
        } else {
          // Default values if no history
          _currentExerciseSets.add(ExerciseSetData(
            weight: '',
            reps: exercise.minReps.toString(),
            rir: exercise.targetRIR.toString(),
            completed: false,
          ));
        }
      }
    }

    // Initialize text controllers for all sets
    _initializeControllers(exercise.sets);

    // Calculate progression suggestion for the first set
    // This ensures it's displayed immediately on exercise start
    if (_currentExerciseSets.isNotEmpty) {
      _notifyListeners(); // Update UI first
      Future.microtask(() {
        // Use a microtask to avoid calling during build
        calculateProgressionSuggestion(exercise.id, 1);
      });
    }
  }

  // Initialize controllers for all sets of an exercise
  void _initializeControllers(int numSets) {
    _disposeControllers(); // Clean up previous controllers

    _weightControllers = List.generate(numSets,
        (i) => TextEditingController(text: _currentExerciseSets[i].weight));

    _repsControllers = List.generate(numSets,
        (i) => TextEditingController(text: _currentExerciseSets[i].reps));

    _rirControllers = List.generate(numSets,
        (i) => TextEditingController(text: _currentExerciseSets[i].rir));
  }

  // Set current active set
  void setCurrentSet(int index) {
    if (index < 0 || index >= _currentExerciseSets.length) return;
    if (_currentExerciseSets[index].completed)
      return; // Don't activate completed sets

    _currentSetIndex = index;

    // Calculate progression suggestion for this specific set
    if (_currentExercise != null) {
      // Use a microtask to avoid calling during build
      Future.microtask(() {
        calculateProgressionSuggestion(_currentExercise!.id,
            index + 1); // +1 because set numbers are 1-based
      });
    }

    _notifyListeners();
  }

  // Method to calculate progression suggestion
  void calculateProgressionSuggestion(String exerciseId, int setNumber) {
    // Hook into external progression service
    if (exerciseId.isNotEmpty && setNumber > 0 && _currentExercise != null) {
      // This method should be provided by the parent class through dependency injection
      // or some other mechanism, we're just defining a placeholder here
      print('Calculating progression suggestion for set $setNumber');
    }
  }

  // Update set data
  void updateSetData(int setIndex, String field, String value) {
    if (setIndex < 0 || setIndex >= _currentExerciseSets.length) return;

    switch (field) {
      case 'weight':
        _currentExerciseSets[setIndex].weight = value;
        _weightControllers[setIndex].text = value;
        break;
      case 'reps':
        _currentExerciseSets[setIndex].reps = value;
        _repsControllers[setIndex].text = value;
        break;
      case 'rir':
        _currentExerciseSets[setIndex].rir = value;
        _rirControllers[setIndex].text = value;
        break;
    }
    _notifyListeners();
  }

  // Get last workout values for a specific set
  SetLog? getLastWorkoutValues(String exerciseId, int setNumber) {
    if (_currentPlan == null || _currentDay == null) return null;

    // Search for most recent workout for this exercise and day
    List<WorkoutLog> relevantWorkouts = _savedWorkouts
        .where((workout) =>
            workout.planId == _currentPlan!.id &&
            workout.dayId == _currentDay!.id)
        .toList();

    // Sort by date, latest first
    relevantWorkouts.sort((a, b) => b.date.compareTo(a.date));

    if (relevantWorkouts.isEmpty) return null;

    // Find last saved set for this exercise and set number
    WorkoutLog lastWorkout = relevantWorkouts.first;
    SetLog? lastSet;

    try {
      lastSet = lastWorkout.sets.firstWhere(
        (set) => set.exerciseId == exerciseId && set.set == setNumber,
      );
      return lastSet;
    } catch (e) {
      return null;
    }
  }

  // Look for data in current workout log
  SetLog? getCurrentWorkoutValues(String exerciseId, int setNumber) {
    try {
      return _workoutLog.firstWhere(
        (log) => log.exerciseId == exerciseId && log.set == setNumber,
      );
    } catch (e) {
      return null;
    }
  }

  // Calculate 1RM using Brzycki formula with RIR consideration
  double? calculate1RM(String weightStr, String repsStr, String rirStr) {
    if (weightStr.isEmpty || repsStr.isEmpty || rirStr.isEmpty) return null;

    double? weight = double.tryParse(weightStr);
    int? reps = int.tryParse(repsStr);
    int? rir = int.tryParse(rirStr);

    if (weight == null ||
        reps == null ||
        rir == null ||
        weight <= 0 ||
        reps <= 0) return null;

    // Actual max reps = Performed reps + RIR
    int totalReps = reps + rir;

    // Brzycki formula: 1RM = Weight × (36 / (37 - Reps))
    if (totalReps >= 36)
      return weight * 1.0; // For very high rep counts, formula is not accurate

    double oneRM = weight * (36 / (37 - totalReps));
    return (oneRM * 10).round() / 10; // Round to one decimal place
  }

  // Get the 1RM for a specific set
  double? getOneRM(int setIndex) {
    if (setIndex < 0 || setIndex >= _currentExerciseSets.length) return null;

    ExerciseSetData setData = _currentExerciseSets[setIndex];
    return calculate1RM(setData.weight, setData.reps, setData.rir);
  }

  // Log the current set and move to the next
  void logCurrentSet() {
    if (_currentExercise == null ||
        _currentSetIndex >= _currentExerciseSets.length) return;

    ExerciseSetData setData = _currentExerciseSets[_currentSetIndex];

    // Skip if data is incomplete
    if (setData.weight.isEmpty || setData.reps.isEmpty || setData.rir.isEmpty)
      return;

    double? weight = double.tryParse(setData.weight);
    int? reps = int.tryParse(setData.reps);
    int? rir = int.tryParse(setData.rir);

    if (weight == null || reps == null || rir == null) return;

    double? oneRM = calculate1RM(setData.weight, setData.reps, setData.rir);
    if (oneRM == null) return;

    // Mark this set as completed
    setData.completed = true;

    // Create log entry
    SetLog logEntry = SetLog(
      exerciseId: _currentExercise!.id,
      exerciseName: _currentExercise!.name,
      set: _currentSetIndex +
          1, // +1 because indices are 0-based but set numbers are 1-based
      weight: weight,
      reps: reps,
      rir: rir,
      oneRM: oneRM,
    );

    // Check if this set is already logged
    int existingIndex = _workoutLog.indexWhere((log) =>
        log.exerciseId == _currentExercise!.id &&
        log.set == _currentSetIndex + 1);

    if (existingIndex >= 0) {
      // Update existing log
      _workoutLog[existingIndex] = logEntry;
    } else {
      // Add new log
      _workoutLog.add(logEntry);
    }

    // Check if there are more sets for this exercise
    bool hasMoreSets = _findNextUncompletedSetIndex() != -1;

    // Show rest timer if there are more sets left for this exercise
    if (hasMoreSets && _currentExercise!.restTime > 0) {
      _currentRestTime = _currentExercise!.restTime;
      _showRestTimer = true;
    } else {
      _showRestTimer = false;
    }

    // Move to next uncompleted set if available
    int nextSetIndex = _findNextUncompletedSetIndex();
    if (nextSetIndex >= 0) {
      setCurrentSet(nextSetIndex);
    }

    _notifyListeners();
  }

  // Neue Methode zum Beenden des Rest Timers
  void endRestTimer() {
    _showRestTimer = false;
    _notifyListeners();
  }

  // Find next uncompleted set index
  int _findNextUncompletedSetIndex() {
    // First try to find sets after the current one
    for (int i = _currentSetIndex + 1; i < _currentExerciseSets.length; i++) {
      if (!_currentExerciseSets[i].completed) {
        return i;
      }
    }

    // If not found, look for uncompleted sets before the current one
    for (int i = 0; i < _currentSetIndex; i++) {
      if (!_currentExerciseSets[i].completed) {
        return i;
      }
    }

    // If all sets are completed, return the last set index
    return -1;
  }

  // Eine Methode, um zur ersten unvollständigen Übung zu navigieren
  void navigateToNextIncompleteExercise() {
    if (_currentPlan == null || _currentDay == null) return;

    // Wir beginnen immer mit der ersten Übung des Trainingstages
    // anstatt von der aktuellen Position aus zu suchen
    for (int i = 0; i < _currentDay!.exercises.length; i++) {
      // Die Übung an dieser Position abrufen
      Exercise exercise = _currentDay!.exercises[i];

      // Prüfen, ob diese Übung unvollständig ist
      List<SetLog> exerciseLogs =
          _workoutLog.where((log) => log.exerciseId == exercise.id).toList();

      if (exerciseLogs.length < exercise.sets) {
        // Unvollständige Übung gefunden - zu dieser wechseln
        _currentExercise = exercise;
        _currentSetIndex = 0;
        _showRestTimer = false; // Timer ausblenden beim Wechseln
        _initializeExerciseSets(exercise);

        // Beenden, wenn wir eine unvollständige Übung gefunden haben
        return;
      }
    }

    // Falls wir hier landen, sind alle Übungen vollständig
    // Wir bleiben bei der aktuellen Übung
  }

  // Move to next exercise
  void moveToNextExercise() {
    if (_currentPlan == null || _currentDay == null || _currentExercise == null)
      return;

    // Log any incomplete sets
    for (int i = 0; i < _currentExerciseSets.length; i++) {
      if (!_currentExerciseSets[i].completed) {
        // Set the current set to this one and log it if possible
        _currentSetIndex = i;
        logCurrentSet();
      }
    }

    // Prüfen, ob alle Sets der aktuellen Übung abgeschlossen sind
    bool isCurrentExerciseCompleted =
        _currentExerciseSets.every((set) => set.completed);

    // Wenn die aktuelle Übung abgeschlossen ist, zur nächsten unvollständigen Übung navigieren
    if (isCurrentExerciseCompleted) {
      navigateToNextIncompleteExercise();
    } else {
      // Andernfalls zum nächsten unvollständigen Set der aktuellen Übung gehen
      int nextSetIndex = _findNextUncompletedSetIndex();
      if (nextSetIndex >= 0) {
        _currentSetIndex = nextSetIndex;
      }
    }

    // UI aktualisieren
    _notifyListeners();
  }

  // Skip current exercise and move to next
  void skipExercise() {
    _showRestTimer =
        false; // Verstecke den Timer wenn zur nächsten Übung gewechselt wird

    if (_currentPlan == null || _currentDay == null || _currentExercise == null)
      return;

    int currentExerciseIndex = _currentDay!.exercises
        .indexWhere((ex) => ex.id == _currentExercise!.id);

    if (currentExerciseIndex < _currentDay!.exercises.length - 1) {
      Exercise nextExercise = _currentDay!.exercises[currentExerciseIndex + 1];
      _currentExercise = nextExercise;
      _currentSetIndex = 0; // Reset to first set

      // Initialize set data for next exercise
      _initializeExerciseSets(nextExercise);
    }

    _notifyListeners();
  }

  // Apply calculated weight to a specific set
  void applyCalculatedWeightToCurrentSet(
      double? calculatedWeight, String targetReps, String targetRIR) {
    if (calculatedWeight == null ||
        _currentSetIndex < 0 ||
        _currentSetIndex >= _currentExerciseSets.length) return;

    _currentExerciseSets[_currentSetIndex].weight = calculatedWeight.toString();
    _weightControllers[_currentSetIndex].text = calculatedWeight.toString();

    if (targetReps.isNotEmpty) {
      _currentExerciseSets[_currentSetIndex].reps = targetReps;
      _repsControllers[_currentSetIndex].text = targetReps;
    }
    if (targetRIR.isNotEmpty) {
      _currentExerciseSets[_currentSetIndex].rir = targetRIR;
      _rirControllers[_currentSetIndex].text = targetRIR;
    }

    _notifyListeners();
  }

  // Apply progression suggestion to current set
  void applyProgressionSuggestion(ProgressionSuggestion suggestion) {
    if (_currentSetIndex < 0 || _currentSetIndex >= _currentExerciseSets.length)
      return;

    // Only update the current active set
    _currentExerciseSets[_currentSetIndex].weight = suggestion.weight;
    _currentExerciseSets[_currentSetIndex].reps = suggestion.reps;
    _currentExerciseSets[_currentSetIndex].rir = suggestion.rir;

    _weightControllers[_currentSetIndex].text = suggestion.weight;
    _repsControllers[_currentSetIndex].text = suggestion.reps;
    _rirControllers[_currentSetIndex].text = suggestion.rir;

    // Don't recalculate progression here - we'll keep showing the suggestion
    // until the user changes the values manually or logs the set

    _notifyListeners();
  }

  // Dispose resources
  void dispose() {
    _disposeControllers();
  }
}
