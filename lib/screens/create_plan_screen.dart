// create_plan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';

class CreatePlanScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onPlanCreated;

  const CreatePlanScreen({
    Key? key,
    required this.onBackPressed,
    required this.onPlanCreated,
  }) : super(key: key);

  @override
  _CreatePlanScreenState createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final FocusNode _planNameFocus = FocusNode();
  bool _planNameHasFocus = false;

  @override
  void initState() {
    super.initState();

    // Simple fade-in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _fadeController.forward();

    // Focus listener
    _planNameFocus.addListener(() {
      setState(() {
        _planNameHasFocus = _planNameFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _planNameFocus.removeListener(() {});
    _planNameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1626),
                  Color(0xFF162A46),
                ],
              ),
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(context),

                      SizedBox(height: 24),

                      // Content
                      Expanded(
                        child: _buildContent(context, state),
                      ),

                      // Create button - properly at bottom
                      SizedBox(height: 16),
                      _buildCreateButton(context, state),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

        // Title
        Column(
          children: [
            Text(
              "CREATE PLAN",
              style: TextStyle(
                color: Color(0xFF3D85C6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Design Your Fitness Journey",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),

        // Invisible spacer for balance
        SizedBox(width: 40),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WorkoutTrackerState state) {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        // Plan name section
        _buildSection(
          title: "PLAN NAME",
          child: _buildPlanNameInput(context, state),
        ),

        SizedBox(height: 32),

        // Training days section
        _buildSection(
          title: "TRAINING FREQUENCY",
          child: _buildDaysSelector(context, state),
        ),

        SizedBox(height: 32),

        // Training day names
        _buildSection(
          title: "NAME YOUR DAYS",
          child: Column(
            children: List.generate(
              state.numberOfTrainingDays,
              (index) => _buildDayNameInput(context, state, index),
            ),
          ),
        ),

        // Additional space at bottom for padding
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildPlanNameInput(BuildContext context, WorkoutTrackerState state) {
    return Theme(
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
          // Remove default focus border
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
        focusNode: _planNameFocus,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: "Enter a name for your plan",
        ),
        onChanged: (value) {
          state.newPlanName = value;
        },
      ),
    );
  }

  Widget _buildDaysSelector(BuildContext context, WorkoutTrackerState state) {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) {
          final days = index + 1;
          final isSelected = state.numberOfTrainingDays == days;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              state.numberOfTrainingDays = days;
              setState(() {});
            },
            child: Container(
              width: 60,
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color(0xFF44CF74).withOpacity(0.15)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Color(0xFF44CF74)
                      : Colors.white.withOpacity(0.1),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days.toString(),
                    style: TextStyle(
                      color: isSelected ? Color(0xFF44CF74) : Colors.white,
                      fontSize: 22,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Days",
                    style: TextStyle(
                      color: isSelected
                          ? Color(0xFF44CF74).withOpacity(0.8)
                          : Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayNameInput(
      BuildContext context, WorkoutTrackerState state, int index) {
    final initialValue = state.trainingDayNames[index];
    final controller = TextEditingController(text: initialValue);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Day indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF3D85C6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          SizedBox(width: 16),

          // Name input - improved to match the plan name input style
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
              child: TextField(
                controller: controller,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: "Name for day ${index + 1}",
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    state.updateTrainingDayName(index, value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context, WorkoutTrackerState state) {
    final bool isValid = state.newPlanName.trim().isNotEmpty;

    return ElevatedButton(
      onPressed: isValid
          ? () {
              HapticFeedback.mediumImpact();
              state
                  .createDraftPlan(); // Changed from createNewPlan() to create a draft instead
              widget.onPlanCreated();
            }
          : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor:
            isValid ? Color(0xFF44CF74) : Colors.grey.withOpacity(0.3),
        disabledForegroundColor: Colors.white.withOpacity(0.5),
        disabledBackgroundColor: Colors.grey.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "CREATE PLAN",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(width: 12),
          Icon(
            Icons.arrow_forward_rounded,
            size: 20,
          ),
        ],
      ),
    );
  }
}
