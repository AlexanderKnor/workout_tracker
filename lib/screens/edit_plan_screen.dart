// edit_plan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_selector.dart';

class EditPlanScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  final VoidCallback? onDiscardAndGoHome;

  const EditPlanScreen({
    Key? key,
    required this.onBackPressed,
    this.onDiscardAndGoHome,
  }) : super(key: key);

  @override
  _EditPlanScreenState createState() => _EditPlanScreenState();
}

class _EditPlanScreenState extends State<EditPlanScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  TabController? _tabController;
  bool _showElevation = false;
  final ScrollController _scrollController = ScrollController();
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();

    // Fade-in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _fadeController.forward();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = Provider.of<WorkoutTrackerState>(context, listen: false);

    if (state.currentPlan != null &&
        state.currentPlan!.trainingDays.isNotEmpty &&
        (_tabController == null ||
            _tabController!.length != state.currentPlan!.trainingDays.length)) {
      // Dispose alten Controller, falls vorhanden
      _tabController?.dispose();

      // Initialisiere mit korrektem Index
      final initialIndex =
          state.selectedDayIndex < state.currentPlan!.trainingDays.length
              ? state.selectedDayIndex
              : 0;

      _tabController = TabController(
        length: state.currentPlan!.trainingDays.length,
        vsync: this,
        initialIndex: initialIndex,
      );

      // Tab-Änderungen überwachen und den State aktualisieren
      _tabController!.addListener(_handleTabSelection);
    }
  }

  void _handleTabSelection() {
    if (_tabController != null && !_tabController!.indexIsChanging) {
      final state = Provider.of<WorkoutTrackerState>(context, listen: false);
      if (state.selectedDayIndex != _tabController!.index) {
        state.selectedDayIndex = _tabController!.index;
        if (state.currentPlan != null &&
            _tabController!.index < state.currentPlan!.trainingDays.length) {
          state.setCurrentDay(
              state.currentPlan!.trainingDays[_tabController!.index]);
        }
      }
    }
  }

  void _onScroll() {
    final shouldShowElevation = _scrollController.offset > 0;
    if (shouldShowElevation != _showElevation) {
      setState(() {
        _showElevation = shouldShowElevation;
      });
    }
  }

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

    if (_tabController != null) {
      _tabController!.removeListener(_handleTabSelection);
      _tabController!.dispose();
    }

    _focusNodes.forEach((_, node) => node.dispose());
    super.dispose();
  }

  Future<void> _onDone() async {
    final state = Provider.of<WorkoutTrackerState>(context, listen: false);

    if (!state.isPlanValid(state.currentPlan)) {
      _showPlanNotValidDialog();
      return;
    }

    await state.saveCurrentPlan();

    if (widget.onDiscardAndGoHome != null) {
      widget.onDiscardAndGoHome!();
    } else {
      widget.onBackPressed();
    }
  }

  void _showPlanNotValidDialog() {
    final state = Provider.of<WorkoutTrackerState>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1C2F49),
        titlePadding:
            const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
        contentPadding: const EdgeInsets.all(24),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF95738).withOpacity(0.2),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF95738),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Incomplete Plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Each training day must have at least one exercise. Would you like to continue editing or discard this plan?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      state.discardCurrentPlan();
                      Navigator.of(context).pop();

                      if (widget.onDiscardAndGoHome != null) {
                        widget.onDiscardAndGoHome!();
                      } else {
                        widget.onBackPressed();
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                    child: const Text('DISCARD PLAN'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D85C6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('CONTINUE EDITING'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: const BoxDecoration(
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          _buildHeader(context, state, inSelectionMode: true),
          const SizedBox(height: 16),
          const Expanded(child: ExerciseSelector()),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, WorkoutTrackerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, state, inSelectionMode: false),
        Expanded(
          child: state.currentPlan != null
              ? _buildPlanContent(context, state)
              : const Center(
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: BoxDecoration(
        color: _showElevation ? const Color(0xFF0F1A2A) : Colors.transparent,
        boxShadow: _showElevation
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: const Icon(
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
                style: const TextStyle(
                  color: Color(0xFF3D85C6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                inSelectionMode
                    ? "Choose from database"
                    : state.currentPlan?.name ?? "Customize your workout",
                style: const TextStyle(
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
              ? const SizedBox(width: 40)
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _onDone();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF44CF74).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF44CF74).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Text(
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
      return const Center(
        child: Text(
          'This plan has no training days.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab bar with days
        Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2F49),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: state.currentPlan!.trainingDays
                .map((day) => Tab(text: day.name))
                .toList(),
            labelColor: const Color(0xFF3D85C6),
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            indicatorColor: const Color(0xFF3D85C6),
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        const SizedBox(height: 16),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: state.currentPlan!.trainingDays
                .map((day) => _buildDayContent(context, state, day))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDayContent(
      BuildContext context, WorkoutTrackerState state, TrainingDay day) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          _buildExercisesCard(context, state, day),
          const SizedBox(height: 20),
          _buildAddExerciseCard(context, state),
        ],
      ),
    );
  }

  Widget _buildExercisesCard(
      BuildContext context, WorkoutTrackerState state, TrainingDay day) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14253D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.fitness_center,
                  color: Color(0xFF3D85C6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Exercises for ${day.name}',
                  style: const TextStyle(
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2F49),
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
              physics: const NeverScrollableScrollPhysics(),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2F49),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF3D85C6),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delete button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => state.deleteExercise(exercise.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2F49),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
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
        color: const Color(0xFF14253D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.fitness_center,
                  text: 'From Database',
                  color: const Color(0xFF3D85C6),
                  onTap: () => state.toggleExerciseSelectionMode(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add,
                  text: 'Create Custom',
                  color: const Color(0xFF44CF74),
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
          padding: const EdgeInsets.symmetric(vertical: 14),
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
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
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
    final nameFocus = _getFocusNode('newExercise_name');
    final descFocus = _getFocusNode('newExercise_desc');
    final setsFocus = _getFocusNode('newExercise_sets');
    final minRepsFocus = _getFocusNode('newExercise_minReps');
    final maxRepsFocus = _getFocusNode('newExercise_maxReps');
    final rirFocus = _getFocusNode('newExercise_rir');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1C2F49),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF44CF74).withOpacity(0.15),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Color(0xFF44CF74),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
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
                const SizedBox(height: 24),
                _buildStyledTextField(
                  label: 'Exercise Name',
                  hint: 'e.g. Bench Press',
                  focusNode: nameFocus,
                  onChanged: (value) => state.newExerciseName = value,
                ),
                const SizedBox(height: 16),
                _buildStyledTextField(
                  label: 'Description (optional)',
                  hint: 'e.g. Barbell on flat bench',
                  maxLines: 2,
                  focusNode: descFocus,
                  onChanged: (value) => state.newExerciseDescription = value,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStyledNumberField(
                        label: 'Sets',
                        initialValue: state.newExerciseSets.toString(),
                        focusNode: setsFocus,
                        onChanged: (value) {
                          final newValue = int.tryParse(value);
                          if (newValue != null && newValue > 0) {
                            state.newExerciseSets = newValue;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStyledNumberField(
                        label: 'Min Reps',
                        initialValue: state.newExerciseMinReps.toString(),
                        focusNode: minRepsFocus,
                        onChanged: (value) {
                          final newValue = int.tryParse(value);
                          if (newValue != null && newValue > 0) {
                            state.newExerciseMinReps = newValue;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStyledNumberField(
                        label: 'Max Reps',
                        initialValue: state.newExerciseMaxReps.toString(),
                        focusNode: maxRepsFocus,
                        onChanged: (value) {
                          final newValue = int.tryParse(value);
                          if (newValue != null && newValue > 0) {
                            state.newExerciseMaxReps = newValue;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStyledNumberField(
                        label: 'Target RIR',
                        initialValue: state.newExerciseRIR.toString(),
                        focusNode: rirFocus,
                        onChanged: (value) {
                          final newValue = int.tryParse(value);
                          if (newValue != null && newValue >= 0) {
                            state.newExerciseRIR = newValue;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          "CANCEL",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (state.newExerciseName.trim().isNotEmpty) {
                            state.addExerciseToPlan();
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF44CF74),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "ADD",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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

    final nameFocus = _getFocusNode('editExercise_name_${exercise.id}');
    final descFocus = _getFocusNode('editExercise_desc_${exercise.id}');
    final setsFocus = _getFocusNode('editExercise_sets_${exercise.id}');
    final minRepsFocus = _getFocusNode('editExercise_minReps_${exercise.id}');
    final maxRepsFocus = _getFocusNode('editExercise_maxReps_${exercise.id}');
    final rirFocus = _getFocusNode('editExercise_rir_${exercise.id}');

    String name = exercise.name;
    String description = exercise.description ?? '';
    int sets = exercise.sets;
    int minReps = exercise.minReps;
    int maxReps = exercise.maxReps;
    int rir = exercise.targetRIR;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1C2F49),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF3D85C6).withOpacity(0.15),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Color(0xFF3D85C6),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
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
                const SizedBox(height: 24),
                _buildStyledTextField(
                  label: 'Exercise Name',
                  controller: nameController,
                  focusNode: nameFocus,
                  onChanged: (value) => name = value,
                ),
                const SizedBox(height: 16),
                _buildStyledTextField(
                  label: 'Description (optional)',
                  controller: descriptionController,
                  focusNode: descFocus,
                  maxLines: 2,
                  onChanged: (value) => description = value,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStyledNumberField(
                        label: 'Sets',
                        controller: setsController,
                        focusNode: setsFocus,
                        onChanged: (value) {
                          final newValue = int.tryParse(value);
                          if (newValue != null && newValue > 0) {
                            sets = newValue;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStyledNumberField(
                        label: 'Min Reps',
                        controller: minRepsController,
                        focusNode: minRepsFocus,
                        onChanged: (value) {
                          final newValue = int.tryParse(value);
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStyledNumberField(
                        label: 'Max Reps',
                        controller: maxRepsController,
                        focusNode: maxRepsFocus,
                        onChanged: (value) {
                          final newValue = int.tryParse(value);
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStyledNumberField(
                        label: 'Target RIR',
                        controller: rirController,
                        focusNode: rirFocus,
                        onChanged: (value) {
                          final newValue = int.tryParse(value);
                          if (newValue != null && newValue >= 0) {
                            rir = newValue;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          "CANCEL",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (name.trim().isNotEmpty) {
                            _updateExercise(state, day, exercise, name,
                                description, sets, minReps, maxReps, rir);
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3D85C6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "SAVE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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
        const SizedBox(height: 8),
        Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF3D85C6),
                  width: 2,
                ),
              ),
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(
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
        const SizedBox(height: 8),
        Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF3D85C6),
                  width: 2,
                ),
              ),
            ),
          ),
          child: TextField(
            controller: controller ?? TextEditingController(text: initialValue),
            focusNode: focusNode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
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
    final exerciseIndex =
        day.exercises.indexWhere((ex) => ex.id == oldExercise.id);

    if (exerciseIndex != -1) {
      final updatedExercise = Exercise(
        id: oldExercise.id,
        name: name,
        sets: sets,
        minReps: minReps,
        maxReps: maxReps,
        targetRIR: rir,
        categoryId: oldExercise.categoryId,
        description: description.isNotEmpty ? description : null,
      );

      day.exercises[exerciseIndex] = updatedExercise;
      state.notifyListeners();
    }
  }
}
