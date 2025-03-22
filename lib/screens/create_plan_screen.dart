// create_plan_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';

class CreatePlanScreen extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onPlanCreated;

  const CreatePlanScreen({
    Key? key,
    required this.onBackPressed,
    required this.onPlanCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: onBackPressed,
                  tooltip: 'ZurÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¼ck',
                ),
                Expanded(
                  child: Text(
                    'Neuen Trainingsplan erstellen',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                              'Grundinformationen',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Planname',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              decoration: InputDecoration(
                                hintText:
                                    'z.B. GanzkÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¶rperplan',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onChanged: (value) => state.newPlanName = value,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Anzahl der Trainingstage',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: state.numberOfTrainingDays,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: [1, 2, 3, 4, 5, 6].map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value Trainingstage'),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  state.numberOfTrainingDays = newValue;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
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
                              'Trainingstage konfigurieren',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 16),
                            for (int i = 0; i < state.numberOfTrainingDays; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child:
                                    _buildTrainingDayInput(context, state, i),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: state.newPlanName.trim().isEmpty
                            ? null
                            : () {
                                state.createNewPlan();
                                onPlanCreated();
                              },
                        icon: Icon(Icons.save),
                        label: Text('Plan erstellen'),
                      ),
                    ),
                    SizedBox(height: 16), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrainingDayInput(
      BuildContext context, WorkoutTrackerState state, int index) {
    return Row(
      children: [
        Container(
          width: 60,
          child: Text(
            'Tag ${index + 1}:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: state.trainingDayNames[index],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            controller:
                TextEditingController(text: state.trainingDayNames[index]),
            onChanged: (value) {
              if (value.isNotEmpty) {
                state.updateTrainingDayName(index, value);
              }
            },
          ),
        ),
      ],
    );
  }
}
