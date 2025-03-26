// home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/models.dart';
import '../providers/workout_provider.dart';

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
            child: _buildCreatePlanButton(context),
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
                  // Header section
                  _buildFlexibleAppBar(context, state),

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

  Widget _buildFlexibleAppBar(BuildContext context, WorkoutTrackerState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1626),
            Color(0xFF0F1A2A),
          ],
        ),
      ),
      child: FadeTransition(
        opacity: _welcomeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 0.2),
            end: Offset.zero,
          ).animate(_welcomeAnimation),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 54,
                    width: 54,
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
                        size: 26,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WELCOME',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Workout Tracker',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildWeeklyOverview(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyOverview(BuildContext context, WorkoutTrackerState state) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THIS WEEK',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Color(0xFF14253D),
              border: Border.all(
                color: Color(0xFF2E4865),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final isToday = index + 1 == today.weekday;
                final isPast = index + 1 < today.weekday;

                return Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday ? Color(0xFF2196F3) : Colors.transparent,
                        border: isToday
                            ? null
                            : Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                      ),
                      child: Center(
                        child: Text(
                          days[index],
                          style: TextStyle(
                            color: isToday
                                ? Colors.white
                                : Colors.white.withOpacity(isPast ? 0.5 : 0.8),
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      (startOfWeek.day + index).toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isToday
                            ? Colors.white
                            : Colors.white.withOpacity(isPast ? 0.5 : 0.8),
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Unified plans content, replacing the tab view structure
  Widget _buildPlansContent(BuildContext context, WorkoutTrackerState state) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: state.plans.isEmpty
          ? _buildEmptyPlans(context)
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.only(top: 20, bottom: 100),
                physics: BouncingScrollPhysics(),
                itemCount: state.plans.length,
                itemBuilder: (context, index) => Hero(
                  tag: 'plan_${state.plans[index].id}',
                  child: _buildPlanCard(
                    context,
                    state.plans[index],
                    state,
                    index,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyPlans(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLottieAnimation(
              'workout_empty',
              height: 200,
            ),
            SizedBox(height: 24),
            Text(
              'No training plans yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Create your first workout plan to start\ntracking your fitness journey',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: widget.onCreatePressed,
              icon: Icon(Icons.add),
              label: Text('CREATE YOUR FIRST PLAN'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: Color(0xFF2196F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                shadowColor: Color(0xFF2196F3).withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLottieAnimation(String animationName, {double height = 150}) {
    // Custom placeholder animation widget
    return Container(
      height: height,
      width: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1C2F49),
      ),
      child: Icon(
        Icons.fitness_center,
        size: height / 3,
        color: Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, TrainingPlan plan,
      WorkoutTrackerState state, int index) {
    if (_planCardKeys.length <= index) {
      _planCardKeys.add(GlobalKey());
    }

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return TweenAnimationBuilder<double>(
      key: _planCardKeys[index],
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Color(0xFF14253D),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2196F3),
                      Color(0xFF0D47A1),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 16,
                            children: [
                              _buildPlanMetric(
                                Icons.calendar_today_outlined,
                                '${plan.trainingDays.length} ${plan.trainingDays.length == 1 ? 'day' : 'days'}',
                              ),
                              _buildPlanMetric(
                                Icons.fitness_center,
                                '${_getTotalExercises(plan)} exercises',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    _buildContextMenu(context, plan, state),
                  ],
                ),
              ),

              // Plan content
              Container(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                constraints: BoxConstraints(
                  maxWidth: size.width - 32, // Account for outside padding
                ),
                color: Color(0xFF1C2F49),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: plan.trainingDays.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: isSmallScreen ? 60 : 70,
                    endIndent: isSmallScreen ? 16 : 20,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  itemBuilder: (context, index) => _buildTrainingDayItem(
                    context,
                    plan,
                    plan.trainingDays[index],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanMetric(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextMenu(
      BuildContext context, TrainingPlan plan, WorkoutTrackerState state) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Color(0xFF1C2F49),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: Colors.white),
              SizedBox(width: 12),
              Text('Edit Plan', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Color(0xFFF95738)),
              SizedBox(width: 12),
              Text(
                'Delete',
                style: TextStyle(color: Color(0xFFF95738)),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            widget.onEditPressed(plan);
            break;
          case 'delete':
            _showDeleteDialog(context, state, plan);
            break;
        }
      },
    );
  }

  Widget _buildTrainingDayItem(
      BuildContext context, TrainingPlan plan, TrainingDay day) {
    final exercises = day.exercises;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return InkWell(
      onTap: () => widget.onWorkoutPressed(plan, day),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: 12, horizontal: isSmallScreen ? 12 : 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Day indicator
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2E4865),
              ),
              child: Center(
                child: Text(
                  day.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),

            // Day info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${exercises.length} ${exercises.length == 1 ? 'exercise' : 'exercises'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Start button with "Starten" text
            Container(
              // Use constraints to ensure button doesn't overflow
              constraints: BoxConstraints(
                maxWidth: isSmallScreen ? 80 : 90,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF44CF74),
                    Color(0xFF2AAB5A),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF44CF74).withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Starten',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getTotalExercises(TrainingPlan plan) {
    int total = 0;
    for (var day in plan.trainingDays) {
      total += day.exercises.length;
    }
    return total;
  }

  void _showDeleteDialog(
      BuildContext context, WorkoutTrackerState state, TrainingPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Color(0xFF1C2F49),
        titlePadding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 0),
        contentPadding: EdgeInsets.all(24),
        title: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF95738).withOpacity(0.2),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF95738),
                size: 28,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Delete Plan',
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
              'Are you sure you want to delete "${plan.name}"? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('CANCEL'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      state.deletePlan(plan.id);
                      Navigator.of(context).pop();
                    },
                    child: Text('DELETE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF95738),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
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
    );
  }

  Widget _buildCreatePlanButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Add haptic feedback and animation
        HapticFeedback.mediumImpact();
        widget.onCreatePressed();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2196F3),
              Color(0xFF0D47A1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF2196F3).withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
