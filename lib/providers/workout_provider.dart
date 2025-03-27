// lib/providers/workout_provider.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../services/exercise_service.dart';
import 'modules/plan_manager.dart';
import 'modules/workout_session.dart';
import 'modules/strength_calculator.dart';
import 'modules/progression_service.dart';

class WorkoutTrackerState extends ChangeNotifier {
  // Services
  final DatabaseService _databaseService = DatabaseService();
  final ExerciseDatabase _exerciseDb = ExerciseDatabase();
  late final PlanManager _planManager;
  late final WorkoutSession _workoutSession;
  late final StrengthCalculator _strengthCalculator;
  late final ProgressionService _progressionService;

  // State flags
  bool _isLoading = true;
  bool _isExerciseDbLoaded = false;
  String _selectedCategoryId = '';
  String _exerciseSearchQuery = '';
  bool _isSelectingFromDatabase = false;

  // Constructor
  WorkoutTrackerState() {
    // Initialize modules
    _planManager = PlanManager(_databaseService, notifyListeners);
    _workoutSession = WorkoutSession(_databaseService, notifyListeners);
    _strengthCalculator = StrengthCalculator(notifyListeners);
    _progressionService = ProgressionService(_workoutSession, notifyListeners);

    // Initial data loading
    _loadData();
    _loadExerciseDatabase();
  }

  // A method for safely updating state
  void safeUpdate(Function updateFunction) {
    Future.microtask(() {
      try {
        updateFunction();
      } catch (e) {
        print('Error in safeUpdate: $e');
      }
    });
  }

  // ======== Data loading methods ========

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load plans
      await _planManager.loadPlans();

      // Load workout logs
      await _workoutSession.loadWorkoutLogs();

      // Load active plan id
      String? activePlanId = await _databaseService.getActivePlanId();
      _planManager.setActivePlanId(activePlanId);

