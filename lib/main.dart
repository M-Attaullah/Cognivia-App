import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cognivia_app/firebase_options.dart';
import 'package:cognivia_app/core/constants/app_strings.dart';
import 'package:cognivia_app/core/theme/light_theme.dart';
import 'package:cognivia_app/core/theme/dark_theme.dart';
import 'package:cognivia_app/core/services/ad_manager.dart';
import 'package:cognivia_app/presentation/screens/splash/splash_screen.dart';
import 'package:cognivia_app/presentation/providers/auth_provider.dart';
import 'package:cognivia_app/presentation/providers/quiz_provider.dart';
import 'package:cognivia_app/presentation/providers/task_provider.dart';
import 'package:cognivia_app/presentation/providers/chat_provider.dart';

void main() async {
  debugPrint('CogniVia: Starting app initialization...');
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    debugPrint('CogniVia: Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('CogniVia: Firebase initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('CogniVia: Failed to initialize Firebase: $e');
    debugPrint('CogniVia: Stack trace: $stackTrace');
    // Don't return here - continue with app initialization
  }

  // Initialize Mobile Ads
  try {
    debugPrint('CogniVia: Initializing Mobile Ads...');
    await MobileAds.instance.initialize();
    debugPrint('CogniVia: Mobile Ads initialized successfully');
  } catch (e) {
    debugPrint('CogniVia: Failed to initialize AdMob: $e');
  }

  // Initialize AdManager
  try {
    debugPrint('CogniVia: Initializing AdManager...');
    await AdManager.instance.init();
    debugPrint('CogniVia: AdManager initialized successfully');
  } catch (e) {
    debugPrint('CogniVia: Failed to initialize AdManager: $e');
  }

  debugPrint('CogniVia: Running app...');
  runApp(const CogniViaApp());
}

class CogniViaApp extends StatefulWidget {
  const CogniViaApp({super.key});

  @override
  State<CogniViaApp> createState() => _CogniViaAppState();
}

class _CogniViaAppState extends State<CogniViaApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: _themeMode,
        home: SplashScreen(
          onThemeToggle: _toggleTheme,
          currentThemeMode: _themeMode,
        ),
      ),
    );
  }
}
