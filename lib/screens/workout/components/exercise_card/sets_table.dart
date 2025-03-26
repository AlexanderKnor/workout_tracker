// lib/screens/workout/components/exercise_card/sets_table.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../models/models.dart';
import '../../../../providers/workout_provider.dart';

class SetsTable extends StatelessWidget {
  final Exercise exercise;

  const SetsTable({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF1C2F49),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Table header
              _buildTableHeader(),

              // Set rows
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
      },
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFF253B59),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              'Set',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Weight',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Reps',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'RIR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '1RM',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(
      BuildContext context, WorkoutTrackerState state, int index) {
    // Calculate 1RM for this set
    double? oneRM = state.getOneRM(index);
    bool isCurrentSet = index == state.currentSetIndex;
    bool isCompleted = state.currentExerciseSets[index].completed;

    // Get progression suggestion for this set if it's the current set
    bool hasProgressionSuggestion =
        isCurrentSet && state.progressionSuggestion != null;

    return Column(
      children: [
        InkWell(
          onTap: !isCompleted
              ? () {
                  HapticFeedback.selectionClick();
                  state.setCurrentSet(index);
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              color: isCompleted
                  ? Color(0xFF253B59).withOpacity(0.3)
                  : (isCurrentSet ? Color(0xFF3D85C6).withOpacity(0.15) : null),
            ),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: [
                // Set number with visual indicator
                Container(
                  width: 24,
                  height: 24,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Color(0xFF44CF74)
                        : (isCurrentSet
                            ? Color(0xFF3D85C6)
                            : Color(0xFF253B59)),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 14)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),

                // Weight input - wider to fit 3+ digits
                Container(
                  width: 70,
                  margin: EdgeInsets.only(right: 4),
                  child: _buildImprovedTextField(
                    controller: state.weightControllers[index],
                    enabled: isCurrentSet && !isCompleted,
                    onChanged: (value) =>
                        state.updateSetData(index, 'weight', value),
                    suffix: 'kg',
                    hintText: '0',
                    accentColor: Color(0xFF3D85C6),
                    defaultColor: Color(0xFF253B59),
                  ),
                ),

                // Reps input
                Container(
                  width: 50,
                  margin: EdgeInsets.only(right: 4),
                  child: _buildImprovedTextField(
                    controller: state.repsControllers[index],
                    enabled: isCurrentSet && !isCompleted,
                    onChanged: (value) =>
                        state.updateSetData(index, 'reps', value),
                    hintText: '0',
                    accentColor: Color(0xFFF1A33C),
                    defaultColor: Color(0xFF253B59),
                  ),
                ),

                // RIR input
                Container(
                  width: 50,
                  margin: EdgeInsets.only(right: 4),
                  child: _buildImprovedTextField(
                    controller: state.rirControllers[index],
                    enabled: isCurrentSet && !isCompleted,
                    onChanged: (value) =>
                        state.updateSetData(index, 'rir', value),
                    hintText: '0',
                    accentColor: Color(0xFF44CF74),
                    defaultColor: Color(0xFF253B59),
                  ),
                ),

                // 1RM display - with flexible expand
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCurrentSet
                          ? Color(0xFF3D85C6).withOpacity(0.1)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: isCurrentSet
                          ? Border.all(
                              color: Color(0xFF3D85C6).withOpacity(0.3),
                              width: 1,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      oneRM != null ? oneRM.toString() : '-',
                      style: TextStyle(
                        color: isCurrentSet
                            ? Color(0xFF3D85C6)
                            : Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Show progression suggestion directly under the current set
        if (hasProgressionSuggestion)
          _buildProgressionSuggestionRow(context, state),
      ],
    );
  }

  Widget _buildProgressionSuggestionRow(
      BuildContext context, WorkoutTrackerState state) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3D85C6).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Color(0xFF3D85C6),
                size: 14,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  state.progressionSuggestion!.reason,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              // Suggested weight
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF3D85C6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  state.progressionSuggestion!.weight.isEmpty
                      ? "- kg"
                      : "${state.progressionSuggestion!.weight} kg",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3D85C6),
                  ),
                ),
              ),

              // Suggested reps
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Color(0xFFF1A33C).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  state.progressionSuggestion!.reps.isEmpty
                      ? "- reps"
                      : "${state.progressionSuggestion!.reps} reps",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFF1A33C),
                  ),
                ),
              ),

              // Suggested RIR
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF44CF74).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  state.progressionSuggestion!.rir.isEmpty
                      ? "- RIR"
                      : "${state.progressionSuggestion!.rir} RIR",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF44CF74),
                  ),
                ),
              ),

              Spacer(),

              // Apply button
              TextButton(
                onPressed: () => state.safeAcceptProgressionSuggestion(),
                child: Text(
                  "APPLY",
                  style: TextStyle(
                    color: Color(0xFF3D85C6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImprovedTextField({
    required TextEditingController controller,
    required bool enabled,
    required Function(String) onChanged,
    String? suffix,
    String? hintText,
    required Color accentColor,
    required Color defaultColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              color: enabled ? accentColor : Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: enabled ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              hintText: enabled ? hintText : '',
              hintStyle: TextStyle(
                color: accentColor.withOpacity(0.5),
              ),
              suffixText: suffix,
              suffixStyle: TextStyle(
                color: enabled
                    ? accentColor.withOpacity(0.7)
                    : Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
              filled: true,
              fillColor: enabled ? accentColor.withOpacity(0.08) : defaultColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: accentColor,
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: onChanged,
            enabled: enabled,
          ),

          // Subtle enhancement for active field
          if (enabled)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0),
                      accentColor.withOpacity(0.5),
                      accentColor.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
