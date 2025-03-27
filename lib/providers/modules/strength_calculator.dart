// lib/providers/modules/strength_calculator.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/models.dart';
import 'workout_session.dart';

class StrengthCalculator {
  final Function _notifyListeners;

  // State variables
  bool _showStrengthCalculator = false;
  String _testWeight = '';
  String _testReps = '';
  String _targetReps = '';
  String _targetRIR = '';
  double? _calculatedWeight;

  // Text controllers for strength calculator
  late TextEditingController _testWeightController;
  late TextEditingController _testRepsController;
  late TextEditingController _targetRepsController;
  late TextEditingController _targetRIRController;

  // Constructor
  StrengthCalculator(this._notifyListeners) {
    // Initialize controllers
    _testWeightController = TextEditingController(text: _testWeight);
    _testRepsController = TextEditingController(text: _testReps);
    _targetRepsController = TextEditingController(text: _targetReps);
    _targetRIRController = TextEditingController(text: _targetRIR);
  }

  // ======== Getters ========
  bool get showStrengthCalculator => _showStrengthCalculator;
  String get testWeight => _testWeight;
  String get testReps => _testReps;
  String get targetReps => _targetReps;
  String get targetRIR => _targetRIR;
  double? get calculatedWeight => _calculatedWeight;

  TextEditingController get testWeightController => _testWeightController;
  TextEditingController get testRepsController => _testRepsController;
  TextEditingController get targetRepsController => _targetRepsController;
  TextEditingController get targetRIRController => _targetRIRController;

  // ======== Setters ========
  set testWeight(String value) {
    _testWeight = value;
    _testWeightController.text = value;
    _testWeightController.selection = TextSelection.fromPosition(
        TextPosition(offset: _testWeightController.text.length));
    _notifyListeners();
  }

  set testReps(String value) {
    _testReps = value;
    _testRepsController.text = value;
    _testRepsController.selection = TextSelection.fromPosition(
        TextPosition(offset: _testRepsController.text.length));
    _notifyListeners();
  }

  set targetReps(String value) {
    _targetReps = value;
    _targetRepsController.text = value;
    _targetRepsController.selection = TextSelection.fromPosition(
        TextPosition(offset: _targetRepsController.text.length));
    _notifyListeners();
  }

  set targetRIR(String value) {
    _targetRIR = value;
    _targetRIRController.text = value;
    _targetRIRController.selection = TextSelection.fromPosition(
        TextPosition(offset: _targetRIRController.text.length));
    _notifyListeners();
  }

  // ======== Methods ========

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
    if (_testWeight.isEmpty || _testReps.isEmpty) {
      _calculatedWeight = null;
      _notifyListeners();
      return;
    }

    double? weight = double.tryParse(_testWeight);
    int? reps = int.tryParse(_testReps);

    if (weight == null || reps == null || weight <= 0 || reps <= 0) {
      _calculatedWeight = null;
      _notifyListeners();
      return;
    }

    // Calculate 1RM based on test (RIR 0)
    double oneRM = weight * (36 / (37 - reps));

    // Calculate ideal working weight based on user-defined target values
    int userTargetReps =
        int.tryParse(_targetReps) ?? 8; // Default to 8 if not specified
    int userTargetRIR =
        int.tryParse(_targetRIR) ?? 2; // Default to 2 if not specified
    int effectiveReps = userTargetReps + userTargetRIR; // Consider RIR

    // Reverse formula: Weight = 1RM × ((37 - effective reps) / 36)
    double idealWeight = oneRM * ((37 - effectiveReps) / 36);

    // Round to nearest 0.5 kg
    _calculatedWeight = (idealWeight * 2).round() / 2;
    _notifyListeners();
  }

  // Accept calculated weight for current set
  void acceptCalculatedWeight(WorkoutSession session) {
    if (_calculatedWeight != null) {
      session.applyCalculatedWeightToCurrentSet(
          _calculatedWeight, _targetReps, _targetRIR);
    }

    _showStrengthCalculator = false;
    _notifyListeners();
  }

  // Open strength calculator dialog
  void openStrengthCalculator(Exercise? currentExercise) {
    _testWeight = '';
    _testReps = '';
    _targetReps =
        currentExercise != null ? currentExercise.minReps.toString() : '';
    _targetRIR =
        currentExercise != null ? currentExercise.targetRIR.toString() : '';
    _calculatedWeight = null;

    // Update controllers with initial values
    _testWeightController.text = _testWeight;
    _testRepsController.text = _testReps;
    _targetRepsController.text = _targetReps;
    _targetRIRController.text = _targetRIR;

    _showStrengthCalculator = true;
    _notifyListeners();
  }

  // Close strength calculator dialog
  void hideStrengthCalculator() {
    _showStrengthCalculator = false;
    _notifyListeners();
  }

  // Clean up resources
  void dispose() {
    _testWeightController.dispose();
    _testRepsController.dispose();
    _targetRepsController.dispose();
    _targetRIRController.dispose();
  }
}
