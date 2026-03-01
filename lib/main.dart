import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stutz/firebase_options.dart';
import 'package:stutz/presentation/screens/home_screen.dart';
import 'package:stutz/presentation/screens/onboarding/welcome_screen.dart';
import 'package:stutz/presentation/screens/onboarding/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    WakelockPlus.enable();
    print("🚀 Wakelock enabled: The screen will stay on.");
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  final user = FirebaseAuth.instance.currentUser;

  Widget startScreen;

  if (user != null) {
    startScreen = const HomeScreen();
  } else if (seenOnboarding) {
    startScreen = const LoginScreen();
  } else {
    startScreen = const WelcomeScreen();
  }

  runApp(ProviderScope(child: MainApp(startScreen: startScreen)));
}

class MainApp extends StatelessWidget {
  final Widget startScreen;

  const MainApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('de', 'CH'), // German (Switzerland)
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      home: startScreen,
    );
  }
}
