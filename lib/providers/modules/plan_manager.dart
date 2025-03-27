// lib/providers/modules/plan_manager.dart
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/database_service.dart';

class PlanManager {
  final DatabaseService _databaseService;
  final Function _notifyListeners;

  // Plans data
  List<TrainingPlan> _plans = [];
  TrainingPlan? _currentPlan;
  TrainingDay? _currentDay;
  String? _activePlanId;

  // Flag to track if current plan is saved to database
  bool _isPlanSaved = true;

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
  int _newExerciseRestTime =
      150; // Neue Variable für die Satzpause, Standard: 2:30 Minuten

  // Constructor
  PlanManager(this._databaseService, this._notifyListeners) {
    _initDefaultTrainingDayNames();
  }

  // Initialize default training day names
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

  // ======== Getters ========
  List<TrainingPlan> get plans => _plans;
  TrainingPlan? get currentPlan => _currentPlan;
  TrainingDay? get currentDay => _currentDay;
  bool get isPlanSaved => _isPlanSaved;
  String? get activePlanId => _activePlanId;
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
  int get newExerciseRestTime => _newExerciseRestTime; // Neuer Getter

  // Get active plan from the list
  TrainingPlan? get activePlan {
    if (_activePlanId == null) return null;
    try {
      return _plans.firstWhere((plan) => plan.id == _activePlanId);
    } catch (e) {
      return null;
    }
  }

  // ======== Setters ========
  set newPlanName(String value) {
    _newPlanName = value;
    _notifyListeners();
  }

  set numberOfTrainingDays(int value) {
    if (value > 0) {
      _numberOfTrainingDays = value;
      _initDefaultTrainingDayNames();
      _notifyListeners();
    }
  }

  set selectedDayIndex(int value) {
    if (value >= 0 && value < _numberOfTrainingDays) {
      _selectedDayIndex = value;
      _notifyListeners();
    }
  }

  set newExerciseName(String value) {
    _newExerciseName = value;
    _notifyListeners();
  }

  set newExerciseSets(int value) {
    _newExerciseSets = value;
    _notifyListeners();
  }

  set newExerciseMinReps(int value) {
    _newExerciseMinReps = value;
    _notifyListeners();
  }

  set newExerciseMaxReps(int value) {
    _newExerciseMaxReps = value;
    _notifyListeners();
  }

  set newExerciseRIR(int value) {
    _newExerciseRIR = value;
    _notifyListeners();
  }

  set newExerciseDescription(String value) {
    _newExerciseDescription = value;
    _notifyListeners();
  }

  set newExerciseRestTime(int value) {
    _newExerciseRestTime = value;
    _notifyListeners();
  }

  // ======== Methods ========
  void setActivePlanId(String? planId) {
    _activePlanId = planId;
  }

  // Load plans from database
  Future<void> loadPlans() async {
    try {
      _plans = await _databaseService.getTrainingPlans();
    } catch (e) {
      print('Error loading plans: $e');
      _plans = [];
    }
  }

  // Set active plan and save to database
  void setActivePlan(String planId) {
    if (_plans.any((plan) => plan.id == planId)) {
      _activePlanId = planId;
      savePlanActivationState();
      _notifyListeners();
    }
  }

  // Save active plan state to database
  Future<void> savePlanActivationState() async {
    if (_activePlanId != null) {
      try {
        await _databaseService.saveActivePlanId(_activePlanId!);
      } catch (e) {
        print('Error saving active plan state: $e');
      }
    }
  }

  // Set current plan for editing
  void setCurrentPlan(TrainingPlan plan) {
    _currentPlan = plan;
    _isPlanSaved = true; // This is an existing plan from the database

    // Set first day as default if available
    if (plan.trainingDays.isNotEmpty) {
      _currentDay = plan.trainingDays[0];
    } else {
      _currentDay = null;
    }

    _notifyListeners();
  }

  // Set current training day
  void setCurrentDay(TrainingDay day) {
    _currentDay = day;
    _notifyListeners();
  }

