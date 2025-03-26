// lib/providers/workout_provider.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/models.dart';
import '../services/exercise_service.dart';
import '../services/database_service.dart';

class WorkoutTrackerState extends ChangeNotifier {
  List<TrainingPlan> _plans = [];
  List<WorkoutLog> _savedWorkouts = [];
  TrainingPlan? _currentPlan;
  TrainingDay? _currentDay;
  Exercise? _currentExercise;
  List<SetLog> _workoutLog = [];

  // Neue Datenbankinstanz
  final DatabaseService _databaseService = DatabaseService();

  // Exercise database
  final ExerciseDatabase _exerciseDb = ExerciseDatabase();
  bool _isExerciseDbLoaded = false;
  String _selectedCategoryId = '';
  String _exerciseSearchQuery = '';

  // Modified: now storing data for all sets of current exercise
  List<ExerciseSetData> _currentExerciseSets = [];
  int _currentSetIndex = 0; // Track the current active set index

  // Text controllers for each set's inputs
  List<TextEditingController> _weightControllers = [];
  List<TextEditingController> _repsControllers = [];
  List<TextEditingController> _rirControllers = [];

  bool _showStrengthCalculator = false;
  String _testWeight = '';
  String _testReps = '';
  String _targetReps = '';
  String _targetRIR = '';
  double? _calculatedWeight;

  // Text controllers for strength calculator
  late TextEditingController testWeightController;
  late TextEditingController testRepsController;
  late TextEditingController targetRepsController;
  late TextEditingController targetRIRController;

  ProgressionSuggestion? _progressionSuggestion;
  String _progressionReason = '';

  // Plan creation variables
  String _newPlanName = '';
  int _numberOfTrainingDays = 3;
  int _selectedDayIndex = 0;
  List<String> _trainingDayNames = [];

  // Exercise creation variables
  String _newExerciseName = '';
  int _newExerciseSets = 3;
  int _newExerciseMinReps = 8;
  int _newExerciseMaxReps = 12;
  int _newExerciseRIR = 2;
  String _newExerciseDescription = '';

  // Exercise selection mode flag
  bool _isSelectingFromDatabase = false;

  // Flag für initialen Ladevorgang
  bool _isLoading = true;

  // Getter für Ladevorgang
  bool get isLoading => _isLoading;

  WorkoutTrackerState() {
    // Initialisiere Controller für Rechner
    testWeightController = TextEditingController(text: _testWeight);
    testRepsController = TextEditingController(text: _testReps);
    targetRepsController = TextEditingController(text: _targetReps);
    targetRIRController = TextEditingController(text: _targetRIR);

    // Initialisiere Standard-Trainingstagnamen
    _initDefaultTrainingDayNames();

    // Daten aus der Datenbank laden
    _loadData();

    // Übungsdatenbank laden
    _loadExerciseDatabase();
  }

  // Lade Daten aus der Datenbank
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Trainingspläne laden
      _plans = await _databaseService.getTrainingPlans();

      // Workout-Logs laden
      _savedWorkouts = await _databaseService.getWorkoutLogs();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Fehler beim Laden der Daten: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lade die Übungsdatenbank
  Future<void> _loadExerciseDatabase() async {
    if (!_isExerciseDbLoaded) {
      await _exerciseDb.loadDatabase();
      _isExerciseDbLoaded = _exerciseDb.isLoaded;
      notifyListeners();
    }
  }

  void _initDefaultTrainingDayNames() {
    _trainingDayNames = [];

    for (int i = 0; i < _numberOfTrainingDays; i++) {
      switch (i) {
        case 0:
          _trainingDayNames.add('Tag A');
          break;
        case 1:
          _trainingDayNames.add('Tag B');
          break;
        case 2:
          _trainingDayNames.add('Tag C');
          break;
        case 3:
          _trainingDayNames.add('Tag D');
          break;
        case 4:
          _trainingDayNames.add('Tag E');
          break;
        default:
          _trainingDayNames.add('Tag ${String.fromCharCode(65 + i)}');
          break;
      }
    }
  }

