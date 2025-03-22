// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/workout_provider.dart';
import 'screens/home_screen.dart';
import 'screens/create_plan_screen.dart';
import 'screens/edit_plan_screen.dart';
import 'screens/workout_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WorkoutTrackerState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        // Improve text scaling
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 14),
          bodyLarge: TextStyle(fontSize: 16),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        // Ensure buttons have sufficient touch target size
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(88, 48),
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey[200]!,
          disabledColor: Colors.grey[300]!,
          selectedColor: Colors.blue[100]!,
          secondarySelectedColor: Colors.blue[100]!,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          labelStyle: TextStyle(fontSize: 12),
        ),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentView = 'plans'; // 'plans', 'create', 'edit', 'workout'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildCurrentView(),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case 'plans':
        return HomeScreen(
          onCreatePressed: () => setState(() => _currentView = 'create'),
          onEditPressed: (plan) {
            Provider.of<WorkoutTrackerState>(context, listen: false)
                .setCurrentPlan(plan);
            setState(() => _currentView = 'edit');
          },
          onWorkoutPressed: (plan, day) {
            Provider.of<WorkoutTrackerState>(context, listen: false)
                .startWorkout(plan, day);
            setState(() => _currentView = 'workout');
          },
        );
      case 'create':
        return CreatePlanScreen(
          onBackPressed: () => setState(() => _currentView = 'plans'),
          onPlanCreated: () => setState(() => _currentView = 'edit'),
        );
      case 'edit':
        return EditPlanScreen(
          onBackPressed: () => setState(() => _currentView = 'plans'),
        );
      case 'workout':
        return WorkoutScreen(
          onBackPressed: () => setState(() => _currentView = 'plans'),
          onFinished: () => setState(() => _currentView = 'plans'),
        );
      default:
        return HomeScreen(
          onCreatePressed: () => setState(() => _currentView = 'create'),
          onEditPressed: (plan) {
            Provider.of<WorkoutTrackerState>(context, listen: false)
                .setCurrentPlan(plan);
            setState(() => _currentView = 'edit');
          },
          onWorkoutPressed: (plan, day) {
            Provider.of<WorkoutTrackerState>(context, listen: false)
                .startWorkout(plan, day);
            setState(() => _currentView = 'workout');
          },
        );
    }
  }
}
