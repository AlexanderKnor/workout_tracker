// edit_plan_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_selector.dart';

class EditPlanScreen extends StatelessWidget {
  final VoidCallback onBackPressed;

  const EditPlanScreen({
    Key? key,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: onBackPressed,
                  tooltip: 'ZurÃƒÆ’Ã‚Â¼ck',
                ),
                Expanded(
                  child: Text(
                    '${state.currentPlan?.name ?? ''} bearbeiten',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Fertig-Button zum Speichern und ZurÃƒÆ’Ã‚Â¼ckkehren
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: () => onBackPressed(),
                    icon: Icon(Icons.check),
                    label: Text('Fertig'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: state.currentPlan != null
                  ? (state.isSelectingFromDatabase
                      ? ExerciseSelector()
                      : _buildPlanContent(context, state))
                  : Center(
                      child: Text('Kein Plan ausgewÃƒÆ’Ã‚Â¤hlt.'),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlanContent(BuildContext context, WorkoutTrackerState state) {
    if (state.currentPlan!.trainingDays.isEmpty) {
      return Center(
        child: Text('Dieser Plan hat keine Trainingstage.'),
      );
    }

    return DefaultTabController(
      length: state.currentPlan!.trainingDays.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              tabs: state.currentPlan!.trainingDays
                  .map((day) => Tab(text: day.name))
                  .toList(),
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black87,
              indicatorColor: Colors.blue,
              indicatorSize: TabBarIndicatorSize.tab,
              onTap: (index) {
                state.setCurrentDay(state.currentPlan!.trainingDays[index]);
              },
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: state.currentPlan!.trainingDays
                  .map((day) => _buildDayContent(context, state, day))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayContent(
      BuildContext context, WorkoutTrackerState state, TrainingDay day) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercises List
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ÃƒÆ’Ã…â€œbungen fÃƒÆ’Ã‚Â¼r ${day.name}',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  day.exercises.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Text(
                            'Keine ÃƒÆ’Ã…â€œbungen hinzugefÃƒÆ’Ã‚Â¼gt.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : Column(
                          children: day.exercises
                              .map((exercise) => _buildExerciseItem(
                                  context, exercise, state, day))
                              .toList(),
                        ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Neue SchaltflÃƒÆ’Ã‚Â¤chen zum HinzufÃƒÆ’Ã‚Â¼gen von ÃƒÆ’Ã…â€œbungen
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ÃƒÆ’Ã…â€œbung hinzufÃƒÆ’Ã‚Â¼gen',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => state.toggleExerciseSelectionMode(),
                          icon: Icon(Icons.fitness_center),
                          label: Text('Aus Datenbank wÃƒÆ’Ã‚Â¤hlen'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showManualExerciseDialog(context, state),
                          icon: Icon(Icons.add),
                          label: Text('Manuell erstellen'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualExerciseDialog(
      BuildContext context, WorkoutTrackerState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ÃƒÆ’Ã…â€œbung manuell erstellen'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'ÃƒÆ’Ã…â€œbungsname',
                  hintText: 'z.B. BankdrÃƒÆ’Ã‚Â¼cken',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) => state.newExerciseName = value,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Beschreibung (optional)',
                  hintText: 'z.B. Mit Langhantel auf flacher Bank',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
                onChanged: (value) => state.newExerciseDescription = value,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SÃƒÆ’Ã‚Â¤tze'),
                        SizedBox(height: 4),
                        TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                              text: state.newExerciseSets.toString()),
                          onChanged: (value) {
                            int? newValue = int.tryParse(value);
                            if (newValue != null && newValue > 0) {
                              state.newExerciseSets = newValue;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Min. Wiederholungen'),
                        SizedBox(height: 4),
                        TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                              text: state.newExerciseMinReps.toString()),
                          onChanged: (value) {
                            int? newValue = int.tryParse(value);
                            if (newValue != null && newValue > 0) {
                              state.newExerciseMinReps = newValue;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Max. Wiederholungen'),
                        SizedBox(height: 4),
                        TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                              text: state.newExerciseMaxReps.toString()),
                          onChanged: (value) {
                            int? newValue = int.tryParse(value);
                            if (newValue != null && newValue > 0) {
                              state.newExerciseMaxReps = newValue;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ziel-RIR'),
                        SizedBox(height: 4),
                        TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                              text: state.newExerciseRIR.toString()),
                          onChanged: (value) {
                            int? newValue = int.tryParse(value);
                            if (newValue != null && newValue >= 0) {
                              state.newExerciseRIR = newValue;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              if (state.newExerciseName.trim().isNotEmpty) {
                state.addExerciseToPlan();
                Navigator.of(context).pop();
              }
            },
            child: Text('HinzufÃƒÆ’Ã‚Â¼gen'),
          ),
        ],
      ),
    );
  }

  void _showEditExerciseDialog(BuildContext context, WorkoutTrackerState state,
      Exercise exercise, TrainingDay day) {
    // Initialisiere TextEditingController mit den Werten der ÃƒÆ’Ã…â€œbung
    final nameController = TextEditingController(text: exercise.name);
    final descriptionController =
        TextEditingController(text: exercise.description ?? '');
    final setsController =
        TextEditingController(text: exercise.sets.toString());
    final minRepsController =
        TextEditingController(text: exercise.minReps.toString());
    final maxRepsController =
        TextEditingController(text: exercise.maxReps.toString());
    final rirController =
        TextEditingController(text: exercise.targetRIR.toString());

    // Lokale Variablen fÃƒÆ’Ã‚Â¼r die Werte
    String name = exercise.name;
    String description = exercise.description ?? '';
    int sets = exercise.sets;
    int minReps = exercise.minReps;
    int maxReps = exercise.maxReps;
    int rir = exercise.targetRIR;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ÃƒÆ’Ã…â€œbung bearbeiten'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'ÃƒÆ’Ã…â€œbungsname',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) => name = value,
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Beschreibung (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
                onChanged: (value) => description = value,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SÃƒÆ’Ã‚Â¤tze'),
                        SizedBox(height: 4),
                        TextField(
                          controller: setsController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            int? newValue = int.tryParse(value);
                            if (newValue != null && newValue > 0) {
                              sets = newValue;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Min. Wiederholungen'),
                        SizedBox(height: 4),
                        TextField(
                          controller: minRepsController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            int? newValue = int.tryParse(value);
                            if (newValue != null && newValue > 0) {
                              minReps = newValue;
                              // Stelle sicher, dass minReps nicht grÃƒÆ’Ã‚Â¶ÃƒÆ’Ã…Â¸er als maxReps ist
                              if (minReps > maxReps) {
                                maxRepsController.text = minReps.toString();
                                maxReps = minReps;
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Max. Wiederholungen'),
                        SizedBox(height: 4),
                        TextField(
                          controller: maxRepsController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            int? newValue = int.tryParse(value);
                            if (newValue != null && newValue > 0) {
                              maxReps = newValue;
                              // Stelle sicher, dass maxReps nicht kleiner als minReps ist
                              if (maxReps < minReps) {
                                minRepsController.text = maxReps.toString();
                                minReps = maxReps;
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ziel-RIR'),
                        SizedBox(height: 4),
                        TextField(
                          controller: rirController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            int? newValue = int.tryParse(value);
                            if (newValue != null && newValue >= 0) {
                              rir = newValue;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.trim().isNotEmpty) {
                // Aktualisiere die ÃƒÆ’Ã…â€œbung mit den neuen Werten
                _updateExercise(state, day, exercise, name, description, sets,
                    minReps, maxReps, rir);
                Navigator.of(context).pop();
              }
            },
            child: Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _updateExercise(
      WorkoutTrackerState state,
      TrainingDay day,
      Exercise oldExercise,
      String name,
      String description,
      int sets,
      int minReps,
      int maxReps,
      int rir) {
    // Finde den Index der alten ÃƒÆ’Ã…â€œbung
    int exerciseIndex =
        day.exercises.indexWhere((ex) => ex.id == oldExercise.id);
    if (exerciseIndex != -1) {
      // Erstelle eine neue ÃƒÆ’Ã…â€œbung mit aktualisierten Werten aber derselben ID
      Exercise updatedExercise = Exercise(
        id: oldExercise.id,
        name: name,
        sets: sets,
        minReps: minReps,
        maxReps: maxReps,
        targetRIR: rir,
        categoryId: oldExercise.categoryId,
        description: description.isNotEmpty ? description : null,
      );

      // Ersetze die alte ÃƒÆ’Ã…â€œbung durch die aktualisierte
      day.exercises[exerciseIndex] = updatedExercise;

      // Benachrichtige Listeners ÃƒÆ’Ã‚Â¼ber die ÃƒÆ’Ã¢â‚¬Å¾nderung
      state.notifyListeners();
    }
  }

  Widget _buildExerciseItem(BuildContext context, Exercise exercise,
      WorkoutTrackerState state, TrainingDay day) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${exercise.sets} SÃƒÆ’Ã‚Â¤tze ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â ${exercise.minReps}-${exercise.maxReps} Wdh @ ${exercise.targetRIR} RIR',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (exercise.description != null &&
                    exercise.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      exercise.description!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bearbeiten-Button hinzugefÃƒÆ’Ã‚Â¼gt
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () =>
                    _showEditExerciseDialog(context, state, exercise, day),
                tooltip: 'Bearbeiten',
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => state.deleteExercise(exercise.id),
                tooltip: 'LÃƒÆ’Ã‚Â¶schen',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
