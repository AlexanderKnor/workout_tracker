// lib/services/database_service.dart
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Pfad zur Datenbank im App-Speicher ermitteln
    String path = join(await getDatabasesPath(), 'workout_tracker.db');

    // Datenbank Ã¶ffnen oder erstellen, wenn sie nicht existiert
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Tabelle fÃ¼r TrainingsplÃ¤ne
    await db.execute('''
      CREATE TABLE training_plans(
        id TEXT PRIMARY KEY,
        name TEXT
      )
    ''');

    // Tabelle fÃ¼r Trainingstage
    await db.execute('''
      CREATE TABLE training_days(
        id TEXT PRIMARY KEY,
        name TEXT,
        plan_id TEXT,
        FOREIGN KEY(plan_id) REFERENCES training_plans(id) ON DELETE CASCADE
      )
    ''');

    // Tabelle fÃ¼r Ãœbungen
    await db.execute('''
      CREATE TABLE exercises(
        id TEXT PRIMARY KEY,
        name TEXT,
        sets INTEGER,
        min_reps INTEGER,
        max_reps INTEGER,
        target_rir INTEGER,
        day_id TEXT,
        category_id TEXT,
        description TEXT,
        FOREIGN KEY(day_id) REFERENCES training_days(id) ON DELETE CASCADE
      )
    ''');

    // Tabelle fÃ¼r Workout-Logs
    await db.execute('''
      CREATE TABLE workout_logs(
        id TEXT PRIMARY KEY,
        date INTEGER,
        plan_id TEXT,
        plan_name TEXT,
        day_id TEXT,
        day_name TEXT
      )
    ''');

    // Tabelle fÃ¼r Set-Logs
    await db.execute('''
      CREATE TABLE set_logs(
        id TEXT PRIMARY KEY,
        workout_id TEXT,
        exercise_id TEXT,
        exercise_name TEXT,
        set_number INTEGER,
        weight REAL,
        reps INTEGER,
        rir INTEGER,
        one_rm REAL,
        FOREIGN KEY(workout_id) REFERENCES workout_logs(id) ON DELETE CASCADE
      )
    ''');

    // Neue Tabelle für App-Einstellungen hinzufügen
    await db.execute('''
      CREATE TABLE app_settings(
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  // -------------------- CRUD Operationen fÃ¼r TrainingsplÃ¤ne --------------------

  // Alle TrainingsplÃ¤ne abrufen
  Future<List<TrainingPlan>> getTrainingPlans() async {
    final Database db = await database;

    // PlÃ¤ne abfragen
    final List<Map<String, dynamic>> planMaps =
        await db.query('training_plans');

    // Leere Liste zurÃ¼ckgeben, wenn keine PlÃ¤ne vorhanden
    if (planMaps.isEmpty) {
      return [];
    }

    // Liste der PlÃ¤ne erstellen
    List<TrainingPlan> plans = [];

    for (var planMap in planMaps) {
      // Trainingstage fÃ¼r diesen Plan abrufen
      final List<Map<String, dynamic>> dayMaps = await db.query(
        'training_days',
        where: 'plan_id = ?',
        whereArgs: [planMap['id']],
      );

      List<TrainingDay> days = [];

      for (var dayMap in dayMaps) {
        // Ãœbungen fÃ¼r diesen Tag abrufen
        final List<Map<String, dynamic>> exerciseMaps = await db.query(
          'exercises',
          where: 'day_id = ?',
          whereArgs: [dayMap['id']],
        );

        List<Exercise> exercises = exerciseMaps.map((exerciseMap) {
          return Exercise(
            id: exerciseMap['id'],
            name: exerciseMap['name'],
            sets: exerciseMap['sets'],
            minReps: exerciseMap['min_reps'],
            maxReps: exerciseMap['max_reps'],
            targetRIR: exerciseMap['target_rir'],
            categoryId: exerciseMap['category_id'],
            description: exerciseMap['description'],
          );
        }).toList();

        days.add(TrainingDay(
          id: dayMap['id'],
          name: dayMap['name'],
          exercises: exercises,
        ));
      }

      plans.add(TrainingPlan(
        id: planMap['id'],
        name: planMap['name'],
        trainingDays: days,
      ));
    }

    return plans;
  }

  // Trainingsplan speichern
  Future<void> saveTrainingPlan(TrainingPlan plan) async {
    final Database db = await database;

    // Transaktion starten, um Datenkonsistenz zu gewÃ¤hrleisten
    await db.transaction((txn) async {
      // Plan speichern
      await txn.insert(
        'training_plans',
        {
          'id': plan.id,
          'name': plan.name,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Alle Trainingstage fÃ¼r diesen Plan speichern
      for (var day in plan.trainingDays) {
        await txn.insert(
          'training_days',
          {
            'id': day.id,
            'name': day.name,
            'plan_id': plan.id,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Alle Ãœbungen fÃ¼r diesen Tag speichern
        for (var exercise in day.exercises) {
          await txn.insert(
            'exercises',
            {
              'id': exercise.id,
              'name': exercise.name,
              'sets': exercise.sets,
              'min_reps': exercise.minReps,
              'max_reps': exercise.maxReps,
              'target_rir': exercise.targetRIR,
              'day_id': day.id,
              'category_id': exercise.categoryId,
              'description': exercise.description,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  // Trainingsplan aktualisieren (kompletten Plan mit Tagen und Ãœbungen)
  Future<void> updateTrainingPlan(TrainingPlan plan) async {
    final Database db = await database;

    // Transaktion starten
    await db.transaction((txn) async {
      // Plan aktualisieren
      await txn.update(
        'training_plans',
        {
          'name': plan.name,
        },
        where: 'id = ?',
        whereArgs: [plan.id],
      );

      // Bestehende Tage und Ãœbungen fÃ¼r diesen Plan abrufen
      final List<Map<String, dynamic>> existingDays = await txn.query(
        'training_days',
        where: 'plan_id = ?',
        whereArgs: [plan.id],
      );

      // Set der IDs der aktualisierten Tage erstellen
      final Set<String> updatedDayIds =
          plan.trainingDays.map((day) => day.id).toSet();

      // Tage lÃ¶schen, die nicht mehr existieren
      for (var existingDay in existingDays) {
        if (!updatedDayIds.contains(existingDay['id'])) {
          await txn.delete(
            'training_days',
            where: 'id = ?',
            whereArgs: [existingDay['id']],
          );
        }
      }

      // Tage und Ãœbungen aktualisieren oder erstellen
      for (var day in plan.trainingDays) {
        // Tag aktualisieren oder erstellen
        await txn.insert(
          'training_days',
          {
            'id': day.id,
            'name': day.name,
            'plan_id': plan.id,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Bestehende Ãœbungen fÃ¼r diesen Tag abrufen
        final List<Map<String, dynamic>> existingExercises = await txn.query(
          'exercises',
          where: 'day_id = ?',
          whereArgs: [day.id],
        );

        // Set der IDs der aktualisierten Ãœbungen erstellen
        final Set<String> updatedExerciseIds =
            day.exercises.map((exercise) => exercise.id).toSet();

        // Ãœbungen lÃ¶schen, die nicht mehr existieren
        for (var existingExercise in existingExercises) {
          if (!updatedExerciseIds.contains(existingExercise['id'])) {
            await txn.delete(
              'exercises',
              where: 'id = ?',
              whereArgs: [existingExercise['id']],
            );
          }
        }

        // Ãœbungen aktualisieren oder erstellen
        for (var exercise in day.exercises) {
          await txn.insert(
            'exercises',
            {
              'id': exercise.id,
              'name': exercise.name,
              'sets': exercise.sets,
              'min_reps': exercise.minReps,
              'max_reps': exercise.maxReps,
              'target_rir': exercise.targetRIR,
              'day_id': day.id,
              'category_id': exercise.categoryId,
              'description': exercise.description,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  // Trainingsplan lÃ¶schen
  Future<void> deleteTrainingPlan(String planId) async {
    final Database db = await database;

    await db.delete(
      'training_plans',
      where: 'id = ?',
      whereArgs: [planId],
    );
  }

  // -------------------- CRUD Operationen fÃ¼r Workout-Logs --------------------

  // Alle Workout-Logs abrufen
  Future<List<WorkoutLog>> getWorkoutLogs() async {
    final Database db = await database;

    // Alle Workout-Logs abfragen
    final List<Map<String, dynamic>> logMaps = await db.query('workout_logs');

    // Leere Liste zurÃ¼ckgeben, wenn keine Logs vorhanden
    if (logMaps.isEmpty) {
      return [];
    }

    // Liste der Workout-Logs erstellen
    List<WorkoutLog> logs = [];

    for (var logMap in logMaps) {
      // Set-Logs fÃ¼r dieses Workout abrufen
      final List<Map<String, dynamic>> setMaps = await db.query(
        'set_logs',
        where: 'workout_id = ?',
        whereArgs: [logMap['id']],
      );

      // Set-Logs mappen
      List<SetLog> sets = setMaps.map((setMap) {
        return SetLog(
          exerciseId: setMap['exercise_id'],
          exerciseName: setMap['exercise_name'],
          set: setMap['set_number'],
          weight: setMap['weight'],
          reps: setMap['reps'],
          rir: setMap['rir'],
          oneRM: setMap['one_rm'],
        );
      }).toList();

      // Workout-Log erstellen
      logs.add(WorkoutLog(
        id: logMap['id'],
        date: DateTime.fromMillisecondsSinceEpoch(logMap['date']),
        planId: logMap['plan_id'],
        planName: logMap['plan_name'],
        dayId: logMap['day_id'],
        dayName: logMap['day_name'],
        sets: sets,
      ));
    }

    return logs;
  }

  // Workout-Log speichern
  Future<void> saveWorkoutLog(WorkoutLog log) async {
    final Database db = await database;

    // Transaktion starten
    await db.transaction((txn) async {
      // Workout-Log speichern
      await txn.insert(
        'workout_logs',
        {
          'id': log.id,
          'date': log.date.millisecondsSinceEpoch,
          'plan_id': log.planId,
          'plan_name': log.planName,
          'day_id': log.dayId,
          'day_name': log.dayName,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Set-Logs speichern
      for (int i = 0; i < log.sets.length; i++) {
        final SetLog setLog = log.sets[i];
        await txn.insert(
          'set_logs',
          {
            'id': '${log.id}_${i}',
            'workout_id': log.id,
            'exercise_id': setLog.exerciseId,
            'exercise_name': setLog.exerciseName,
            'set_number': setLog.set,
            'weight': setLog.weight,
            'reps': setLog.reps,
            'rir': setLog.rir,
            'one_rm': setLog.oneRM,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Methode zum Speichern der aktiven Plan-ID
  Future<void> saveActivePlanId(String planId) async {
    final Database db = await database;
    await db.insert(
      'app_settings',
      {'key': 'active_plan_id', 'value': planId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Methode zum Abrufen der aktiven Plan-ID
  Future<String?> getActivePlanId() async {
    final Database db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'app_settings',
        where: 'key = ?',
        whereArgs: ['active_plan_id'],
      );
      if (maps.isNotEmpty) {
        return maps.first['value'] as String?;
      }
    } catch (e) {
      print('Fehler beim Abrufen der aktiven Plan-ID: $e');
    }
    return null;
  }

  // Datenbank-Wartungsfunktion
  Future<void> deleteAllData() async {
    final Database db = await database;

    await db.delete('set_logs');
    await db.delete('workout_logs');
    await db.delete('exercises');
    await db.delete('training_days');
    await db.delete('training_plans');
    await db.delete('app_settings');
  }
}
