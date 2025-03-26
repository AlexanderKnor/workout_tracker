// exercise_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../services/exercise_service.dart';

class ExerciseSelector extends StatelessWidget {
  const ExerciseSelector({Key? key}) : super(key: key);

  // Dialog zur Anpassung der Übungsparameter vor dem Hinzufügen
  void _showExerciseCustomizationDialog(BuildContext context,
      WorkoutTrackerState state, ExerciseTemplate template) {
    // Initialisiere lokale Werte mit den Standardwerten aus der Vorlage
    int sets = template.defaultSets;
    int minReps = template.defaultMinReps;
    int maxReps = template.defaultMaxReps;
    int rir = template.defaultRIR;

    // Controller für Textfelder
    final setsController = TextEditingController(text: sets.toString());
    final minRepsController = TextEditingController(text: minReps.toString());
    final maxRepsController = TextEditingController(text: maxReps.toString());
    final rirController = TextEditingController(text: rir.toString());

    // Focus nodes for the dialog fields
    final setsFocus = FocusNode();
    final minRepsFocus = FocusNode();
    final maxRepsFocus = FocusNode();
    final rirFocus = FocusNode();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF1C2F49),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF3D85C6).withOpacity(0.15),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          color: Color(0xFF3D85C6),
                          size: 28,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        template.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (template.description.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          template.description,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Parameteranpassungen
                Text(
                  'Übungsparameter anpassen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 16),

                // Nummer fields - first row
                Row(
                  children: [
                    Expanded(
                      child: _buildStyledNumberField(
                        context: context,
                        label: 'Sätze',
                        controller: setsController,
                        focusNode: setsFocus,
                        onChanged: (value) {
                          int? parsed = int.tryParse(value);
                          if (parsed != null && parsed > 0) {
                            sets = parsed;
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStyledNumberField(
                        context: context,
                        label: 'Ziel-RIR',
                        controller: rirController,
                        focusNode: rirFocus,
                        onChanged: (value) {
                          int? parsed = int.tryParse(value);
                          if (parsed != null && parsed >= 0) {
                            rir = parsed;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Number fields - second row
                Row(
                  children: [
                    Expanded(
                      child: _buildStyledNumberField(
                        context: context,
                        label: 'Min. Wiederholungen',
                        controller: minRepsController,
                        focusNode: minRepsFocus,
                        onChanged: (value) {
                          int? parsed = int.tryParse(value);
                          if (parsed != null && parsed > 0) {
                            minReps = parsed;
                            // Stelle sicher, dass minReps nicht größer als maxReps ist
                            if (minReps > maxReps) {
                              maxRepsController.text = minReps.toString();
                              maxReps = minReps;
                            }
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStyledNumberField(
                        context: context,
                        label: 'Max. Wiederholungen',
                        controller: maxRepsController,
                        focusNode: maxRepsFocus,
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
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Dialog buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          "ABBRECHEN",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Übung mit angepassten Werten hinzufügen
                          state.addExerciseFromTemplate(template,
                              customSets: sets,
                              customMinReps: minReps,
                              customMaxReps: maxReps,
                              customRIR: rir);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "HINZUFÜGEN",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF44CF74),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledNumberField({
    required BuildContext context,
    required String label,
    required Function(String) onChanged,
    required TextEditingController controller,
    required FocusNode focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        SizedBox(height: 8),
        Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
              ),
              // Custom focus border
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Color(0xFF3D85C6),
                  width: 2,
                ),
              ),
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Wert eingeben',
            ),
            onChanged: onChanged,
          ),
        ),
      ],
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
                CircularProgressIndicator(
                  color: Color(0xFF3D85C6),
                ),
                SizedBox(height: 16),
                Text(
                  'Übungsdatenbank wird geladen...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final categories = state.getAllCategories();
        final exercises = state.getFilteredExercises();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            // Suchfeld
            Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  // Custom focus border
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Color(0xFF3D85C6),
                      width: 2,
                    ),
                  ),
                ),
              ),
              child: TextField(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Suche nach Übungen...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                onChanged: (value) => state.exerciseSearchQuery = value,
              ),
            ),
            SizedBox(height: 20),

            // Kategorie-Filter
            Text(
              'KATEGORIEN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: Color(0xFF3D85C6),
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                children: [
                  _buildCategoryChip(context, state, '', 'Alle'),
                  ...categories.map((category) => _buildCategoryChip(
                      context, state, category.id, category.name)),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Übungen Titel
            Text(
              'VERFÜGBARE ÜBUNGEN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: Color(0xFF3D85C6),
              ),
            ),
            SizedBox(height: 12),

            // Übungsliste
            Expanded(
              child: exercises.isEmpty
                  ? Center(
                      child: Text(
                        'Keine Übungen gefunden',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: exercises.length,
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 20),
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
      padding: EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          state.selectedCategoryId = categoryId;
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Color(0xFF3D85C6).withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Color(0xFF3D85C6)
                  : Colors.white.withOpacity(0.1),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            categoryName,
            style: TextStyle(
              color: isSelected
                  ? Color(0xFF3D85C6)
                  : Colors.white.withOpacity(0.8),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseItem(BuildContext context, WorkoutTrackerState state,
      ExerciseTemplate exercise) {
    // Finde die Kategorie für den Übungstyp
    final category = state.getAllCategories().firstWhere(
          (cat) => cat.id == exercise.categoryId,
          orElse: () => ExerciseCategory(id: '', name: ''),
        );

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color(0xFF14253D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              _showExerciseCustomizationDialog(context, state, exercise),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showExerciseCustomizationDialog(
                          context, state, exercise),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF44CF74).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Color(0xFF44CF74),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                if (category.name.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF3D85C6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3D85C6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 8),
                Text(
                  '${exercise.defaultSets} Sätze | ${exercise.defaultMinReps}-${exercise.defaultMaxReps} Wiederholungen | ${exercise.defaultRIR} RIR',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                if (exercise.description.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    exercise.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
