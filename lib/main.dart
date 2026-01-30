import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// --- NEUE IMPORTS ---
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stutz/firebase_options.dart'; // Die generierte Datei

// Screens
import 'package:stutz/presentation/screens/home_screen.dart';
import 'package:stutz/presentation/screens/onboarding/welcome_screen.dart';
import 'package:stutz/presentation/screens/onboarding/login_screen.dart';

void main() async {
  // 1. Bindings initialisieren
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Debug Check (Wakelock)
  if (kDebugMode) {
    WakelockPlus.enable();
    print("🚀 Wakelock aktiviert: Der Bildschirm bleibt an.");
  }

  // 3. Firebase Starten (jetzt mit Optionen!)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 4. Prüfen: Wohin soll der User geleitet werden?

  // A) Hat er das Tutorial schon gesehen?
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  // B) Ist er schon eingeloggt?
  final user = FirebaseAuth.instance.currentUser;

  // C) Entscheidung treffen
  Widget startScreen;

  if (user != null) {
    // Eingeloggt -> Ab ins Dashboard (HomeScreen)
    startScreen = const HomeScreen();
  } else if (seenOnboarding) {
    // Tutorial schon gesehen, aber ausgeloggt -> Login Screen
    startScreen = const LoginScreen();
  } else {
    // Ganz neu -> Welcome Screen
    startScreen = const WelcomeScreen();
  }

  // 5. App starten und Start-Screen übergeben
  // (const entfernt, da startScreen dynamisch ist)
  runApp(ProviderScope(child: MainApp(startScreen: startScreen)));
}

class MainApp extends StatelessWidget {
  final Widget startScreen;

  // Konstruktor nimmt jetzt den startScreen entgegen
  const MainApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,

      supportedLocales: const [
        Locale('de', 'CH'), // Deutsch
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
      // Hier nutzen wir die Entscheidung aus der main()
      home: startScreen,
    );
  }
}
