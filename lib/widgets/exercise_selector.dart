// exercise_selector.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../services/exercise_service.dart';

class ExerciseSelector extends StatelessWidget {
  const ExerciseSelector({Key? key}) : super(key: key);

  // Dialog zur Anpassung der Ãœbungsparameter vor dem HinzufÃ¼gen
  void _showExerciseCustomizationDialog(BuildContext context,
      WorkoutTrackerState state, ExerciseTemplate template) {
    // Initialisiere lokale Werte mit den Standardwerten aus der Vorlage
    int sets = template.defaultSets;
    int minReps = template.defaultMinReps;
    int maxReps = template.defaultMaxReps;
    int rir = template.defaultRIR;

    // Controller fÃ¼r Textfelder
    final setsController = TextEditingController(text: sets.toString());
    final minRepsController = TextEditingController(text: minReps.toString());
    final maxRepsController = TextEditingController(text: maxReps.toString());
    final rirController = TextEditingController(text: rir.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ãœbungsparameter anpassen'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ãœbungsinformationen anzeigen
              Text(
                template.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              if (template.description.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  template.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
              SizedBox(height: 16),

              // Parameteranpassungen
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SÃ¤tze'),
                        SizedBox(height: 4),
                        TextField(
                          controller: setsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            int? parsed = int.tryParse(value);
                            if (parsed != null && parsed > 0) {
                              sets = parsed;
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
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            int? parsed = int.tryParse(value);
                            if (parsed != null && parsed >= 0) {
                              rir = parsed;
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
                        Text('Min. Wiederholungen'),
                        SizedBox(height: 4),
                        TextField(
                          controller: minRepsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            int? parsed = int.tryParse(value);
                            if (parsed != null && parsed > 0) {
                              minReps = parsed;
                              // Stelle sicher, dass minReps nicht grÃ¶ÃŸer als maxReps ist
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
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Max. Wiederholungen'),
                        SizedBox(height: 4),
                        TextField(
                          controller: maxRepsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            int? parsed = int.tryParse(value);
                            if (parsed != null && parsed > 0) {
                              maxReps = parsed;
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
              // Ãœbung mit angepassten Werten hinzufÃ¼gen
              state.addExerciseFromTemplate(template,
                  customSets: sets,
                  customMinReps: minReps,
                  customMaxReps: maxReps,
                  customRIR: rir);
              Navigator.of(context).pop();
            },
            child: Text('HinzufÃ¼gen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        if (!state.isExerciseDbLoaded) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Ãœbungsdatenbank wird geladen...'),
              ],
            ),
          );
        }

        final categories = state.getAllCategories();
        final exercises = state.getFilteredExercises();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ãœbung aus Datenbank auswÃ¤hlen',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'WÃ¤hle eine Ãœbung und passe SÃ¤tze, Wiederholungen und RIR nach deinen WÃ¼nschen an',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => state.toggleExerciseSelectionMode(),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Suchfeld
            TextField(
              decoration: InputDecoration(
                hintText: 'Suche nach Ãœbungen...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => state.exerciseSearchQuery = value,
            ),
            SizedBox(height: 16),

            // Kategorie-Filter
            Container(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip(context, state, '', 'Alle'),
                  ...categories.map((category) => _buildCategoryChip(
                      context, state, category.id, category.name)),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Ãœbungsliste
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return _buildExerciseItem(context, state, exercise);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryChip(BuildContext context, WorkoutTrackerState state,
      String categoryId, String categoryName) {
    final isSelected = state.selectedCategoryId == categoryId;

    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(categoryName),
        selected: isSelected,
        onSelected: (_) => state.selectedCategoryId = categoryId,
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue,
      ),
    );
  }

  Widget _buildExerciseItem(BuildContext context, WorkoutTrackerState state,
      ExerciseTemplate exercise) {
    // Finde die Kategorie fÃ¼r den Ãœbungstyp
    final category = state.getAllCategories().firstWhere(
          (cat) => cat.id == exercise.categoryId,
          orElse: () => ExerciseCategory(id: '', name: ''),
        );

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          exercise.name,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.name.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Chip(
                  label: Text(
                    category.name,
                    style: TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.grey[200],
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            SizedBox(height: 4),
            Text(
              '${exercise.defaultSets} SÃ¤tze | ${exercise.defaultMinReps}-${exercise.defaultMaxReps} Wiederholungen | ${exercise.defaultRIR} RIR',
              style: TextStyle(fontSize: 12),
            ),
            if (exercise.description.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  exercise.description,
                  style: TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.add_circle, color: Colors.green),
          onPressed: () =>
              _showExerciseCustomizationDialog(context, state, exercise),
        ),
        onTap: () => _showExerciseCustomizationDialog(context, state, exercise),
      ),
    );
  }
}
