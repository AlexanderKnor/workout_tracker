// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/workout_provider.dart';
import 'screens/home_screen.dart';
import 'screens/create_plan_screen.dart';
import 'screens/edit_plan_screen.dart';
import 'screens/workout_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentView(),
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