  // Getters
  List<TrainingPlan> get plans => _plans;
  List<WorkoutLog> get savedWorkouts => _savedWorkouts;
  TrainingPlan? get currentPlan => _currentPlan;
  TrainingDay? get currentDay => _currentDay;
  Exercise? get currentExercise => _currentExercise;
  int get currentSetIndex => _currentSetIndex;
  List<SetLog> get workoutLog => _workoutLog;
  List<ExerciseSetData> get currentExerciseSets => _currentExerciseSets;
  List<TextEditingController> get weightControllers => _weightControllers;
  List<TextEditingController> get repsControllers => _repsControllers;
  List<TextEditingController> get rirControllers => _rirControllers;
  bool get showStrengthCalculator => _showStrengthCalculator;
  String get testWeight => _testWeight;
  String get testReps => _testReps;
  String get targetReps => _targetReps;
  String get targetRIR => _targetRIR;
  double? get calculatedWeight => _calculatedWeight;
  ProgressionSuggestion? get progressionSuggestion => _progressionSuggestion;
  String get progressionReason => _progressionReason;
  String get newPlanName => _newPlanName;
  int get numberOfTrainingDays => _numberOfTrainingDays;
  int get selectedDayIndex => _selectedDayIndex;
  List<String> get trainingDayNames => _trainingDayNames;
  String get newExerciseName => _newExerciseName;
  int get newExerciseSets => _newExerciseSets;
  int get newExerciseMinReps => _newExerciseMinReps;
  int get newExerciseMaxReps => _newExerciseMaxReps;
  int get newExerciseRIR => _newExerciseRIR;
  String get newExerciseDescription => _newExerciseDescription;

  // Exercise database getters
  bool get isExerciseDbLoaded => _isExerciseDbLoaded;
  String get selectedCategoryId => _selectedCategoryId;
  String get exerciseSearchQuery => _exerciseSearchQuery;
  bool get isSelectingFromDatabase => _isSelectingFromDatabase;

  // Get exercises based on filters
  List<ExerciseTemplate> getFilteredExercises() {
    if (!_isExerciseDbLoaded) return [];

    // If search query is not empty, search across all categories
    if (_exerciseSearchQuery.isNotEmpty) {
      return _exerciseDb.searchExercises(_exerciseSearchQuery);
    }

    // If category is selected, filter by category
    if (_selectedCategoryId.isNotEmpty) {
      return _exerciseDb.getExercisesByCategory(_selectedCategoryId);
    }

    // Otherwise return all exercises
    return _exerciseDb.getAllExercises();
  }

  // Get all categories from database
  List<ExerciseCategory> getAllCategories() {
    if (!_isExerciseDbLoaded) return [];
    return _exerciseDb.getAllCategories();
  }

  // Setters for exercise database
  set selectedCategoryId(String value) {
    _selectedCategoryId = value;
    notifyListeners();
  }

  set exerciseSearchQuery(String value) {
    _exerciseSearchQuery = value;
    notifyListeners();
  }

  // Toggle exercise selection from database
  void toggleExerciseSelectionMode() {
    _isSelectingFromDatabase = !_isSelectingFromDatabase;
    if (_isSelectingFromDatabase) {
      // Reset filters when opening selection
      _selectedCategoryId = '';
      _exerciseSearchQuery = '';
    }
    notifyListeners();
  }

  // Add exercise from template to plan with optional custom values
  void addExerciseFromTemplate(
    ExerciseTemplate template, {
    int? customSets,
    int? customMinReps,
    int? customMaxReps,
    int? customRIR,
  }) {
    if (_currentPlan == null || _currentDay == null) return;

    // Create a new exercise with custom or default values
    Exercise newExercise = Exercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: template.name,
      sets: customSets ?? template.defaultSets,
      minReps: customMinReps ?? template.defaultMinReps,
      maxReps: customMaxReps ?? template.defaultMaxReps,
      targetRIR: customRIR ?? template.defaultRIR,
      categoryId: template.categoryId,
      description: template.description,
    );

    _currentDay!.exercises.add(newExercise);
    _isSelectingFromDatabase = false; // Close selection mode

    // Plan in der Datenbank aktualisieren
    _updatePlanInDatabase();

