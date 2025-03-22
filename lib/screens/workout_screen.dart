// workout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';

class WorkoutScreen extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onFinished;

  const WorkoutScreen({
    Key? key,
    required this.onBackPressed,
    required this.onFinished,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        // Check if all sets of the last exercise are logged
        bool isLastExercise = false;
        bool allSetsLogged = false;

        if (state.currentPlan != null &&
            state.currentDay != null &&
            state.currentExercise != null) {
          int currentExerciseIndex = state.currentDay!.exercises
              .indexWhere((ex) => ex.id == state.currentExercise!.id);
          isLastExercise =
              currentExerciseIndex == state.currentDay!.exercises.length - 1;

          if (isLastExercise) {
            // Check if all sets are logged for the last exercise
            int expectedSets = state.currentExercise!.sets;
            int loggedSets = state.workoutLog
                .where((log) => log.exerciseId == state.currentExercise!.id)
                .length;

            allSetsLogged = loggedSets == expectedSets;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: onBackPressed,
                  tooltip: 'ZurÃƒÂ¼ck',
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        state.currentPlan?.name ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (state.currentDay != null)
                        Text(
                          state.currentDay!.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 48), // Spacer for even layout
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.currentExercise != null && !allSetsLogged)
                      _buildExerciseCard(context, state),
                    if (state.workoutLog.isNotEmpty)
                      _buildWorkoutLogCard(context, state),
                    if (isLastExercise && allSetsLogged)
                      _buildWorkoutCompletedCard(context, state),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Modified to show all sets at once, but with only one active
  Widget _buildExerciseCard(BuildContext context, WorkoutTrackerState state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
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
              state.currentExercise!.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 4),
            Text(
              'Ziel: ${state.currentExercise!.minReps}-${state.currentExercise!.maxReps} Wiederholungen @ ${state.currentExercise!.targetRIR} RIR',
              style: TextStyle(color: Colors.grey[600]),
            ),

            // Progression Suggestion
            if (state.progressionSuggestion != null)
              _buildProgressionSuggestion(context, state, isSmallScreen),

            // Strength Calculator
            if (state.showStrengthCalculator)
              _buildStrengthCalculator(context, state, isSmallScreen),

            SizedBox(height: 16),

            // All sets table - NEW FEATURE
            if (!state.showStrengthCalculator)
              _buildAllSetsTable(context, state),

            SizedBox(height: 16),

            // Action buttons - responsive layout
            isSmallScreen
                ? _buildActionButtonsVertical(context, state)
                : _buildActionButtonsHorizontal(context, state),
          ],
        ),
      ),
    );
  }

  // Build table for all sets
  Widget _buildAllSetsTable(BuildContext context, WorkoutTrackerState state) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text('Satz',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Gewicht',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Wdhl',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('RIR',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('1RM',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: state.currentExerciseSets.length,
            itemBuilder: (context, index) {
              return _buildSetRow(context, state, index);
            },
          ),
        ],
      ),
    );
  }

  // Build a row for a single set
  Widget _buildSetRow(
      BuildContext context, WorkoutTrackerState state, int index) {
    // Calculate 1RM for this set
    double? oneRM = state.getOneRM(index);
    bool isCurrentSet = index == state.currentSetIndex;
    bool isCompleted = state.currentExerciseSets[index].completed;

    return InkWell(
      onTap: !isCompleted ? () => state.setCurrentSet(index) : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
          color: isCompleted
              ? Colors.grey[100]
              : (isCurrentSet ? Colors.blue[50] : null),
        ),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            // Set number
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Text('${index + 1}',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  if (isCompleted)
                    Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.check_circle,
                          color: Colors.green, size: 16),
                    ),
                ],
              ),
            ),

            // Weight input
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.only(right: 4),
                child: TextField(
                  controller: state.weightControllers[index],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onChanged: (value) =>
                      state.updateSetData(index, 'weight', value),
                  enabled: isCurrentSet && !isCompleted,
                ),
              ),
            ),

            // Reps input
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.only(right: 4),
                child: TextField(
                  controller: state.repsControllers[index],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onChanged: (value) =>
                      state.updateSetData(index, 'reps', value),
                  enabled: isCurrentSet && !isCompleted,
                ),
              ),
            ),

            // RIR input
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.only(right: 4),
                child: TextField(
                  controller: state.rirControllers[index],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onChanged: (value) =>
                      state.updateSetData(index, 'rir', value),
                  enabled: isCurrentSet && !isCompleted,
                ),
              ),
            ),

            // 1RM display
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(oneRM != null ? oneRM.toString() : '-'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Vertical layout for action buttons on small screens
  Widget _buildActionButtonsVertical(
      BuildContext context, WorkoutTrackerState state) {
    bool isLastSetOfExercise =
        state.currentSetIndex == state.currentExerciseSets.length - 1;
    bool isCurrentSetCompleted =
        state.currentSetIndex < state.currentExerciseSets.length &&
            state.currentExerciseSets[state.currentSetIndex].completed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: isCurrentSetCompleted
              ? (isLastSetOfExercise ? () => state.moveToNextExercise() : null)
              : () => state.logCurrentSet(),
          icon: Icon(
              isCurrentSetCompleted && isLastSetOfExercise
                  ? Icons.check_circle
                  : Icons.check,
              size: 18),
          label: Text(isCurrentSetCompleted && isLastSetOfExercise
              ? 'ÃƒÅ“bung abschlieÃƒÅ¸en'
              : 'Satz abhaken'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrentSetCompleted && isLastSetOfExercise
                ? Colors.green
                : Colors.blue,
            minimumSize: Size(double.infinity, 48),
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => state.skipExercise(),
                icon: Icon(Icons.close, size: 18),
                label: Text('ÃƒÅ“berspringen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => state.openStrengthCalculator(),
                child: Text('Kraftrechner'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Horizontal layout for action buttons on larger screens
  Widget _buildActionButtonsHorizontal(
      BuildContext context, WorkoutTrackerState state) {
    bool isLastSetOfExercise =
        state.currentSetIndex == state.currentExerciseSets.length - 1;
    bool isCurrentSetCompleted =
        state.currentSetIndex < state.currentExerciseSets.length &&
            state.currentExerciseSets[state.currentSetIndex].completed;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => state.skipExercise(),
              icon: Icon(Icons.close, size: 18),
              label: Text('ÃƒÅ“berspringen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black87,
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => state.openStrengthCalculator(),
              child: Text('Kraftrechner'),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: isCurrentSetCompleted
              ? (isLastSetOfExercise ? () => state.moveToNextExercise() : null)
              : () => state.logCurrentSet(),
          icon: Icon(
              isCurrentSetCompleted && isLastSetOfExercise
                  ? Icons.check_circle
                  : Icons.check,
              size: 18),
          label: Text(isCurrentSetCompleted && isLastSetOfExercise
              ? 'ÃƒÅ“bung abschlieÃƒÅ¸en'
              : 'Satz abhaken'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrentSetCompleted && isLastSetOfExercise
                ? Colors.green
                : Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressionSuggestion(
      BuildContext context, WorkoutTrackerState state, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Progressions-Vorschlag:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => state.acceptProgressionSuggestion(),
                icon: Icon(Icons.thumb_up, size: 14),
                label: Text('ÃƒÅ“bernehmen'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size(0, 36),
                  textStyle: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            state.progressionSuggestion!.reason,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          SizedBox(height: 8),
          // Responsive layout for suggestion stats
          isSmallScreen
              ? _buildProgressionSuggestionStatsVertical(state)
              : _buildProgressionSuggestionStatsHorizontal(state),
        ],
      ),
    );
  }

  // Vertical layout for progression suggestion stats
  Widget _buildProgressionSuggestionStatsVertical(WorkoutTrackerState state) {
    return Column(
      children: [
        _buildSuggestionStatItem('Gewicht',
            '${state.progressionSuggestion!.weight.isEmpty ? "-" : state.progressionSuggestion!.weight} kg'),
        SizedBox(height: 8),
        _buildSuggestionStatItem(
            'Wdh',
            state.progressionSuggestion!.reps.isEmpty
                ? "-"
                : state.progressionSuggestion!.reps),
        SizedBox(height: 8),
        _buildSuggestionStatItem(
            'RIR',
            state.progressionSuggestion!.rir.isEmpty
                ? "-"
                : state.progressionSuggestion!.rir),
        SizedBox(height: 8),
        _buildSuggestionStatItem('1RM',
            '${state.calculate1RM(state.progressionSuggestion!.weight, state.progressionSuggestion!.reps, state.progressionSuggestion!.rir)?.toString() ?? "-"} kg'),
      ],
    );
  }

  // Horizontal layout for progression suggestion stats
  Widget _buildProgressionSuggestionStatsHorizontal(WorkoutTrackerState state) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text(
                  'Gewicht',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${state.progressionSuggestion!.weight.isEmpty ? "-" : state.progressionSuggestion!.weight} kg',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text(
                  'Wdh',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  state.progressionSuggestion!.reps.isEmpty
                      ? "-"
                      : state.progressionSuggestion!.reps,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text(
                  'RIR',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  state.progressionSuggestion!.rir.isEmpty
                      ? "-"
                      : state.progressionSuggestion!.rir,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text(
                  '1RM',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${state.calculate1RM(state.progressionSuggestion!.weight, state.progressionSuggestion!.reps, state.progressionSuggestion!.rir)?.toString() ?? "-"} kg',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper for vertical suggestion stat item
  Widget _buildSuggestionStatItem(String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthCalculator(
      BuildContext context, WorkoutTrackerState state, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kraftrechner:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Gib dein Maximalgewicht (RIR 0) ein, um dein ideales Arbeitsgewicht zu berechnen.',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          SizedBox(height: 12),
          // Responsive test weight inputs
          isSmallScreen
              ? Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Testgewicht (kg)'),
                        SizedBox(height: 4),
                        TextField(
                          controller: state.testWeightController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'z.B. 100',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) => state.testWeight = value,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Max. Wiederholungen (RIR 0)'),
                        SizedBox(height: 4),
                        TextField(
                          controller: state.testRepsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'z.B. 5',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) => state.testReps = value,
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Testgewicht (kg)'),
                          SizedBox(height: 4),
                          TextField(
                            controller: state.testWeightController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: 'z.B. 100',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) => state.testWeight = value,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Max. Wiederholungen (RIR 0)'),
                          SizedBox(height: 4),
                          TextField(
                            controller: state.testRepsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'z.B. 5',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) => state.testReps = value,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

          SizedBox(height: 16),
          Text(
            'Zielwerte fÃƒÂ¼r die Berechnung:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 8),
          // Responsive target inputs
          isSmallScreen
              ? Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ziel-Wiederholungen'),
                        SizedBox(height: 4),
                        TextField(
                          controller: state.targetRepsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: state.currentExercise != null
                                ? state.currentExercise!.minReps.toString()
                                : '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) => state.targetReps = value,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ziel-RIR'),
                        SizedBox(height: 4),
                        TextField(
                          controller: state.targetRIRController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: state.currentExercise != null
                                ? state.currentExercise!.targetRIR.toString()
                                : '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) => state.targetRIR = value,
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ziel-Wiederholungen'),
                          SizedBox(height: 4),
                          TextField(
                            controller: state.targetRepsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: state.currentExercise != null
                                  ? state.currentExercise!.minReps.toString()
                                  : '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) => state.targetReps = value,
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
                            controller: state.targetRIRController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: state.currentExercise != null
                                  ? state.currentExercise!.targetRIR.toString()
                                  : '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) => state.targetRIR = value,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

          SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: state.testWeight.isEmpty || state.testReps.isEmpty
                  ? null
                  : () => state.calculateIdealWorkingWeight(),
              child: Text('Berechnen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ),

          if (state.calculatedWeight != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Empfohlenes Arbeitsgewicht fÃƒÂ¼r ${int.tryParse(state.targetReps) ?? state.currentExercise!.minReps} Wiederholungen mit ${int.tryParse(state.targetRIR) ?? state.currentExercise!.targetRIR} RIR:',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${state.calculatedWeight} kg',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 12),
          // Responsive calculator action buttons
          isSmallScreen
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.calculatedWeight != null)
                      ElevatedButton(
                        onPressed: () => state.acceptCalculatedWeight(),
                        child: Text('Gewicht ÃƒÂ¼bernehmen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: Size(double.infinity, 48),
                        ),
                      ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => state.hideStrengthCalculator(),
                      child: Text('Abbrechen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => state.hideStrengthCalculator(),
                      child: Text('Abbrechen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                      ),
                    ),
                    if (state.calculatedWeight != null)
                      ElevatedButton(
                        onPressed: () => state.acceptCalculatedWeight(),
                        child: Text('Gewicht ÃƒÂ¼bernehmen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildWorkoutLogCard(BuildContext context, WorkoutTrackerState state) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Card(
      margin: EdgeInsets.only(top: 16),
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
              'Training Log',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: isSmallScreen
                      ? _buildCompactWorkoutLogTable(state)
                      : _buildFullWorkoutLogTable(state),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Compact table for small screens
  Widget _buildCompactWorkoutLogTable(WorkoutTrackerState state) {
    return Table(
      columnWidths: {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        3: IntrinsicColumnWidth(),
      },
      border: TableBorder(
        bottom: BorderSide(color: Colors.grey[300]!),
        horizontalInside: BorderSide(color: Colors.grey[300]!),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[400]!)),
          ),
          children: [
            _buildTableHeader('ÃƒÅ“bung / Satz'),
            _buildTableHeader('Kg'),
            _buildTableHeader('Wdh'),
            _buildTableHeader('RIR'),
          ],
        ),
        ...state.workoutLog.map((log) => TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.exerciseName,
                        style: TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Satz ${log.set}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildTableCell('${log.weight}'),
                _buildTableCell('${log.reps}'),
                _buildTableCell('${log.rir}'),
              ],
            )),
      ],
    );
  }

  // Full table for larger screens
  Widget _buildFullWorkoutLogTable(WorkoutTrackerState state) {
    return Table(
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(1.5),
      },
      border: TableBorder(
        bottom: BorderSide(color: Colors.grey[300]!),
        horizontalInside: BorderSide(color: Colors.grey[300]!),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[400]!)),
          ),
          children: [
            _buildTableHeader('ÃƒÅ“bung'),
            _buildTableHeader('Satz'),
            _buildTableHeader('Gewicht'),
            _buildTableHeader('Wdh'),
            _buildTableHeader('RIR'),
            _buildTableHeader('1RM'),
          ],
        ),
        ...state.workoutLog.map((log) => TableRow(
              children: [
                _buildTableCell(log.exerciseName),
                _buildTableCell('${log.set}'),
                _buildTableCell('${log.weight} kg'),
                _buildTableCell('${log.reps}'),
                _buildTableCell('${log.rir}'),
                _buildTableCell('${log.oneRM} kg'),
              ],
            )),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(text),
    );
  }

  Widget _buildWorkoutCompletedCard(
      BuildContext context, WorkoutTrackerState state) {
    return Card(
      margin: EdgeInsets.only(top: 16),
      color: Colors.green[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Training abgeschlossen! Ã°Å¸â€™Âª',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Alle SÃƒÂ¤tze wurden erfolgreich protokolliert.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                state.finishWorkout();
                onFinished(); // Hier rufen wir onFinished auf, um zur Hauptseite zurÃƒÂ¼ckzukehren
              },
              icon: Icon(Icons.check),
              label: Text('Training beenden und speichern'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
