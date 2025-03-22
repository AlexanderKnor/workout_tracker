// home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/workout_provider.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onCreatePressed;
  final Function(TrainingPlan) onEditPressed;
  final Function(TrainingPlan, TrainingDay) onWorkoutPressed;

  const HomeScreen({
    Key? key,
    required this.onCreatePressed,
    required this.onEditPressed,
    required this.onWorkoutPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deine Trainingspläne',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              state.plans.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Du hast noch keine Trainingspläne erstellt.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : Column(
                      children: state.plans
                          .map((plan) => _buildPlanCard(context, plan, state))
                          .toList(),
                    ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onCreatePressed,
                icon: Icon(Icons.add),
                label: Text('Neuen Plan erstellen'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
              if (state.savedWorkouts.isNotEmpty) ...[
                SizedBox(height: 24),
                _buildRecentWorkoutsCard(context, state),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlanCard(
      BuildContext context, TrainingPlan plan, WorkoutTrackerState state) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
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
                    plan.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Wrap icons in a row for more compact layout
                Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => onEditPressed(plan),
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.all(8),
                      tooltip: 'Bearbeiten',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => state.deletePlan(plan.id),
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.all(8),
                      tooltip: 'LÃƒÆ’Ã‚Â¶schen',
                    ),
                  ],
                ),
              ],
            ),
            Text(
              '${plan.trainingDays.length} Trainingstage',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 12),

            // Training Days List
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: plan.trainingDays.length,
                separatorBuilder: (context, index) => Divider(height: 1),
                itemBuilder: (context, index) {
                  TrainingDay day = plan.trainingDays[index];
                  return ListTile(
                    title: Text(day.name),
                    subtitle: Text('${day.exercises.length} ÃƒÆ’Ã…â€œbungen'),
                    trailing: ElevatedButton(
                      onPressed: () => onWorkoutPressed(plan, day),
                      child: Text('Training starten'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        textStyle: TextStyle(fontSize: 14),
                      ),
                    ),
                    dense: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentWorkoutsCard(
      BuildContext context, WorkoutTrackerState state) {
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
              'Letzte Workouts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            ...state.savedWorkouts
                .take(3)
                .map((workout) => _buildWorkoutItem(workout)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutItem(WorkoutLog workout) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Container(
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
                    '${workout.planName} - ${workout.dayName}',
                    style: TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${DateFormat('dd.MM.yyyy').format(workout.date)} ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ${workout.sets.length} SÃƒÆ’Ã‚Â¤tze',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.bar_chart, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