    notifyListeners();
  }

  // Aktualisierten Plan in der Datenbank speichern
  Future<void> _updatePlanInDatabase() async {
    if (_currentPlan != null) {
      try {
        await _databaseService.updateTrainingPlan(_currentPlan!);
      } catch (e) {
        print('Fehler beim Aktualisieren des Plans: $e');
      }
    }
  }

  // Setters for training plan creation
  set newPlanName(String value) {
    _newPlanName = value;
    notifyListeners();
  }

  set numberOfTrainingDays(int value) {
    if (value > 0) {
      _numberOfTrainingDays = value;
      _initDefaultTrainingDayNames();
      notifyListeners();
    }
  }

  set selectedDayIndex(int value) {
    if (value >= 0 && value < _numberOfTrainingDays) {
      _selectedDayIndex = value;
      notifyListeners();
    }
  }

  void updateTrainingDayName(int index, String name) {
    if (index >= 0 && index < _trainingDayNames.length) {
      _trainingDayNames[index] = name;
      notifyListeners();
    }
  }

  // Setters for exercise creation
  set newExerciseName(String value) {
    _newExerciseName = value;
    notifyListeners();
  }

  set newExerciseSets(int value) {
    _newExerciseSets = value;
    notifyListeners();
  }

  set newExerciseMinReps(int value) {
    _newExerciseMinReps = value;
    notifyListeners();
  }

  set newExerciseMaxReps(int value) {
    _newExerciseMaxReps = value;
    notifyListeners();
  }

  set newExerciseRIR(int value) {
    _newExerciseRIR = value;
    notifyListeners();
  }

  set newExerciseDescription(String value) {
    _newExerciseDescription = value;
    notifyListeners();
  }

  // Calculator setters
  set testWeight(String value) {
    _testWeight = value;
    testWeightController.text = value;
    testWeightController.selection = TextSelection.fromPosition(
        TextPosition(offset: testWeightController.text.length));
    notifyListeners();
  }

  set testReps(String value) {
    _testReps = value;
    testRepsController.text = value;
    testRepsController.selection = TextSelection.fromPosition(
        TextPosition(offset: testRepsController.text.length));
    notifyListeners();
  }

  set targetReps(String value) {
    _targetReps = value;
    targetRepsController.text = value;
    targetRepsController.selection = TextSelection.fromPosition(
        TextPosition(offset: targetRepsController.text.length));
    notifyListeners();
  }

  set targetRIR(String value) {
    _targetRIR = value;
    targetRIRController.text = value;
    targetRIRController.selection = TextSelection.fromPosition(
        TextPosition(offset: targetRIRController.text.length));
    notifyListeners();
  }

  // Get the 1RM for a specific set
  double? getOneRM(int setIndex) {
    if (setIndex < 0 || setIndex >= _currentExerciseSets.length) return null;

    ExerciseSetData setData = _currentExerciseSets[setIndex];
    return calculate1RM(setData.weight, setData.reps, setData.rir);
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
    notifyListeners();
  }

  // Set current active set
  void setCurrentSet(int index) {
    if (index < 0 || index >= _currentExerciseSets.length) return;
    if (_currentExerciseSets[index].completed)
      return; // Don't activate completed sets

    _currentSetIndex = index;

    // Calculate progression suggestion for this specific set
    if (_currentExercise != null) {
      calculateProgressionSuggestion(_currentExercise!.id,
          index + 1); // +1 because set numbers are 1-based
    }

    notifyListeners();
  }

  // Apply progression suggestion to a specific set
  void applyProgressionSuggestionToSet(int setIndex) {
    if (_progressionSuggestion == null ||
        setIndex < 0 ||
        setIndex >= _currentExerciseSets.length) return;

    _currentExerciseSets[setIndex].weight = _progressionSuggestion!.weight;
    _currentExerciseSets[setIndex].reps = _progressionSuggestion!.reps;
    _currentExerciseSets[setIndex].rir = _progressionSuggestion!.rir;

    _weightControllers[setIndex].text = _progressionSuggestion!.weight;
    _repsControllers[setIndex].text = _progressionSuggestion!.reps;
    _rirControllers[setIndex].text = _progressionSuggestion!.rir;

    notifyListeners();
  }

  // Apply calculated weight to a specific set
  void applyCalculatedWeightToSet(int setIndex) {
    if (_calculatedWeight == null ||
        setIndex < 0 ||
        setIndex >= _currentExerciseSets.length) return;

    _currentExerciseSets[setIndex].weight = _calculatedWeight.toString();
    _weightControllers[setIndex].text = _calculatedWeight.toString();

    if (_targetReps.isNotEmpty) {
      _currentExerciseSets[setIndex].reps = _targetReps;
      _repsControllers[setIndex].text = _targetReps;
    }
    if (_targetRIR.isNotEmpty) {
      _currentExerciseSets[setIndex].rir = _targetRIR;
      _rirControllers[setIndex].text = _targetRIR;
    }
  }

  // 1RM calculation using Brzycki formula with RIR consideration
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

  // Calculate weight based on 1RM and targeted reps+RIR
  double? calculateWeightFrom1RM(
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

  // Calculate ideal working weight based on a RIR 0 test
  void calculateIdealWorkingWeight() {
    if (_testWeight.isEmpty || _testReps.isEmpty || _currentExercise == null) {
      _calculatedWeight = null;
      notifyListeners();
      return;
    }

    double? weight = double.tryParse(_testWeight);
    int? reps = int.tryParse(_testReps);

    if (weight == null || reps == null || weight <= 0 || reps <= 0) {
      _calculatedWeight = null;
      notifyListeners();
      return;
    }

    // Calculate 1RM based on test (RIR 0)
    double oneRM = weight * (36 / (37 - reps));

    // Calculate ideal working weight based on user-defined target values or default values
    int userTargetReps = int.tryParse(_targetReps) ?? _currentExercise!.minReps;
    int userTargetRIR = int.tryParse(_targetRIR) ?? _currentExercise!.targetRIR;
    int effectiveReps = userTargetReps + userTargetRIR; // Consider RIR

    // Reverse formula: Weight = 1RM × ((37 - effective reps) / 36)
    double idealWeight = oneRM * ((37 - effectiveReps) / 36);

    // Round to nearest 0.5 kg
    _calculatedWeight = (idealWeight * 2).round() / 2;
    notifyListeners();
  }

  // Check if we have valid data in saved workouts
  bool hasValidWorkoutHistory() {
    if (_savedWorkouts.isEmpty || _currentPlan == null || _currentDay == null) {
      return false;
    }

    // Check if there are workouts with the current plan and day
    bool planWorkoutsExist = _savedWorkouts.any((workout) =>
        workout.planId == _currentPlan!.id && workout.dayId == _currentDay!.id);

    return planWorkoutsExist;
  }

  // Get last workout values without fallback
  SetLog? getLastWorkoutValues(String exerciseId, int setNumber) {
    if (_currentPlan == null || _currentDay == null) return null;

    // Search for the most recent workout for this exercise and day
    List<WorkoutLog> relevantWorkouts = _savedWorkouts
        .where((workout) =>
            workout.planId == _currentPlan!.id &&
            workout.dayId == _currentDay!.id)
        .toList();

    // Sort by date, latest first
    relevantWorkouts.sort((a, b) => b.date.compareTo(a.date));

    if (relevantWorkouts.isEmpty) return null;

    // Find the last saved set for this exercise and set number
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

  // Look for data in current workout log without fallback
  SetLog? getCurrentWorkoutValues(String exerciseId, int setNumber) {
    try {
      return _workoutLog.firstWhere(
        (log) => log.exerciseId == exerciseId && log.set == setNumber,
      );
    } catch (e) {
      return null;
    }
  }

  // Calculate progression suggestion
  void calculateProgressionSuggestion(String exerciseId, int setNumber) {
    if (_currentExercise == null) {
      _progressionSuggestion = null;
      notifyListeners();
      return;
    }

    // First check if we have data in current workout
    SetLog? currentWorkoutData = getCurrentWorkoutValues(exerciseId, setNumber);

    // Then check for data from previous workouts if needed
    SetLog? lastSetData =
        currentWorkoutData ?? getLastWorkoutValues(exerciseId, setNumber);

    // Check for missing data
    if (lastSetData == null) {
      // If we have at least the current exercise, show default target values
      _progressionSuggestion = ProgressionSuggestion(
        weight: '',
        reps: _currentExercise!.minReps.toString(),
        rir: _currentExercise!.targetRIR.toString(),
        reason:
            'No complete training data available. Start with your target values.',
      );
      notifyListeners();
      return;
    }

    int targetMinReps = _currentExercise!.minReps;
    int targetMaxReps = _currentExercise!.maxReps;
    int targetRIR = _currentExercise!.targetRIR;

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
      double? newWeight = calculateWeightFrom1RM(
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

    notifyListeners();
  }

  // Accept progression suggestion for current set only
  void acceptProgressionSuggestion() {
    if (_progressionSuggestion != null &&
        _currentExerciseSets.isNotEmpty &&
        _currentSetIndex < _currentExerciseSets.length) {
      // Only update the current active set
      _currentExerciseSets[_currentSetIndex].weight =
          _progressionSuggestion!.weight;
      _currentExerciseSets[_currentSetIndex].reps =
          _progressionSuggestion!.reps;
      _currentExerciseSets[_currentSetIndex].rir = _progressionSuggestion!.rir;

      _weightControllers[_currentSetIndex].text =
          _progressionSuggestion!.weight;
      _repsControllers[_currentSetIndex].text = _progressionSuggestion!.reps;
      _rirControllers[_currentSetIndex].text = _progressionSuggestion!.rir;

      _progressionSuggestion = null;
      notifyListeners();
    }
  }

  // Accept calculated weight for current set only
  void acceptCalculatedWeight() {
    if (_calculatedWeight != null &&
        _currentExerciseSets.isNotEmpty &&
        _currentSetIndex < _currentExerciseSets.length) {
      // Only update the current active set
      _currentExerciseSets[_currentSetIndex].weight =
          _calculatedWeight.toString();
      _weightControllers[_currentSetIndex].text = _calculatedWeight.toString();

      // Set user-defined target reps and RIR
      if (_targetReps.isNotEmpty) {
        _currentExerciseSets[_currentSetIndex].reps = _targetReps;
        _repsControllers[_currentSetIndex].text = _targetReps;
      }
      if (_targetRIR.isNotEmpty) {
        _currentExerciseSets[_currentSetIndex].rir = _targetRIR;
        _rirControllers[_currentSetIndex].text = _targetRIR;
      }
    }

    _showStrengthCalculator = false;
    notifyListeners();
  }

  // Open strength calculator
  void openStrengthCalculator() {
    _testWeight = '';
    _testReps = '';
    _targetReps =
        _currentExercise != null ? _currentExercise!.minReps.toString() : '';
    _targetRIR =
        _currentExercise != null ? _currentExercise!.targetRIR.toString() : '';
    _calculatedWeight = null;

    // Update controllers with initial values
    testWeightController.text = _testWeight;
    testRepsController.text = _testReps;
    targetRepsController.text = _targetReps;
    targetRIRController.text = _targetRIR;

    _showStrengthCalculator = true;
    notifyListeners();
  }

  // Close strength calculator
  void hideStrengthCalculator() {
    _showStrengthCalculator = false;
    notifyListeners();
  }

  // Set current plan
  void setCurrentPlan(TrainingPlan plan) {
    _currentPlan = plan;

    // Set first day as default if available
    if (plan.trainingDays.isNotEmpty) {
      _currentDay = plan.trainingDays[0];
    } else {
      _currentDay = null;
    }

    notifyListeners();
  }

  // Set current training day
  void setCurrentDay(TrainingDay day) {
    _currentDay = day;
    notifyListeners();
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

      // In der Datenbank speichern
      try {
        await _databaseService.saveWorkoutLog(completedWorkout);
      } catch (e) {
        print('Fehler beim Speichern des Workout-Logs: $e');
      }
    }

    // Reset states
    _showStrengthCalculator = false;
    _calculatedWeight = null;
    _progressionSuggestion = null;
    _workoutLog = [];
    _currentPlan = null;
    _currentDay = null;
    _currentExercise = null;
    _currentExerciseSets = [];
    _disposeControllers();

    notifyListeners();
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

  // Dispose of controllers to prevent memory leaks
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

    notifyListeners();
  }

  // Initialize set data for an exercise
  void _initializeExerciseSets(Exercise exercise) {
    _currentExerciseSets = [];
    _currentSetIndex = 0; // Start with the first set

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

    // Initialize text controllers for all sets
    _initializeControllers(exercise.sets);

    // Calculate progression suggestion for the currently active set (first set)
    calculateProgressionSuggestion(exercise.id, _currentSetIndex + 1);
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

    // Move to next uncompleted set if available
    int nextSetIndex = _findNextUncompletedSetIndex();
    if (nextSetIndex >= 0) {
      setCurrentSet(nextSetIndex);
    }

    notifyListeners();
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
    return _currentExerciseSets.length - 1;
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

    int currentExerciseIndex = _currentDay!.exercises
        .indexWhere((ex) => ex.id == _currentExercise!.id);

    if (currentExerciseIndex < _currentDay!.exercises.length - 1) {
      Exercise nextExercise = _currentDay!.exercises[currentExerciseIndex + 1];
      _currentExercise = nextExercise;
      _currentSetIndex = 0; // Reset to first set for the new exercise

      // Initialize set data for next exercise
      _initializeExerciseSets(nextExercise);
    } else {
      // If this was the last exercise, notify user
      _progressionSuggestion = null;
    }

    notifyListeners();
  }

  // Create a new training plan with multiple days
  Future<void> createNewPlan() async {
    if (_newPlanName.trim().isEmpty) return;

    List<TrainingDay> trainingDays = [];

    // Create training days based on number of days and their names
    for (int i = 0; i < _numberOfTrainingDays; i++) {
      trainingDays.add(TrainingDay(
        id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
        name: _trainingDayNames[i],
        exercises: [],
      ));
    }

    TrainingPlan newPlan = TrainingPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _newPlanName,
      trainingDays: trainingDays,
    );

    _plans.add(newPlan);
    _currentPlan = newPlan;
    if (trainingDays.isNotEmpty) {
      _currentDay = trainingDays[0];
    }

    // In der Datenbank speichern
    try {
      await _databaseService.saveTrainingPlan(newPlan);
    } catch (e) {
      print('Fehler beim Speichern des neuen Plans: $e');
    }

    // Reset form state
    _newPlanName = '';
    _numberOfTrainingDays = 3;
    _initDefaultTrainingDayNames();
    _selectedDayIndex = 0;

    notifyListeners();
  }

  // Add exercise to current training day
  Future<void> addExerciseToPlan() async {
    if (_newExerciseName.trim().isEmpty ||
        _currentPlan == null ||
        _currentDay == null) return;

    Exercise newExercise = Exercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _newExerciseName,
      sets: _newExerciseSets,
      minReps: _newExerciseMinReps,
      maxReps: _newExerciseMaxReps,
      targetRIR: _newExerciseRIR,
      description:
          _newExerciseDescription.isNotEmpty ? _newExerciseDescription : null,
    );

    _currentDay!.exercises.add(newExercise);
    _newExerciseName = '';
    _newExerciseDescription = '';

    // Plan in der Datenbank aktualisieren
    await _updatePlanInDatabase();

    notifyListeners();
  }

  // Delete exercise from current training day
  Future<void> deleteExercise(String exerciseId) async {
    if (_currentPlan == null || _currentDay == null) return;

    _currentDay!.exercises.removeWhere((ex) => ex.id == exerciseId);

    // Plan in der Datenbank aktualisieren
    await _updatePlanInDatabase();

    notifyListeners();
  }

  // Delete a training plan
  Future<void> deletePlan(String planId) async {
    _plans.removeWhere((plan) => plan.id == planId);

    // Clear current plan if it was the deleted one
    if (_currentPlan != null && _currentPlan!.id == planId) {
      _currentPlan = null;
      _currentDay = null;
    }

    // Aus der Datenbank löschen
    try {
      await _databaseService.deleteTrainingPlan(planId);
    } catch (e) {
      print('Fehler beim Löschen des Plans: $e');
    }

    notifyListeners();
  }

  // Skip current exercise and move to next
  void skipExercise() {
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
    } else {
      // If last exercise is skipped
      // Notify user
      _progressionSuggestion = null;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _disposeControllers();
    testWeightController.dispose();
    testRepsController.dispose();
    targetRepsController.dispose();
    targetRIRController.dispose();
    super.dispose();
  }
}
