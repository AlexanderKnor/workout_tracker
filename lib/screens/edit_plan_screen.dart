// edit_plan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_selector.dart';

class EditPlanScreen extends StatefulWidget {
  final VoidCallback onBackPressed;

  const EditPlanScreen({
    Key? key,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  _EditPlanScreenState createState() => _EditPlanScreenState();
}

class _EditPlanScreenState extends State<EditPlanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _showElevation = false;
  final ScrollController _scrollController = ScrollController();

  // Focus nodes for highlighting text fields on focus
  final Map<String, FocusNode> _focusNodes = {};

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

  // Get a focus node for a field, creating one if it doesn't exist
  FocusNode _getFocusNode(String fieldId) {
    if (!_focusNodes.containsKey(fieldId)) {
      final focusNode = FocusNode();
      focusNode.addListener(() {
        setState(() {}); // Rebuild when focus changes
      });
      _focusNodes[fieldId] = focusNode;
    }
    return _focusNodes[fieldId]!;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    // Dispose all focus nodes
    _focusNodes.forEach((_, node) => node.dispose());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
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
                child: state.isSelectingFromDatabase
                    ? _buildExerciseSelectorWrapper(state)
                    : _buildMainContent(context, state),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseSelectorWrapper(WorkoutTrackerState state) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          _buildHeader(context, state, inSelectionMode: true),
          SizedBox(height: 16),
          Expanded(child: ExerciseSelector()),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, WorkoutTrackerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        _buildHeader(context, state, inSelectionMode: false),

        // Main content area
        Expanded(
          child: state.currentPlan != null
              ? _buildPlanContent(context, state)
              : Center(
                  child: Text(
                    'No plan selected.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WorkoutTrackerState state,
      {required bool inSelectionMode}) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                if (inSelectionMode) {
                  state.toggleExerciseSelectionMode();
                } else {
                  widget.onBackPressed();
                }
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

          // Title
          Column(
            children: [
              Text(
                inSelectionMode ? "ADD EXERCISE" : "EDIT PLAN",
                style: TextStyle(
                  color: Color(0xFF3D85C6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                inSelectionMode
                    ? "Choose from database"
                    : state.currentPlan?.name ?? "Customize your workout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Done button or spacer
          inSelectionMode
              ? SizedBox(width: 40)
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.onBackPressed();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Color(0xFF44CF74).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF44CF74).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "DONE",
                        style: TextStyle(
                          color: Color(0xFF44CF74),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPlanContent(BuildContext context, WorkoutTrackerState state) {
    if (state.currentPlan!.trainingDays.isEmpty) {
      return Center(
        child: Text(
          'This plan has no training days.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return DefaultTabController(
      length: state.currentPlan!.trainingDays.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab bar with days
          Container(
            margin: EdgeInsets.fromLTRB(20, 16, 20, 0),
            decoration: BoxDecoration(
              color: Color(0xFF1C2F49),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: TabBar(
              tabs: state.currentPlan!.trainingDays
                  .map((day) => Tab(text: day.name))
                  .toList(),
              labelColor: Color(0xFF3D85C6),
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              indicatorColor: Color(0xFF3D85C6),
              indicatorSize: TabBarIndicatorSize.tab,
              onTap: (index) {
                state.setCurrentDay(state.currentPlan!.trainingDays[index]);
              },
            ),
          ),
          SizedBox(height: 16),

          // Tab content
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 100),
        children: [
          // Exercises Card
          _buildExercisesCard(context, state, day),

          SizedBox(height: 20),

          // Add Exercise Card
          _buildAddExerciseCard(context, state),
        ],
      ),
    );
  }

  Widget _buildExercisesCard(
      BuildContext context, WorkoutTrackerState state, TrainingDay day) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: Color(0xFF3D85C6),
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Exercises for ${day.name}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (day.exercises.isEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1C2F49),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'No exercises added yet.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: day.exercises.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.white.withOpacity(0.1),
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                return _buildExerciseItem(
                    context, day.exercises[index], state, day);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(BuildContext context, Exercise exercise,
      WorkoutTrackerState state, TrainingDay day) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${exercise.sets} sets · ${exercise.minReps}-${exercise.maxReps} reps @ ${exercise.targetRIR} RIR',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                if (exercise.description != null &&
                    exercise.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      exercise.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
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
              // Edit button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      _showEditExerciseDialog(context, state, exercise, day),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF1C2F49),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF3D85C6),
                      size: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Delete button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => state.deleteExercise(exercise.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF1C2F49),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Color(0xFFF95738),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddExerciseCard(
      BuildContext context, WorkoutTrackerState state) {
    return Container(
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
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Color(0xFF44CF74),
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Add Exercise',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.fitness_center,
                  text: 'From Database',
                  color: Color(0xFF3D85C6),
                  onTap: () => state.toggleExerciseSelectionMode(),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add,
                  text: 'Create Custom',
                  color: Color(0xFF44CF74),
                  onTap: () => _showManualExerciseDialog(context, state),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManualExerciseDialog(
      BuildContext context, WorkoutTrackerState state) {
    // Create focus nodes for the dialog fields
    final nameFocus = _getFocusNode('newExercise_name');
    final descFocus = _getFocusNode('newExercise_desc');
    final setsFocus = _getFocusNode('newExercise_sets');
    final minRepsFocus = _getFocusNode('newExercise_minReps');
    final maxRepsFocus = _getFocusNode('newExercise_maxReps');
    final rirFocus = _getFocusNode('newExercise_rir');

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
                          color: Color(0xFF44CF74).withOpacity(0.15),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          color: Color(0xFF44CF74),
                          size: 28,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Create Custom Exercise",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Exercise Name Field
                _buildStyledTextField(
                  label: 'Exercise Name',
                  hint: 'e.g. Bench Press',
                  focusNode: nameFocus,
                  onChanged: (value) => state.newExerciseName = value,
                ),
                SizedBox(height: 16),

                // Description Field
                _buildStyledTextField(
                  label: 'Description (optional)',
                  hint: 'e.g. Barbell on flat bench',
                  maxLines: 2,
                  focusNode: descFocus,
                  onChanged: (value) => state.newExerciseDescription = value,
                ),
                SizedBox(height: 16),

                // Number fields - first row
                Row(
                  children: [
                    Expanded(
                      child: _buildStyledNumberField(
                        label: 'Sets',
                        initialValue: state.newExerciseSets.toString(),
                        focusNode: setsFocus,
                        onChanged: (value) {
                          int? newValue = int.tryParse(value);
                          if (newValue != null && newValue > 0) {
                            state.newExerciseSets = newValue;
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStyledNumberField(
                        label: 'Min Reps',
                        initialValue: state.newExerciseMinReps.toString(),
                        focusNode: minRepsFocus,
                        onChanged: (value) {
                          int? newValue = int.tryParse(value);
                          if (newValue != null && newValue > 0) {
                            state.newExerciseMinReps = newValue;
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
                        label: 'Max Reps',
                        initialValue: state.newExerciseMaxReps.toString(),
                        focusNode: maxRepsFocus,
                        onChanged: (value) {
                          int? newValue = int.tryParse(value);
                          if (newValue != null && newValue > 0) {
                            state.newExerciseMaxReps = newValue;
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStyledNumberField(
                        label: 'Target RIR',
                        initialValue: state.newExerciseRIR.toString(),
                        focusNode: rirFocus,
                        onChanged: (value) {
                          int? newValue = int.tryParse(value);
                          if (newValue != null && newValue >= 0) {
                            state.newExerciseRIR = newValue;
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
                          "CANCEL",
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
                          if (state.newExerciseName.trim().isNotEmpty) {
                            state.addExerciseToPlan();
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          "ADD",
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

  void _showEditExerciseDialog(BuildContext context, WorkoutTrackerState state,
      Exercise exercise, TrainingDay day) {
    // Initialize TextEditingControllers with the exercise values
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

    // Create focus nodes for the dialog fields
    final nameFocus = _getFocusNode('editExercise_name_${exercise.id}');
    final descFocus = _getFocusNode('editExercise_desc_${exercise.id}');
    final setsFocus = _getFocusNode('editExercise_sets_${exercise.id}');
    final minRepsFocus = _getFocusNode('editExercise_minReps_${exercise.id}');
    final maxRepsFocus = _getFocusNode('editExercise_maxReps_${exercise.id}');
    final rirFocus = _getFocusNode('editExercise_rir_${exercise.id}');

    // Local variables for the values
    String name = exercise.name;
    String description = exercise.description ?? '';
    int sets = exercise.sets;
    int minReps = exercise.minReps;
    int maxReps = exercise.maxReps;
    int rir = exercise.targetRIR;

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
                          Icons.edit,
                          color: Color(0xFF3D85C6),
                          size: 28,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Edit Exercise",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Exercise Name Field
                _buildStyledTextField(
                  label: 'Exercise Name',
                  controller: nameController,
                  focusNode: nameFocus,
                  onChanged: (value) => name = value,
                ),
                SizedBox(height: 16),

                // Description Field
                _buildStyledTextField(
                  label: 'Description (optional)',
                  controller: descriptionController,
                  focusNode: descFocus,
                  maxLines: 2,
                  onChanged: (value) => description = value,
                ),
                SizedBox(height: 16),

                // Number fields - first row
                Row(
                  children: [
                    Expanded(
                      child: _buildStyledNumberField(
                        label: 'Sets',
                        controller: setsController,
                        focusNode: setsFocus,
                        onChanged: (value) {
                          int? newValue = int.tryParse(value);
                          if (newValue != null && newValue > 0) {
                            sets = newValue;
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStyledNumberField(
                        label: 'Min Reps',
                        controller: minRepsController,
                        focusNode: minRepsFocus,
                        onChanged: (value) {
                          int? newValue = int.tryParse(value);
                          if (newValue != null && newValue > 0) {
                            minReps = newValue;
                            // Make sure minReps is not greater than maxReps
                            if (minReps > maxReps) {
                              maxRepsController.text = minReps.toString();
                              maxReps = minReps;
                            }
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
                        label: 'Max Reps',
                        controller: maxRepsController,
                        focusNode: maxRepsFocus,
                        onChanged: (value) {
                          int? newValue = int.tryParse(value);
                          if (newValue != null && newValue > 0) {
                            maxReps = newValue;
                            // Make sure maxReps is not less than minReps
                            if (maxReps < minReps) {
                              minRepsController.text = maxReps.toString();
                              minReps = maxReps;
                            }
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStyledNumberField(
                        label: 'Target RIR',
                        controller: rirController,
                        focusNode: rirFocus,
                        onChanged: (value) {
                          int? newValue = int.tryParse(value);
                          if (newValue != null && newValue >= 0) {
                            rir = newValue;
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
                          "CANCEL",
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
                          if (name.trim().isNotEmpty) {
                            // Update exercise with new values
                            _updateExercise(state, day, exercise, name,
                                description, sets, minReps, maxReps, rir);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          "SAVE",
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
      ),
    );
  }

  // UPDATED TEXT FIELD METHOD
  Widget _buildStyledTextField({
    required String label,
    required Function(String) onChanged,
    String hint = '',
    int maxLines = 1,
    TextEditingController? controller,
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
            decoration: InputDecoration(
              hintText: hint,
            ),
            maxLines: maxLines,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // UPDATED NUMBER FIELD METHOD
  Widget _buildStyledNumberField({
    required String label,
    required Function(String) onChanged,
    String initialValue = '',
    TextEditingController? controller,
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
            controller: controller ?? TextEditingController(text: initialValue),
            focusNode: focusNode,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Gib einen Wert ein',
            ),
            onChanged: onChanged,
          ),
        ),
      ],
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
    int rir,
  ) {
    // Find the index of the old exercise
    int exerciseIndex =
        day.exercises.indexWhere((ex) => ex.id == oldExercise.id);

    if (exerciseIndex != -1) {
      // Create a new exercise with updated values but same ID
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

      // Replace the old exercise with the updated one
      day.exercises[exerciseIndex] = updatedExercise;

      // Notify listeners about the change
      state.notifyListeners();
    }
  }
}
