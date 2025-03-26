// lib/screens/workout/workout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';

// Component imports
import 'components/workout_header.dart';
import 'components/exercise_card/exercise_card.dart';
import 'components/workout_log_card.dart';
import 'components/workout_completed_card.dart';

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

    // Verzögerte Initialisierung des TabControllers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initExerciseTabController();
    });
  }

  void _initExerciseTabController() {
    final state = Provider.of<WorkoutTrackerState>(context, listen: false);
    if (state.currentDay != null && state.currentDay!.exercises.isNotEmpty) {
      // Initialisiere den TabController mit der Anzahl der Übungen
      _exerciseTabController = TabController(
        length: state.currentDay!.exercises.length,
        vsync: this,
      );

      // Setze den TabController auf den Index der aktuellen Übung, falls vorhanden
      if (state.currentExercise != null) {
        int exerciseIndex = state.currentDay!.exercises
            .indexWhere((ex) => ex.id == state.currentExercise!.id);
        if (exerciseIndex >= 0) {
          _exerciseTabController!.index = exerciseIndex;
        }
      }

      // Höre auf Tab-Änderungen und aktualisiere die aktuelle Übung entsprechend
      _exerciseTabController!.addListener(() {
        if (!_exerciseTabController!.indexIsChanging && mounted) {
          final int tabIndex = _exerciseTabController!.index;
          if (tabIndex >= 0 && tabIndex < state.currentDay!.exercises.length) {
            final selectedExercise = state.currentDay!.exercises[tabIndex];
            if (state.currentExercise?.id != selectedExercise.id) {
              state.setCurrentExerciseByIndex(tabIndex);
            }
          }
        }
      });

      // Kein setState hier mehr aufrufen - wir nutzen stattdessen addPostFrameCallback,
      // wenn wir einen Rebuild triggern müssen
    }
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
  void didUpdateWidget(WorkoutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Bei Änderungen an der Übung oder dem Tag, TabController aktualisieren
    final state = Provider.of<WorkoutTrackerState>(context, listen: false);
    if (state.currentDay != null && state.currentExercise != null) {
      // Überprüfe, ob der TabController noch gültig ist
      if (!_exerciseTabControllerIsValid(state)) {
        // Verzögere die Initialisierung um setState-Aufrufe während des Builds zu vermeiden
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _initExerciseTabController();
            setState(() {}); // UI aktualisieren nach der Initialisierung
          }
        });
      } else {
        // Aktualisiere nur den Tab-Index, falls er sich geändert hat
        int exerciseIndex = state.currentDay!.exercises
            .indexWhere((ex) => ex.id == state.currentExercise!.id);
        if (exerciseIndex >= 0 &&
            _exerciseTabController!.index != exerciseIndex &&
            !_exerciseTabController!.indexIsChanging) {
          _exerciseTabController!.animateTo(exerciseIndex);
        }
      }
    }
  }

  bool _exerciseTabControllerIsValid(WorkoutTrackerState state) {
    return state.currentDay != null &&
        _exerciseTabController != null &&
        _exerciseTabController!.length == state.currentDay!.exercises.length;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    if (_exerciseTabController != null) {
      _exerciseTabController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        // Überprüfen, ob alle Sets der letzten Übung protokolliert sind
        bool allSetsOfAllExercisesLogged = _areAllExercisesComplete(state);

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
                    WorkoutHeader(
                      showElevation: _showElevation,
                      onBackPressed: widget.onBackPressed,
                      currentPlan: state.currentPlan,
                      currentDay: state.currentDay,
                    ),

                    // Nur anzeigen, wenn Training aktiv und Übungen vorhanden sind
                    if (state.currentDay != null &&
                        state.currentDay!.exercises.isNotEmpty &&
                        !allSetsOfAllExercisesLogged)
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
                            // Übungskarte anzeigen, wenn Training aktiv und nicht alle Sets protokolliert
                            if (state.currentDay != null &&
                                state.currentDay!.exercises.isNotEmpty &&
                                !allSetsOfAllExercisesLogged)
                              _buildTabView(state),

                            // Workout-Log-Karte, falls Sets protokolliert sind
                            if (state.workoutLog.isNotEmpty)
                              WorkoutLogCard(
                                workoutLog: state.workoutLog,
                              ),

                            // Erfolgskarte anzeigen, wenn alle Sets protokolliert sind
                            if (allSetsOfAllExercisesLogged)
                              WorkoutCompletedCard(
                                onFinishWorkout: () {
                                  state.finishWorkout();
                                  widget.onFinished();
                                },
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
        );
      },
    );
  }

  Widget _buildExerciseTabs(WorkoutTrackerState state) {
    if (state.currentDay == null || state.currentDay!.exercises.isEmpty) {
      return SizedBox.shrink();
    }

    // Prüfen, ob TabController bereits initialisiert ist
    if (!_exerciseTabControllerIsValid(state)) {
      // Verzögere die Initialisierung auf die nächste Frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initExerciseTabController();
          setState(() {}); // Trigger UI update nach der Initialisierung
        }
      });
      return SizedBox.shrink(); // Zeige nichts während der Initialisierung
    }

    return Container(
      height: 48, // Feste Höhe für die Tabs
      margin: EdgeInsets.symmetric(vertical: 8),
      child: TabBar(
        controller: _exerciseTabController!,
        isScrollable: true, // Scrollbar machen, falls viele Übungen
        indicatorColor: Color(0xFF3D85C6),
        labelColor: Color(0xFF3D85C6),
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: state.currentDay!.exercises.map((exercise) {
          // Prüfen, ob alle Sets dieser Übung abgeschlossen sind
          final allSetsCompleted =
              _areAllSetsOfExerciseCompleted(state, exercise.id);

          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(exercise.name),
                if (allSetsCompleted) ...[
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
    // Finde die Übung in den Logs
    final exerciseSets =
        state.workoutLog.where((log) => log.exerciseId == exerciseId).toList();

    // Finde die Übung im aktuellen Tag
    final exercises =
        state.currentDay!.exercises.where((ex) => ex.id == exerciseId).toList();

    // Wenn die Übung nicht gefunden wurde oder keine Sets hat, return false
    if (exercises.isEmpty) return false;

    // Prüfe, ob die Anzahl der protokollierten Sets der Anzahl der erwarteten Sets entspricht
    return exerciseSets.length == exercises.first.sets;
  }

  bool _areAllExercisesComplete(WorkoutTrackerState state) {
    if (state.currentDay == null) return false;

    // Prüfe für jede Übung im aktuellen Tag
    for (var exercise in state.currentDay!.exercises) {
      if (!_areAllSetsOfExerciseCompleted(state, exercise.id)) {
        return false; // Mindestens eine Übung ist nicht vollständig
      }
    }

    // Wenn alle Übungen vollständig sind
    return state.currentDay!.exercises.isNotEmpty;
  }
}
