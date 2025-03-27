// lib/screens/workout/workout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/rest_timer.dart';

// Component imports
import 'components/workout_header.dart';
import 'components/exercise_card/exercise_card.dart';
import 'components/workout_log_card.dart';
import 'components/workout_completed_card.dart';
import 'dialogs/end_workout_dialog.dart'; // Neuer Dialog für Workout-Beendigung

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
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  TabController? _exerciseTabController;
  bool _showElevation = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isTabChangeFromState =
      false; // Flag to track tab changes initiated by state
  String?
      _lastExerciseId; // Track last selected exercise ID for tab synchronization

  // Store a reference to the state to avoid Provider.of in dispose
  late WorkoutTrackerState _workoutState;
  bool _stateListenerAdded = false;

  @override
  void initState() {
    super.initState();

    // Store reference to state early in lifecycle
    _workoutState = Provider.of<WorkoutTrackerState>(context, listen: false);

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

    // Delayed initialization of TabController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initExerciseTabController();
      }
    });
  }

  void _initExerciseTabController() {
    if (!mounted) return;

    // Use stored reference instead of Provider.of
    if (_workoutState.currentDay == null ||
        _workoutState.currentDay!.exercises.isEmpty) return;

    // Initialize TabController with the number of exercises
    _exerciseTabController = TabController(
      length: _workoutState.currentDay!.exercises.length,
      vsync: this,
    );

    // Set TabController to the index of the current exercise, if available
    if (_workoutState.currentExercise != null) {
      int exerciseIndex = _workoutState.currentDay!.exercises
          .indexWhere((ex) => ex.id == _workoutState.currentExercise!.id);
      if (exerciseIndex >= 0) {
        _exerciseTabController!.index = exerciseIndex;
        // Store the current exercise ID for change detection
        _lastExerciseId = _workoutState.currentExercise!.id;
      }
    }

    // Listen to tab changes and update current exercise accordingly
    _exerciseTabController!.addListener(_handleTabControllerChange);

    // Add a listener to handle state changes
    _workoutState.addListener(_handleStateChange);
    _stateListenerAdded = true;
  }

  // Handle changes from tab controller
  void _handleTabControllerChange() {
    if (!mounted || _exerciseTabController == null) return;

    if (!_exerciseTabController!.indexIsChanging && !_isTabChangeFromState) {
      final int tabIndex = _exerciseTabController!.index;
      if (tabIndex >= 0 &&
          tabIndex < _workoutState.currentDay!.exercises.length) {
        final selectedExercise = _workoutState.currentDay!.exercises[tabIndex];
        if (_workoutState.currentExercise?.id != selectedExercise.id) {
          _workoutState.setCurrentExerciseByIndex(tabIndex);
          // Update last exercise ID
          _lastExerciseId = selectedExercise.id;
        }
      }
    }
    _isTabChangeFromState = false; // Reset flag after handling
  }

  // Method to handle changes in the WorkoutTrackerState
  void _handleStateChange() {
    if (!mounted ||
        _exerciseTabController == null ||
        _workoutState.currentDay == null) return;

    // Check if current exercise has changed
    if (_workoutState.currentExercise != null &&
        _lastExerciseId != _workoutState.currentExercise!.id) {
      _lastExerciseId = _workoutState.currentExercise!.id;

      // Find the index of the new current exercise
      int exerciseIndex = _workoutState.currentDay!.exercises
          .indexWhere((ex) => ex.id == _workoutState.currentExercise!.id);

      if (exerciseIndex >= 0 &&
          exerciseIndex != _exerciseTabController!.index) {
        // Set flag to indicate this tab change is from state update
        _isTabChangeFromState = true;

        // Animate to the new tab with proper duration
        _exerciseTabController!.animateTo(
          exerciseIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onScroll() {
    if (!mounted) return;

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
  void didUpdateWidget(WorkoutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!mounted) return;

    // When exercise or day changes, update TabController if needed
    if (_workoutState.currentDay != null &&
        _workoutState.currentExercise != null) {
      // Check if TabController is still valid
      if (!_exerciseTabControllerIsValid(_workoutState)) {
        // Delay initialization to avoid setState calls during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _initExerciseTabController();
            setState(() {}); // Update UI after initialization
          }
        });
      }
    }
  }

  bool _exerciseTabControllerIsValid(WorkoutTrackerState state) {
    return state.currentDay != null &&
        _exerciseTabController != null &&
        _exerciseTabController!.length == state.currentDay!.exercises.length;
  }

  // Neuer Methode für vorzeitiges Beenden eines Workouts
  void _showEndWorkoutDialog() {
    showDialog(
      context: context,
      builder: (context) => EndWorkoutDialog(
        onSaveAndFinish: () async {
          // Workout mit gespeicherten Sets beenden
          await _workoutState.finishWorkout();
          Navigator.of(context).pop(); // Dialog schließen
          widget.onFinished(); // Zum Home-Screen zurückkehren
        },
        onDiscardAndFinish: () {
          // Workout abbrechen ohne zu speichern
          _workoutState.cancelWorkout();
          Navigator.of(context).pop(); // Dialog schließen
          widget.onFinished(); // Zum Home-Screen zurückkehren
        },
      ),
    );
  }

  // Safe handler for workout finish
  void _handleFinishWorkout() {
    if (!mounted) return;

    HapticFeedback.heavyImpact();

    // Use local reference instead of Provider.of
    _workoutState.finishWorkout().then((_) {
      // Only call callback if still mounted
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    // Important: Remove listeners safely
    if (_stateListenerAdded) {
      _workoutState.removeListener(_handleStateChange);
    }

    _fadeController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    if (_exerciseTabController != null) {
      _exerciseTabController!.removeListener(_handleTabControllerChange);
      _exerciseTabController!.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        // Update local reference
        _workoutState = state;

        return WillPopScope(
          onWillPop: () async {
            // Minimiere Workout statt es zu beenden
            widget.onBackPressed();
            return false;
          },
          child: Scaffold(
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
                      // Header mit neuem Ende-Button
                      WorkoutHeader(
                        showElevation: _showElevation,
                        onBackPressed: () {
                          // Minimize workout instead of ending it
                          widget.onBackPressed();
                        },
                        currentPlan: state.currentPlan,
                        currentDay: state.currentDay,
                        onEndPressed:
                            _showEndWorkoutDialog, // Neue Callback-Funktion
                      ),

                      // Only show tabs if workout is active and not all exercises are completed
                      if (state.currentDay != null &&
                          state.currentDay!.exercises.isNotEmpty &&
                          !state.isAllExercisesCompleted)
                        _buildExerciseTabs(state),

                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: ListView(
                            controller: _scrollController,
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 100),
                            children: [
                              // Show the Rest Timer, if enabled
                              if (state.showRestTimer)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16.0, bottom: 16.0),
                                  child: RestTimer(
                                    // Use a key based on workout progress to force recreation when a set is logged
                                    key: ValueKey<String>(
                                        'rest_timer_${state.currentExercise?.id ?? ''}_${state.workoutLog.length}'),
                                    initialDuration: state.currentRestTime,
                                    onTimerComplete: () {
                                      state.endRestTimer();
                                    },
                                    onSkip: () {
                                      state.endRestTimer();
                                    },
                                  ),
                                ),

                              // Exercise card - show only if workout is active and not all exercises are completed
                              if (state.currentDay != null &&
                                  state.currentDay!.exercises.isNotEmpty &&
                                  !state.isAllExercisesCompleted &&
                                  state.currentExercise != null)
                                _buildTabView(state),

                              // Workout log card - if any sets are logged
                              if (state.workoutLog.isNotEmpty)
                                WorkoutLogCard(
                                  workoutLog: state.workoutLog,
                                ),

                              // Show completion card when all exercises are completed
                              if (state.isAllExercisesCompleted)
                                WorkoutCompletedCard(
                                  onFinishWorkout: _handleFinishWorkout,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseTabs(WorkoutTrackerState state) {
    if (state.currentDay == null || state.currentDay!.exercises.isEmpty) {
      return SizedBox.shrink();
    }

    // Check if TabController is already initialized
    if (!_exerciseTabControllerIsValid(state)) {
      // Delay initialization to the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initExerciseTabController();
          setState(() {}); // Trigger UI update after initialization
        }
      });
      return SizedBox.shrink(); // Show nothing during initialization
    }

    return Container(
      height: 48, // Fixed height for tabs
      margin: EdgeInsets.symmetric(vertical: 8),
      child: TabBar(
        controller: _exerciseTabController!,
        isScrollable: true, // Make scrollable for many exercises
        indicatorColor: Color(0xFF3D85C6),
        labelColor: Color(0xFF3D85C6),
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: state.currentDay!.exercises.map((exercise) {
          // Check if all sets of this exercise are completed
          final bool isCompleted =
              _areAllSetsOfExerciseCompleted(state, exercise.id);

          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(exercise.name),
                if (isCompleted) ...[
                  SizedBox(width: 6),
                  Icon(Icons.check_circle, size: 16, color: Color(0xFF44CF74))
                ]
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabView(WorkoutTrackerState state) {
    if (state.currentExercise == null ||
        !_exerciseTabControllerIsValid(state)) {
      return SizedBox.shrink();
    }

    return ExerciseCard(
      currentExercise: state.currentExercise!,
    );
  }

  bool _areAllSetsOfExerciseCompleted(
      WorkoutTrackerState state, String exerciseId) {
    // Find the exercise in the logs
    final exerciseSets =
        state.workoutLog.where((log) => log.exerciseId == exerciseId).toList();

    // Find the exercise in the current day
    final exercises =
        state.currentDay!.exercises.where((ex) => ex.id == exerciseId).toList();

    // If the exercise was not found or has no sets, return false
    if (exercises.isEmpty) return false;

    // Check if the number of logged sets matches the number of expected sets
    return exerciseSets.length == exercises.first.sets;
  }
}
