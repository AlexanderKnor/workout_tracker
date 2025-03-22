// models.dart
import 'package:flutter/material.dart';

// Model Klassen
class Exercise {
  String id;
  String name;
  int sets;
  int minReps;
  int maxReps;
  int targetRIR;
  String? categoryId; // Optional: Kategorie-ID für die Gruppierung
  String? description; // Optional: Beschreibung der Übung

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.minReps,
    required this.maxReps,
    required this.targetRIR,
    this.categoryId,
    this.description,
  });
}

// Neue Klasse für Trainingstag
class TrainingDay {
  String id;
  String name;
  List<Exercise> exercises;

  TrainingDay({
    required this.id,
    required this.name,
    required this.exercises,
  });
}

// Angepasste TrainingPlan-Klasse mit Trainingstagen
class TrainingPlan {
  String id;
  String name;
  List<TrainingDay> trainingDays;

  TrainingPlan({
    required this.id,
    required this.name,
    required this.trainingDays,
  });
}

class SetLog {
  String exerciseId;
  String exerciseName;
  int set;
  double weight;
  int reps;
  int rir;
  double oneRM;

  SetLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.set,
    required this.weight,
    required this.reps,
    required this.rir,
    required this.oneRM,
  });
}

class WorkoutLog {
  String id;
  DateTime date;
  String planId;
  String planName;
  String dayId;
  String dayName;
  List<SetLog> sets;

  WorkoutLog({
    required this.id,
    required this.date,
    required this.planId,
    required this.planName,
    required this.dayId,
    required this.dayName,
    required this.sets,
  });
}

class ProgressionSuggestion {
  String weight;
  String reps;
  String rir;
  String reason;

  ProgressionSuggestion({
    required this.weight,
    required this.reps,
    required this.rir,
    required this.reason,
  });
}

// Modified to store set data for an exercise
class ExerciseSetData {
  String weight;
  String reps;
  String rir;
  bool completed;

  ExerciseSetData({
    this.weight = '',
    this.reps = '',
    this.rir = '',
    this.completed = false,
  });
}
