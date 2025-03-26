// workout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import 'dart:ui';

class WorkoutScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onFinished;

  const WorkoutScreen({
    Key? key,
    required this.onBackPressed,
    required this.onFinished,
  }) : super(key: key);

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showElevation = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade-in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _fadeController.forward();

    // Scroll listener for elevation
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_showElevation) {
      setState(() {
        _showElevation = true;
      });
    } else if (_scrollController.offset <= 0 && _showElevation) {
      setState(() {
        _showElevation = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

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

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1626),
                  Color(0xFF14253D),
                ],
              ),
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context, state),

                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ListView(
                          controller: _scrollController,
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 100),
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==== HEADER SECTION ====
  Widget _buildHeader(BuildContext context, WorkoutTrackerState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: BoxDecoration(
        color: _showElevation ? Color(0xFF0F1A2A) : Colors.transparent,
        boxShadow: _showElevation
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onBackPressed();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

          // Title - centered with Expanded
          Expanded(
            child: Column(
              children: [
                Text(
                  "ACTIVE WORKOUT",
                  style: TextStyle(
                    color: Color(0xFF44CF74),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  state.currentPlan?.name ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                if (state.currentDay != null)
                  Text(
                    state.currentDay!.name,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Spacer for balance
          SizedBox(width: 40),
        ],
      ),
    );
  }

  // ==== EXERCISE CARD SECTION ====
  Widget _buildExerciseCard(BuildContext context, WorkoutTrackerState state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF14253D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise header with target info badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF3D85C6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: Color(0xFF3D85C6),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.currentExercise!.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF1C2F49),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Target: ${state.currentExercise!.minReps}-${state.currentExercise!.maxReps} reps @ ${state.currentExercise!.targetRIR} RIR',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Track Sets Section - Core focus area
            SizedBox(height: 24),
            Text(
              'TRACK SETS',
              style: TextStyle(
                color: Color(0xFF3D85C6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 12),
            _buildAllSetsTable(context, state),

            SizedBox(height: 24),

            // Action buttons - responsive layout
            isSmallScreen
                ? _buildActionButtonsVertical(context, state)
                : _buildActionButtonsHorizontal(context, state),
          ],
        ),
      ),
    );
  }

  // Suggestion chip that can be tapped to show the suggestion in a dialog
  Widget _buildSuggestionButton(
      BuildContext context, WorkoutTrackerState state) {
    return InkWell(
      onTap: () => _showProgressionSuggestionDialog(context, state),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Color(0xFF3D85C6).withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color(0xFF3D85C6).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.trending_up,
              color: Color(0xFF3D85C6),
              size: 14,
            ),
            SizedBox(width: 4),
            Text(
              'Progression',
              style: TextStyle(
                color: Color(0xFF3D85C6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Progression suggestion dialog
  void _showProgressionSuggestionDialog(
      BuildContext context, WorkoutTrackerState state) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF1C2F49),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF3D85C6).withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: Color(0xFF3D85C6),
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progression Suggestion',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'For ${state.currentExercise!.name} - Set ${state.currentSetIndex + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Reason
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  state.progressionSuggestion!.reason,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Suggested values
              Row(
                children: [
                  _buildSuggestionValueItem(
                      'Weight',
                      state.progressionSuggestion!.weight.isEmpty
                          ? "-"
                          : '${state.progressionSuggestion!.weight} kg',
                      Color(0xFF3D85C6)),
                  SizedBox(width: 10),
                  _buildSuggestionValueItem(
                      'Reps',
                      state.progressionSuggestion!.reps.isEmpty
                          ? "-"
                          : state.progressionSuggestion!.reps,
                      Color(0xFFF1A33C)),
                  SizedBox(width: 10),
                  _buildSuggestionValueItem(
                      'RIR',
                      state.progressionSuggestion!.rir.isEmpty
                          ? "-"
                          : state.progressionSuggestion!.rir,
                      Color(0xFF44CF74)),
                ],
              ),
              SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'CLOSE',
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
                        state.acceptProgressionSuggestion();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'APPLY',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3D85C6),
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
    );
  }

  // Value display for progression suggestion
  Widget _buildSuggestionValueItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ==== SETS TABLE SECTION ====
  // Build table for all sets
  Widget _buildAllSetsTable(BuildContext context, WorkoutTrackerState state) {
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
          Container(
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
          ),

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
  }

  // Build a row for a single set
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
          Container(
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
                      onPressed: () => state.acceptProgressionSuggestion(),
                      child: Text(
                        "APPLY",
                        style: TextStyle(
                          color: Color(0xFF3D85C6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Improved text field for tracking
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

  // ==== ACTION BUTTONS SECTION ====
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
              ? 'Complete Exercise'
              : 'Log Set'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrentSetCompleted && isLastSetOfExercise
                ? Color(0xFF44CF74)
                : Color(0xFF3D85C6),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
        SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _showStrengthCalculatorDialog(context, state),
          icon: Icon(Icons.calculate, size: 18),
          label: Text('Calculator'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1C2F49),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            elevation: 0,
          ),
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
        ElevatedButton.icon(
          onPressed: () => _showStrengthCalculatorDialog(context, state),
          icon: Icon(Icons.calculate, size: 18),
          label: Text('Calculator'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1C2F49),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            elevation: 0,
          ),
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
              ? 'Complete Exercise'
              : 'Log Set'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrentSetCompleted && isLastSetOfExercise
                ? Color(0xFF44CF74)
                : Color(0xFF3D85C6),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  // ==== STRENGTH CALCULATOR DIALOG ====
  void _showStrengthCalculatorDialog(
      BuildContext context, WorkoutTrackerState state) {
    // Reset calculator state when opening
    state.testWeight = '';
    state.testReps = '';
    state.targetReps = state.currentExercise != null
        ? state.currentExercise!.minReps.toString()
        : '';
    state.targetRIR = state.currentExercise != null
        ? state.currentExercise!.targetRIR.toString()
        : '';
    state.hideStrengthCalculator(); // Reset calculated weight

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF1C2F49),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
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
                                    state.calculateIdealWorkingWeight();
                                    setState(() {});
                                  },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text("CALCULATE"),
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
                                state.acceptCalculatedWeight();
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.check, size: 18),
                              label: Text("APPLY TO CURRENT SET"),
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
            );
          },
        ),
      ),
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

  // ==== WORKOUT LOG SECTION ====
  Widget _buildWorkoutLogCard(BuildContext context, WorkoutTrackerState state) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF14253D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF3D85C6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.history,
                        color: Color(0xFF3D85C6),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'SESSION LOG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: Color(0xFF3D85C6),
                      ),
                    ),
                  ],
                ),
                // Exercise count pill
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Color(0xFF1C2F49),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${state.workoutLog.length} sets',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(
                maxHeight: 200,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
        verticalInside: BorderSide(color: Colors.white.withOpacity(0.05)),
        horizontalInside: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Color(0xFF253B59),
          ),
          children: [
            _buildTableHeader('Exercise / Set'),
            _buildTableHeader('Kg'),
            _buildTableHeader('Reps'),
            _buildTableHeader('RIR'),
          ],
        ),
        ...state.workoutLog.map((log) => TableRow(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.exerciseName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        'Set ${log.set}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
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
        verticalInside: BorderSide(color: Colors.white.withOpacity(0.05)),
        horizontalInside: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Color(0xFF253B59),
          ),
          children: [
            _buildTableHeader('Exercise'),
            _buildTableHeader('Set'),
            _buildTableHeader('Weight'),
            _buildTableHeader('Reps'),
            _buildTableHeader('RIR'),
            _buildTableHeader('1RM'),
          ],
        ),
        ...state.workoutLog.map((log) => TableRow(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Text(
                    log.exerciseName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
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
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 13,
        ),
      ),
    );
  }

  // ==== WORKOUT COMPLETED SECTION ====
  Widget _buildWorkoutCompletedCard(
      BuildContext context, WorkoutTrackerState state) {
    return Container(
      margin: EdgeInsets.only(top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: Color(0xFF14253D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Color(0xFF44CF74).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Success icon
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF44CF74).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Color(0xFF44CF74),
                size: 48,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Workout completed! 🎉',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF44CF74),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'All sets have been successfully logged.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                state.finishWorkout();
                widget.onFinished();
              },
              icon: Icon(Icons.check, size: 18),
              label: Text('FINISH WORKOUT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF44CF74),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
