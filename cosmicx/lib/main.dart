import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'views/auth_gate.dart'; // Import the new gate
import 'theme/app_theme.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const CosmicQuestApp());
}

class CosmicQuestApp extends StatefulWidget {
  const CosmicQuestApp({super.key});

  @override
  State<CosmicQuestApp> createState() => _CosmicQuestAppState();
}

class _CosmicQuestAppState extends State<CosmicQuestApp> {
  late ThemeMode _themeMode;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final isDark = await ThemeService.isDarkMode();
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _initialized = true;
    });
  }

  void updateTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: AppTheme.spaceBlack,
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.neonBlue),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Cosmic Quest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,

      // The AuthGate handles routing automatically now!
      home: AuthGate(onThemeChange: updateTheme),
    );
  }
}
