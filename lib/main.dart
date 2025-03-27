// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/workout_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/create_plan_screen.dart';
import 'screens/edit_plan_screen.dart';
import 'screens/workout/workout_screen.dart';
import 'widgets/minimized_workout.dart'; // Neue Widget-Importierung

void main() async {
  // Diese Zeile ist wichtig, damit Flutter-Bindungen initialisiert sind,
  // bevor wir auf die Datenbank zugreifen
  WidgetsFlutterBinding.ensureInitialized();

  // Set fullscreen mode for the entire app
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );

  // Ensure the app stays in portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ChangeNotifierProvider mit "lazy: false" starten, damit WorkoutTrackerState
  // sofort initialisiert wird und Daten laden kann
  runApp(
    ChangeNotifierProvider(
      create: (context) => WorkoutTrackerState(),
      lazy: false, // Sofortige Initialisierung des WorkoutTrackerState
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Tracker',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ThemeMode.dark, // Force dark mode
      home: MainScreen(),
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}

// Light theme definition
final _lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: Colors.grey[50],
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: Size(88, 48),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: Size(88, 48),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey[200]!,
    disabledColor: Colors.grey[300]!,
    selectedColor: Colors.blue[100]!,
    secondarySelectedColor: Colors.blue[100]!,
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    labelStyle: TextStyle(fontSize: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  dividerTheme: DividerThemeData(
    space: 1,
    thickness: 1,
    color: Colors.grey[300],
  ),
  tabBarTheme: TabBarTheme(
    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    unselectedLabelStyle: TextStyle(fontSize: 14),
    indicatorSize: TabBarIndicatorSize.tab,
  ),
);

// Dark theme definition
final _darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    onBackground: Colors.white,
    onSurface: Colors.white,
    primary: Color(0xFF3D85C6),
    secondary: Color(0xFF44CF74),
    tertiary: Color(0xFFF1A33C),
  ),
  scaffoldBackgroundColor: Color(0xFF121212),
  cardTheme: CardTheme(
    elevation: 0,
    color: Color(0xFF1E1E1E),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
        fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: TextStyle(
        fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
    displaySmall: TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.87)),
    titleLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    titleMedium: TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    titleSmall: TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: Size(88, 48),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: Size(88, 48),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    fillColor: Color(0xFF2A2A2A),
    filled: true,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Color(0xFF2A2A2A),
    disabledColor: Color(0xFF3A3A3A),
    selectedColor: Colors.blue.withOpacity(0.3),
    secondarySelectedColor: Colors.blue.withOpacity(0.3),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    labelStyle: TextStyle(fontSize: 12, color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  dividerTheme: DividerThemeData(
    space: 1,
    thickness: 1,
    color: Colors.grey[800],
  ),
  tabBarTheme: TabBarTheme(
    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    unselectedLabelStyle: TextStyle(fontSize: 14),
    indicatorSize: TabBarIndicatorSize.tab,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.grey,
  ),
  listTileTheme: ListTileThemeData(
    iconColor: Colors.white,
    textColor: Colors.white,
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Color(0xFF1E1E1E),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF3D85C6),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.blue;
      }
      return Colors.grey;
    }),
    trackColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.blue.withOpacity(0.5);
      }
      return Colors.grey.withOpacity(0.5);
    }),
  ),
);

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentView = 'plans'; // 'plans', 'create', 'edit', 'workout'
  String _previousView = 'plans'; // Track the previous view for back navigation

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        return WillPopScope(
          onWillPop: () async {
            // Wenn ein Workout läuft und wir nicht im Workout-Screen sind,
            // zum Workout zurückkehren statt die App zu beenden
            if (state.isWorkoutActive && _currentView != 'workout') {
              _navigateTo('workout');
              return false;
            }

            // Wenn wir auf dem Home-Screen sind, erlaube der App, geschlossen zu werden
            if (_currentView == 'plans') {
              return true;
            }

            // Bei aktivem Workout und Zurück-Taste im Workout-Screen wird das Workout minimiert
            if (_currentView == 'workout' && state.isWorkoutActive) {
              state.minimizeWorkout();
              _navigateToHome();
              return false;
            }

            // Ansonsten handle die Zurück-Navigation und verhindere das Schließen der App
            _goBack();
            return false;
          },
          child: Scaffold(
            body: Stack(
              children: [
                // Hauptbildschirm
                _buildCurrentView(),

                // Minimierte Workout-Ansicht, wenn ein Workout aktiv ist und minimiert wurde
                if (state.isWorkoutActive && state.isWorkoutMinimized)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        state.maximizeWorkout();
                        _navigateTo('workout');
                      },
                      child: MinimizedWorkout(
                        onResume: () {
                          state.maximizeWorkout();
                          _navigateTo('workout');
                        },
                        onEnd: () => _showEndWorkoutDialog(context, state),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Ende-Workout-Dialog anzeigen
  void _showEndWorkoutDialog(BuildContext context, WorkoutTrackerState state) {
    // Überprüfen, ob bereits Sets geloggt wurden
    bool hasLoggedSets = state.workoutLog.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Color(0xFF1C2F49),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF95738).withOpacity(0.2),
              ),
              child: Icon(
                Icons.fitness_center,
                color: Color(0xFFF95738),
                size: 28,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Workout beenden?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasLoggedSets
                  ? 'Möchtest du das Workout beenden? Du hast bereits Sets geloggt.'
                  : 'Möchtest du das Workout beenden? Du hast noch keine Sets geloggt.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            if (hasLoggedSets) ...[
              // Wenn Sets geloggt wurden, Optionen anzeigen
              ElevatedButton(
                onPressed: () async {
                  // Workout mit gespeicherten Sets beenden
                  await state.finishWorkout();
                  Navigator.of(context).pop();

                  // Stellen Sie sicher, dass nach dem Beenden alle Zustände korrekt zurückgesetzt werden
                  state.resetWorkoutState();
                  if (mounted) setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF44CF74),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 0),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('SPEICHERN UND BEENDEN'),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // Workout abbrechen, ohne Sets zu speichern
                  state.cancelWorkout();
                  Navigator.of(context).pop();

                  // Stellen Sie sicher, dass nach dem Abbrechen alle Zustände korrekt zurückgesetzt werden
                  state.resetWorkoutState();
                  if (mounted) setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF95738),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 0),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('VERWERFEN UND BEENDEN'),
              ),
            ] else ...[
              // Wenn keine Sets geloggt wurden, nur eine Beenden-Option anzeigen
              ElevatedButton(
                onPressed: () {
                  // Workout abbrechen, ohne Sets zu speichern
                  state.cancelWorkout();
                  Navigator.of(context).pop();

                  // Stellen Sie sicher, dass nach dem Abbrechen alle Zustände korrekt zurückgesetzt werden
                  state.resetWorkoutState();
                  if (mounted) setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF95738),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 0),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('WORKOUT BEENDEN'),
              ),
            ],
            SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withOpacity(0.7),
                padding: EdgeInsets.symmetric(vertical: 14),
                minimumSize: Size(double.infinity, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
              ),
              child: Text('ABBRECHEN'),
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to a new view while preserving history
  void _navigateTo(String view) {
    setState(() {
      _previousView = _currentView;
      _currentView = view;
    });
  }

  // Navigate directly to the plans view (home screen)
  void _navigateToHome() {
    setState(() {
      _previousView = 'plans'; // Set this so back button works correctly after
      _currentView = 'plans';
    });
  }

  // Go back to the previous view
  void _goBack() {
    // Check if we need to discard a draft plan
    if (_currentView == 'edit') {
      final state = Provider.of<WorkoutTrackerState>(context, listen: false);
      if (!state.isPlanSaved) {
        // When going back from edit screen with unsaved plan, check if it's empty
        // and we're returning to the create screen
        if (_previousView == 'create') {
          state.discardCurrentPlan();
        }
      }
    }

    setState(() {
      _currentView = _previousView;
      // Default to plans if previous view is the same as current
      // (this prevents navigation loops)
      if (_previousView == _currentView) {
        _previousView = 'plans';
      }
    });
  }

  Widget _buildCurrentView() {
    final state = Provider.of<WorkoutTrackerState>(context, listen: false);

    switch (_currentView) {
      case 'plans':
        return HomeScreen(
          onCreatePressed: () => _navigateTo('create'),
          onEditPressed: (plan) {
            state.setCurrentPlan(plan);
            _navigateTo('edit');
          },
          onWorkoutPressed: (plan, day) {
            state.startWorkout(plan, day);
            _navigateTo('workout');
          },
        );
      case 'create':
        return CreatePlanScreen(
          onBackPressed: _goBack,
          onPlanCreated: () => _navigateTo('edit'),
        );
      case 'edit':
        return EditPlanScreen(
          onBackPressed: _goBack,
          onDiscardAndGoHome: _navigateToHome,
        );
      case 'workout':
        return WorkoutScreen(
          onBackPressed: () {
            // Minimiere das Workout, anstatt es zu beenden
            state.minimizeWorkout();
            _navigateToHome();
          },
          onFinished: () {
            // Workout wurde ordnungsgemäß abgeschlossen
            state.resetWorkoutState();
            _navigateTo('plans');
          },
        );
      default:
        return HomeScreen(
          onCreatePressed: () => _navigateTo('create'),
          onEditPressed: (plan) {
            state.setCurrentPlan(plan);
            _navigateTo('edit');
          },
          onWorkoutPressed: (plan, day) {
            state.startWorkout(plan, day);
            _navigateTo('workout');
          },
        );
    }
  }
}