      // If no active plan is set and plans exist, set the first one as active
      if (_planManager.activePlanId == null && _planManager.plans.isNotEmpty) {
        _planManager.setActivePlanId(_planManager.plans.first.id);
        _planManager.savePlanActivationState();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadExerciseDatabase() async {
    if (!_isExerciseDbLoaded) {
      await _exerciseDb.loadDatabase();
      _isExerciseDbLoaded = _exerciseDb.isLoaded;
      notifyListeners();
    }
  }

  // ======== Getters and Setters ========

  // Loading state
  bool get isLoading => _isLoading;

  // Plan Management Getters (delegated)
  List<TrainingPlan> get plans => _planManager.plans;
  TrainingPlan? get currentPlan => _planManager.currentPlan;
  TrainingDay? get currentDay => _planManager.currentDay;
  bool get isPlanSaved => _planManager.isPlanSaved;
  TrainingPlan? get activePlan => _planManager.activePlan;

  // Workout Session Getters (delegated)
  Exercise? get currentExercise => _workoutSession.currentExercise;
  int get currentSetIndex => _workoutSession.currentSetIndex;
  List<SetLog> get workoutLog => _workoutSession.workoutLog;
  List<ExerciseSetData> get currentExerciseSets =>
      _workoutSession.currentExerciseSets;
  List<TextEditingController> get weightControllers =>
      _workoutSession.weightControllers;
  List<TextEditingController> get repsControllers =>
      _workoutSession.repsControllers;
  List<TextEditingController> get rirControllers =>
      _workoutSession.rirControllers;
  bool get isAllExercisesCompleted => _workoutSession.isAllExercisesCompleted;
  bool get isLastExercise => _workoutSession.isLastExercise;

  // Rest Timer Getters (delegated)
  bool get showRestTimer => _workoutSession.showRestTimer;
  int get currentRestTime => _workoutSession.currentRestTime;

  // Strength Calculator Getters (delegated)
  bool get showStrengthCalculator => _strengthCalculator.showStrengthCalculator;
  String get testWeight => _strengthCalculator.testWeight;
  String get testReps => _strengthCalculator.testReps;
  String get targetReps => _strengthCalculator.targetReps;
  String get targetRIR => _strengthCalculator.targetRIR;
  double? get calculatedWeight => _strengthCalculator.calculatedWeight;
  TextEditingController get testWeightController =>
      _strengthCalculator.testWeightController;
  TextEditingController get testRepsController =>
      _strengthCalculator.testRepsController;
  TextEditingController get targetRepsController =>
      _strengthCalculator.targetRepsController;
  TextEditingController get targetRIRController =>
      _strengthCalculator.targetRIRController;

  // Progression Service Getters (delegated)
  ProgressionSuggestion? get progressionSuggestion =>
      _progressionService.progressionSuggestion;
  String get progressionReason => _progressionService.progressionReason;

  // Plan Creation Getters (delegated)
  String get newPlanName => _planManager.newPlanName;
  int get numberOfTrainingDays => _planManager.numberOfTrainingDays;
  int get selectedDayIndex => _planManager.selectedDayIndex;
  List<String> get trainingDayNames => _planManager.trainingDayNames;

  // Exercise Creation Getters (delegated)
  String get newExerciseName => _planManager.newExerciseName;
  int get newExerciseSets => _planManager.newExerciseSets;
  int get newExerciseMinReps => _planManager.newExerciseMinReps;
  int get newExerciseMaxReps => _planManager.newExerciseMaxReps;
  int get newExerciseRIR => _planManager.newExerciseRIR;
  String get newExerciseDescription => _planManager.newExerciseDescription;
  int get newExerciseRestTime =>
      _planManager.newExerciseRestTime; // Neuer Getter

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

  // Set Filter Properties
  set selectedCategoryId(String value) {
    _selectedCategoryId = value;
    notifyListeners();
  }

  set exerciseSearchQuery(String value) {
    _exerciseSearchQuery = value;
    notifyListeners();
  }

  // Toggle between normal and exercise selection mode
  void toggleExerciseSelectionMode() {
    _isSelectingFromDatabase = !_isSelectingFromDatabase;
    if (_isSelectingFromDatabase) {
      // Reset filters when opening selection
      _selectedCategoryId = '';
      _exerciseSearchQuery = '';
    }
    notifyListeners();
  }

  // ======== Delegated Methods ========

  // Plan Management Methods
  void setCurrentPlan(TrainingPlan plan) => _planManager.setCurrentPlan(plan);
  void setCurrentDay(TrainingDay day) => _planManager.setCurrentDay(day);
  Future<void> createNewPlan() => _planManager.createNewPlan();
  Future<void> createDraftPlan() => _planManager.createDraftPlan();
  bool isPlanValid(TrainingPlan? plan) => _planManager.isPlanValid(plan);
  Future<bool> saveCurrentPlan() => _planManager.saveCurrentPlan();
  void discardCurrentPlan() => _planManager.discardCurrentPlan();
  Future<void> addExerciseToPlan() => _planManager.addExerciseToPlan();
  Future<void> deleteExercise(String exerciseId) =>
      _planManager.deleteExercise(exerciseId);
  Future<void> deletePlan(String planId) => _planManager.deletePlan(planId);
  void setActivePlan(String planId) => _planManager.setActivePlan(planId);
  void updateTrainingDayName(int index, String name) =>
      _planManager.updateTrainingDayName(index, name);

  // Plan creation setters
  set newPlanName(String value) => _planManager.newPlanName = value;
  set numberOfTrainingDays(int value) =>
      _planManager.numberOfTrainingDays = value;
  set selectedDayIndex(int value) => _planManager.selectedDayIndex = value;

  // Exercise creation setters
  set newExerciseName(String value) => _planManager.newExerciseName = value;
  set newExerciseSets(int value) => _planManager.newExerciseSets = value;
  set newExerciseMinReps(int value) => _planManager.newExerciseMinReps = value;
  set newExerciseMaxReps(int value) => _planManager.newExerciseMaxReps = value;
  set newExerciseRIR(int value) => _planManager.newExerciseRIR = value;
  set newExerciseDescription(String value) =>
      _planManager.newExerciseDescription = value;
  set newExerciseRestTime(int value) =>
      _planManager.newExerciseRestTime = value; // Neuer Setter

  // Workout Session Methods
  void startWorkout(TrainingPlan plan, TrainingDay day) =>
      _workoutSession.startWorkout(plan, day);
  Future<void> finishWorkout() async {
    await _workoutSession.finishWorkout();
    notifyListeners(); // Make sure UI updates after workout is finished
  }

  // Rest Timer Methods
  void endRestTimer() => _workoutSession.endRestTimer();

  // ÜBERARBEITETE METHODE
  void setCurrentExerciseByIndex(int index) {
    if (currentDay == null ||
        index < 0 ||
        index >= currentDay!.exercises.length) return;

    Exercise selectedExercise = currentDay!.exercises[index];

    // If the current exercise is already selected, do nothing
    if (currentExercise?.id == selectedExercise.id) return;

    // Check if the selected exercise has data in the workout log
    final hasLoggedSets =
        workoutLog.any((log) => log.exerciseId == selectedExercise.id);

    // Rufe die ursprüngliche Methode auf, um die Übung zu setzen
    _workoutSession.setCurrentExerciseByIndex(index);

    // Falls nötig, könnten wir hier zusätzliche Anpassungen vornehmen
    notifyListeners();
  }

  void setCurrentSet(int index) => _workoutSession.setCurrentSet(index);
  void updateSetData(int setIndex, String field, String value) =>
      _workoutSession.updateSetData(setIndex, field, value);
  double? getOneRM(int setIndex) => _workoutSession.getOneRM(setIndex);
  void logCurrentSet() => _workoutSession.logCurrentSet();
  void safeLogCurrentSet() => safeUpdate(() => _workoutSession.logCurrentSet());

  void safeMoveToNextExercise() {
    // Führe den Code in einem sicheren Kontext aus, der nicht mit dem UI-Thread kollidiert
    Future.microtask(() {
      try {
        print("safeMoveToNextExercise wird aufgerufen");

        // Prüfen, ob aktuelle Übung bereits abgeschlossen ist
        bool isCurrentExerciseCompleted = false;
        if (currentExerciseSets.isNotEmpty) {
          isCurrentExerciseCompleted =
              currentExerciseSets.every((set) => set.completed);
        }

        print("Ist aktuelle Übung abgeschlossen? $isCurrentExerciseCompleted");

        if (isCurrentExerciseCompleted) {
          // Wenn Übung bereits abgeschlossen, direkt zur ersten unvollständigen Übung navigieren
          print(
              "Übung abgeschlossen, navigiere direkt zur ersten unvollständigen Übung");
          _forceMoveToFirstIncompleteExercise();
        } else {
          // Sonst die normale moveToNextExercise-Methode aufrufen
          print(
              "Übung noch nicht abgeschlossen, rufe normale moveToNextExercise auf");
          _workoutSession.moveToNextExercise();
        }

        // Stelle sicher, dass eine UI-Aktualisierung erfolgt
        notifyListeners();
      } catch (e) {
        print('Fehler in safeMoveToNextExercise: $e');
      }
    });
  }

  // Neue Methode zum direkten Navigieren zur ersten unvollständigen Übung
  void _forceMoveToFirstIncompleteExercise() {
    if (currentDay == null) return;

    print("Suche erste unvollständige Übung...");

    // Aktuelle Übungs-ID merken
    String? originalExerciseId = currentExercise?.id;

    // Übungen des aktuellen Tages durchgehen (beginnend mit der ersten)
    for (int i = 0; i < currentDay!.exercises.length; i++) {
      Exercise exercise = currentDay!.exercises[i];

      // Prüfen, ob diese Übung unvollständig ist
      List<SetLog> exerciseLogs = _workoutSession.workoutLog
          .where((log) => log.exerciseId == exercise.id)
          .toList();

      // Wenn die Anzahl der Logs kleiner ist als die Anzahl der Sets,
      // dann ist die Übung unvollständig
      if (exerciseLogs.length < exercise.sets) {
        print(
            "Unvollständige Übung gefunden: ${exercise.name} (ID: ${exercise.id})");

        // Wenn die gefundene Übung nicht die aktuelle ist, zu ihr wechseln
        if (exercise.id != originalExerciseId) {
          print("Wechsle zu unvollständiger Übung ${exercise.name}");

          // Bestimme den Index der Übung
          int exerciseIndex =
              currentDay!.exercises.indexWhere((ex) => ex.id == exercise.id);

          // Setze die Übung direkt
          setCurrentExerciseByIndex(exerciseIndex);

          // Beenden, sobald eine unvollständige Übung gefunden wurde
          return;
        } else {
          print(
              "Gefundene unvollständige Übung ist bereits die aktuelle Übung");
        }
      }
    }

    print(
        "Keine unvollständige Übung gefunden oder bereits bei der ersten unvollständigen Übung");
  }

  void skipExercise() => _workoutSession.skipExercise();

  // Strength Calculator Methods
  set testWeight(String value) => _strengthCalculator.testWeight = value;
  set testReps(String value) => _strengthCalculator.testReps = value;
  set targetReps(String value) => _strengthCalculator.targetReps = value;
  set targetRIR(String value) => _strengthCalculator.targetRIR = value;
  void calculateIdealWorkingWeight() =>
      _strengthCalculator.calculateIdealWorkingWeight();
  void safeCalculateIdealWorkingWeight() =>
      safeUpdate(() => _strengthCalculator.calculateIdealWorkingWeight());
  void acceptCalculatedWeight() =>
      _strengthCalculator.acceptCalculatedWeight(_workoutSession);
  void safeAcceptCalculatedWeight() => safeUpdate(
      () => _strengthCalculator.acceptCalculatedWeight(_workoutSession));
  void openStrengthCalculator() =>
      _strengthCalculator.openStrengthCalculator(currentExercise);
  void safeOpenStrengthCalculator() => safeUpdate(
      () => _strengthCalculator.openStrengthCalculator(currentExercise));
  void hideStrengthCalculator() => _strengthCalculator.hideStrengthCalculator();

  // Progression Service Methods
  void calculateProgressionSuggestion(String exerciseId, int setNumber) =>
      _progressionService.calculateProgressionSuggestion(
          exerciseId, setNumber, currentExercise);
  void acceptProgressionSuggestion() =>
      _progressionService.acceptProgressionSuggestion(_workoutSession);
  void safeAcceptProgressionSuggestion() => safeUpdate(
      () => _progressionService.acceptProgressionSuggestion(_workoutSession));

  // Database Methods
  void addExerciseFromTemplate(
    ExerciseTemplate template, {
    int? customSets,
    int? customMinReps,
    int? customMaxReps,
    int? customRIR,
    int? customRestTime, // Neuer Parameter
  }) {
    if (_planManager.currentPlan == null || _planManager.currentDay == null)
      return;

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
      restTime: customRestTime ??
          150, // Verwende den übergebenen Wert oder den Standardwert
    );

    _planManager.currentDay!.exercises.add(newExercise);
    _isSelectingFromDatabase = false; // Close selection mode

    // Update plan in database if already saved
    if (_planManager.isPlanSaved) {
      _planManager.updatePlanInDatabase();
    }

    notifyListeners();
  }

  @override
  void notifyListeners() {
    // This is important to ensure state changes propagate correctly
    super.notifyListeners();
  }

  @override
  void dispose() {
    _workoutSession.dispose();
    _strengthCalculator.dispose();
    super.dispose();
  }
}