  // Update training day name
  void updateTrainingDayName(int index, String name) {
    if (index >= 0 && index < _trainingDayNames.length) {
      _trainingDayNames[index] = name;
      _notifyListeners();
    }
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

    // Set the newly created plan as active
    _activePlanId = newPlan.id;

    if (trainingDays.isNotEmpty) {
      _currentDay = trainingDays[0];
    }

    // Save to database
    try {
      await _databaseService.saveTrainingPlan(newPlan);
      await savePlanActivationState(); // Save active plan state
    } catch (e) {
      print('Error saving new plan: $e');
    }

    // Mark plan as saved
    _isPlanSaved = true;

    // Reset form state
    _newPlanName = '';
    _numberOfTrainingDays = 3;
    _initDefaultTrainingDayNames();
    _selectedDayIndex = 0;

    _notifyListeners();
  }

  // Create plan without saving to database immediately
  Future<void> createDraftPlan() async {
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

    // Set the current plan but don't add to plans list or database yet
    _currentPlan = newPlan;
    if (trainingDays.isNotEmpty) {
      _currentDay = trainingDays[0];
    }

    // Mark as not saved
    _isPlanSaved = false;

    // Reset form state
    _newPlanName = '';
    _numberOfTrainingDays = 3;
    _initDefaultTrainingDayNames();
    _selectedDayIndex = 0;

    _notifyListeners();
  }

  // Check if a plan is valid (has at least one exercise per day)
  bool isPlanValid(TrainingPlan? plan) {
    if (plan == null) return false;

    // Check each day has at least one exercise
    for (var day in plan.trainingDays) {
      if (day.exercises.isEmpty) {
        return false;
      }
    }

    // All days have at least one exercise
    return true;
  }

  // Finalize and save the current plan
  Future<bool> saveCurrentPlan() async {
    if (_currentPlan != null && !_isPlanSaved) {
      // Check if the plan is valid (has at least one exercise per day)
      if (!isPlanValid(_currentPlan)) {
        return false; // Plan is not valid
      }

      // Add to plans list if not already there
      if (!_plans.any((plan) => plan.id == _currentPlan!.id)) {
        _plans.add(_currentPlan!);
      }

      // Set the new plan as active plan
      _activePlanId = _currentPlan!.id;

      // Save to database
      try {
        await _databaseService.saveTrainingPlan(_currentPlan!);
        await savePlanActivationState(); // Save active plan state
        _isPlanSaved = true;
        _notifyListeners();
        return true; // Plan saved successfully
      } catch (e) {
        print('Error saving plan: $e');
        return false; // Error saving plan
      }
    }
    return _isPlanSaved; // Already saved or no current plan
  }

  // Discard the current plan if not saved
  void discardCurrentPlan() {
    if (_currentPlan != null && !_isPlanSaved) {
      _currentPlan = null;
      _currentDay = null;
      _isPlanSaved = true;
      _notifyListeners();
    }
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
      restTime: _newExerciseRestTime, // Setzung der Pausenzeit
    );

    _currentDay!.exercises.add(newExercise);
    _newExerciseName = '';
    _newExerciseDescription = '';
    // _newExerciseRestTime auf den Standardwert zurücksetzen ist optional

    // Update plan in database if already saved
    if (_isPlanSaved) {
      await updatePlanInDatabase();
    }

    _notifyListeners();
  }

  // Delete exercise from current training day
  Future<void> deleteExercise(String exerciseId) async {
    if (_currentPlan == null || _currentDay == null) return;

    _currentDay!.exercises.removeWhere((ex) => ex.id == exerciseId);

    // Update plan in database if already saved
    if (_isPlanSaved) {
      await updatePlanInDatabase();
    }

    _notifyListeners();
  }

  // Delete a training plan
  Future<void> deletePlan(String planId) async {
    _plans.removeWhere((plan) => plan.id == planId);

    // Clear current plan if it was the deleted one
    if (_currentPlan != null && _currentPlan!.id == planId) {
      _currentPlan = null;
      _currentDay = null;
    }

    // If the active plan was deleted, set a new active plan if available
    if (_activePlanId == planId && _plans.isNotEmpty) {
      _activePlanId = _plans.first.id;
      savePlanActivationState();
    } else if (_plans.isEmpty) {
      _activePlanId = null;
    }

    // Delete from database
    try {
      await _databaseService.deleteTrainingPlan(planId);
    } catch (e) {
      print('Error deleting plan: $e');
    }

    _notifyListeners();
  }

  // Update plan in database
  Future<void> updatePlanInDatabase() async {
    if (_currentPlan != null) {
      try {
        await _databaseService.updateTrainingPlan(_currentPlan!);
      } catch (e) {
        print('Error updating plan: $e');
      }
    }
  }
}
