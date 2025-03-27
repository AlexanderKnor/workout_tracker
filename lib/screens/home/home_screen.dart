// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../models/models.dart'; // Wichtig: Models importieren

// Component imports
import 'components/home_header.dart';
import 'components/weekly_overview.dart';
import 'components/plan_card/plan_card.dart';
import 'components/empty_plans_view.dart';
import 'components/create_plan_button.dart';

class HomeScreen extends StatefulWidget {
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late AnimationController _welcomeAnimationController;
  late Animation<double> _welcomeAnimation;
  bool _showElevation = false;

  // For parallax effect in cards
  final List<GlobalKey> _planCardKeys = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Animation for FAB
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    // Animation for welcome section
    _welcomeAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _welcomeAnimation = CurvedAnimation(
      parent: _welcomeAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Start animations
    Future.delayed(Duration(milliseconds: 150), () {
      _welcomeAnimationController.forward();
      _fabAnimationController.forward();
    });
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

    // Update plan card parallax effects
    setState(() {});
  }

  // Neue Methode: Prüfen, ob ein Workout gestartet werden kann
  void _handleWorkoutStart(BuildContext context, WorkoutTrackerState state,
      TrainingPlan plan, TrainingDay day) {
    // Prüfen, ob bereits ein Workout aktiv ist
    if (state.isWorkoutActive) {
      // Wenn ja, Hinweis anzeigen
      _showActiveWorkoutDialog(context, state);
    } else {
      // Wenn nein, Workout starten
      widget.onWorkoutPressed(plan, day);
    }
  }

  // Dialog anzeigen, wenn bereits ein Workout aktiv ist
  void _showActiveWorkoutDialog(
      BuildContext context, WorkoutTrackerState state) {
    // Bestimme Workout-Informationen
    String planName = state.currentPlan?.name ?? "Aktives Workout";
    String dayName = state.currentDay?.name ?? "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Color(0xFF1C2F49),
        titlePadding: EdgeInsets.all(24),
        contentPadding: EdgeInsets.all(24),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF3D85C6).withOpacity(0.2),
              ),
              child: Icon(
                Icons.fitness_center,
                color: Color(0xFF3D85C6),
                size: 28,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Bereits aktives Workout',
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
            Text(
              'Du hast bereits ein Workout in Bearbeitung: "$planName"${dayName.isNotEmpty ? " ($dayName)" : ""}.\n\nSchließe oder beende dein aktuelles Workout, bevor du ein neues startest.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withOpacity(0.7),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                    child: Text('ABBRECHEN'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Dialog schließen
                      Navigator.of(context).pop();

                      // Zum aktiven Workout zurückkehren
                      state.maximizeWorkout();
                      widget.onWorkoutPressed(
                          state.currentPlan!, state.currentDay!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3D85C6),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('ZUM WORKOUT'),
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
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _welcomeAnimationController.dispose();
    super.dispose();
  }

  // Calculate parallax offset for each card
  double _getParallaxOffset(GlobalKey cardKey) {
    if (cardKey.currentContext == null) return 0.0;

    final RenderBox renderBox =
        cardKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate how far the card is from the center of the screen
    final centerDistance =
        (position.dy + renderBox.size.height / 2) - screenHeight / 2;

    // Convert to a parallax value (-10 to 10 pixels)
    return -centerDistance / screenHeight * 20;
  }

  // Hilfsfunktion für die Gesamtzahl der Übungen eines Plans
  int _getTotalExercises(TrainingPlan plan) {
    int total = 0;
    for (var day in plan.trainingDays) {
      total += day.exercises.length;
    }
    return total;
  }

  // Plan-Auswahldialog anzeigen
  void _showPlanSelectionDialog(
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
              Text(
                'Meine Trainingspläne',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: state.plans.map((plan) {
                      bool isActive = plan.id == state.activePlan?.id;
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color:
                              isActive ? Color(0xFF253B59) : Color(0xFF14253D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            plan.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            '${plan.trainingDays.length} Tage · ${_getTotalExercises(plan)} Übungen',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          trailing: isActive
                              ? Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF44CF74).withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Color(0xFF44CF74),
                                    size: 16,
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    state.setActivePlan(plan.id);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Aktivieren'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF3D85C6),
                                    foregroundColor: Colors.white,
                                    textStyle: TextStyle(fontSize: 12),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'SCHLIESSEN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        // Zeige Ladebildschirm während Daten geladen werden
        if (state.isLoading) {
          return _buildLoadingScreen();
        }

        // Ensure we have enough keys for plan cards
        while (_planCardKeys.length < state.plans.length) {
          _planCardKeys.add(GlobalKey());
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          floatingActionButton: ScaleTransition(
            scale: CurvedAnimation(
              parent: _fabAnimationController,
              curve: Curves.easeOutBack,
            ),
            child: CreatePlanButton(onPressed: widget.onCreatePressed),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1626), // Dark navy
                  Color(0xFF14253D), // Medium navy
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header section with welcome and weekly overview
                  FadeTransition(
                    opacity: _welcomeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(_welcomeAnimation),
                      child: Column(
                        children: [
                          HomeHeader(),
                          WeeklyOverview(),
                        ],
                      ),
                    ),
                  ),

                  // Plans content (takes remaining space)
                  Expanded(
                    child: _buildPlansContent(context, state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Neuer Ladebildschirm
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1626), // Dark navy
              Color(0xFF14253D), // Medium navy
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or Icon
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2196F3),
                      Color(0xFF0D47A1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2196F3).withOpacity(0.4),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Workout Tracker",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Color(0xFF3D85C6),
                  strokeWidth: 4,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Daten werden geladen...",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Unified plans content, replacing the tab view structure
  Widget _buildPlansContent(BuildContext context, WorkoutTrackerState state) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: state.activePlan == null
          ? EmptyPlansView(onCreatePressed: widget.onCreatePressed)
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Aktiver Plan
                  Hero(
                    tag: 'plan_${state.activePlan!.id}',
                    child: PlanCard(
                      key: GlobalKey(),
                      plan: state.activePlan!,
                      parallaxOffset: 0.0,
                      onEditPressed: widget.onEditPressed,
                      // Geändert - jetzt mit Prüfung auf aktives Workout
                      onWorkoutPressed: (plan, day) =>
                          _handleWorkoutStart(context, state, plan, day),
                    ),
                  ),

                  // Button zum Zugriff auf die Plan-Bibliothek
                  if (state.plans.length > 1)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: GestureDetector(
                        onTap: () {
                          _showPlanSelectionDialog(context, state);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Color(0xFF1C2F49),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_outlined,
                                color: Color(0xFF3D85C6),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'MEINE PLÄNE (${state.plans.length})',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
