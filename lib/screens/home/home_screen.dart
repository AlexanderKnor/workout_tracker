// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
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
      child: state.plans.isEmpty
          ? EmptyPlansView(onCreatePressed: widget.onCreatePressed)
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.only(top: 20, bottom: 100),
                physics: BouncingScrollPhysics(),
                itemCount: state.plans.length,
                itemBuilder: (context, index) => Hero(
                  tag: 'plan_${state.plans[index].id}',
                  child: PlanCard(
                    key: _planCardKeys[index],
                    plan: state.plans[index],
                    parallaxOffset: _getParallaxOffset(_planCardKeys[index]),
                    onEditPressed: widget.onEditPressed,
                    onWorkoutPressed: widget.onWorkoutPressed,
                  ),
                ),
              ),
            ),
    );
  }
}
