// exercise_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';

class ExerciseCategory {
  final String id;
  final String name;

  ExerciseCategory({
    required this.id,
    required this.name,
  });

  factory ExerciseCategory.fromJson(Map<String, dynamic> json) {
    return ExerciseCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ExerciseTemplate {
  final String id;
  final String name;
  final String categoryId;
  final String description;
  final int defaultSets;
  final int defaultMinReps;
  final int defaultMaxReps;
  final int defaultRIR;

  ExerciseTemplate({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.description,
    required this.defaultSets,
    required this.defaultMinReps,
    required this.defaultMaxReps,
    required this.defaultRIR,
  });

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) {
    return ExerciseTemplate(
      id: json['id'],
      name: json['name'],
      categoryId: json['categoryId'],
      description: json['description'],
      defaultSets: json['defaultSets'],
      defaultMinReps: json['defaultMinReps'],
      defaultMaxReps: json['defaultMaxReps'],
      defaultRIR: json['defaultRIR'],
    );
  }

  // Diese Methode wurde entfernt, da wir jetzt benutzerdefinierte Werte im Provider verwenden
}

class ExerciseDatabase {
  late List<ExerciseCategory> categories;
  late List<ExerciseTemplate> exercises;
  bool _isLoaded = false;

  // Singleton pattern
  static final ExerciseDatabase _instance = ExerciseDatabase._internal();

  factory ExerciseDatabase() {
    return _instance;
  }

  ExerciseDatabase._internal();

  bool get isLoaded => _isLoaded;

  Future<void> loadDatabase() async {
    if (_isLoaded) return;

    try {
      // Load the JSON file from assets
      final String jsonString =
          await rootBundle.loadString('assets/data/exercise_database.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Parse categories
      categories = (jsonData['categories'] as List)
          .map((item) => ExerciseCategory.fromJson(item))
          .toList();

      // Parse exercises
      exercises = (jsonData['exercises'] as List)
          .map((item) => ExerciseTemplate.fromJson(item))
          .toList();

      _isLoaded = true;
    } catch (e) {
      print('Error loading exercise database: $e');
      // Initialize with empty lists if loading fails
      categories = [];
      exercises = [];
    }
  }

  // Get all categories
  List<ExerciseCategory> getAllCategories() {
    return categories;
  }

  // Get exercises by category
  List<ExerciseTemplate> getExercisesByCategory(String categoryId) {
    return exercises
        .where((exercise) => exercise.categoryId == categoryId)
        .toList();
  }

  // Get all exercises
  List<ExerciseTemplate> getAllExercises() {
    return exercises;
  }

  // Search exercises by name
  List<ExerciseTemplate> searchExercises(String query) {
    if (query.isEmpty) return exercises;

    String lowercaseQuery = query.toLowerCase();
    return exercises
        .where((exercise) =>
            exercise.name.toLowerCase().contains(lowercaseQuery) ||
            exercise.description.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Get exercise by ID
  ExerciseTemplate? getExerciseById(String id) {
    try {
      return exercises.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category by ID
  ExerciseCategory? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}
