// lib/screens/workout/dialogs/strength_calculator_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/workout_provider.dart';

class StrengthCalculatorDialog extends StatefulWidget {
  const StrengthCalculatorDialog({Key? key}) : super(key: key);

  @override
  _StrengthCalculatorDialogState createState() =>
      _StrengthCalculatorDialogState();
}

class _StrengthCalculatorDialogState extends State<StrengthCalculatorDialog> {
  @override
  void initState() {
    super.initState();

    // Use a post-frame callback to safely update state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<WorkoutTrackerState>(context, listen: false);

      // Set default values for the calculator
      state.testWeight = '';
      state.testReps = '';
      state.targetReps = state.currentExercise != null
          ? state.currentExercise!.minReps.toString()
          : '';
      state.targetRIR = state.currentExercise != null
          ? state.currentExercise!.targetRIR.toString()
          : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        return Dialog(
          backgroundColor: Color(0xFF1C2F49),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24),
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
                            color: Color(0xFF3D85C6).withOpacity(0.2),
                          ),
                          child: Icon(
                            Icons.calculate,
                            color: Color(0xFF3D85C6),
                            size: 28,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Weight Calculator",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Calculate your ideal working weight based on a test set",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Test values section with title
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF14253D),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TEST VALUES",
                          style: TextStyle(
                            color: Color(0xFF3D85C6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Enter the weight and reps for a set where you reached failure (RIR 0)",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStyledCalculatorField(
                                context: context,
                                label: "Test Weight",
                                controller: state.testWeightController,
                                onChanged: (value) {
                                  state.testWeight = value;
                                  setState(() {});
                                },
                                suffix: "kg",
                                accentColor: Color(0xFF3D85C6),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildStyledCalculatorField(
                                context: context,
                                label: "Max Reps",
                                controller: state.testRepsController,
                                onChanged: (value) {
                                  state.testReps = value;
                                  setState(() {});
                                },
                                accentColor: Color(0xFFF1A33C),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Target values section
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF14253D),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TARGET VALUES",
                          style: TextStyle(
                            color: Color(0xFF44CF74),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Enter your target repetitions and RIR for your working sets",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStyledCalculatorField(
                                context: context,
                                label: "Target Reps",
                                controller: state.targetRepsController,
                                onChanged: (value) {
                                  state.targetReps = value;
                                  setState(() {});
                                },
                                accentColor: Color(0xFFF1A33C),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildStyledCalculatorField(
                                context: context,
                                label: "Target RIR",
                                controller: state.targetRIRController,
                                onChanged: (value) {
                                  state.targetRIR = value;
                                  setState(() {});
                                },
                                accentColor: Color(0xFF44CF74),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Calculate button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          state.testWeight.isEmpty || state.testReps.isEmpty
                              ? null
                              : () {
                                  HapticFeedback.selectionClick();
                                  state.safeCalculateIdealWorkingWeight();
                                  setState(() {});
                                },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "CALCULATE",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3D85C6),
                        disabledBackgroundColor:
                            Color(0xFF3D85C6).withOpacity(0.3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Results section, if available
                  if (state.calculatedWeight != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF44CF74).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFF44CF74).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "RESULT",
                            style: TextStyle(
                              color: Color(0xFF44CF74),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "${state.calculatedWeight} kg",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF44CF74),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "for ${state.targetReps} reps @ ${state.targetRIR} RIR",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              state.safeAcceptCalculatedWeight();
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.check, size: 18),
                            label: Text(
                              "APPLY TO CURRENT SET",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF44CF74),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),

                  // Close button
                  if (state.calculatedWeight == null)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "CLOSE",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Styled field for calculator
  Widget _buildStyledCalculatorField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    String? suffix,
    required Color accentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              color: accentColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: accentColor.withOpacity(0.08),
              hintText: '0',
              hintStyle: TextStyle(
                color: accentColor.withOpacity(0.4),
              ),
              suffixText: suffix,
              suffixStyle: TextStyle(
                color: accentColor.withOpacity(0.7),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: accentColor,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
