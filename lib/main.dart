import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stutz/app/app_loading_screen.dart';
import 'package:stutz/app/app_router.dart';
import 'package:stutz/core/theme/app_theme.dart';
import 'package:stutz/firebase_options.dart';
import 'package:stutz/features/transactions/data/transaction_month.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TransactionMonth.initialize();

  if (kDebugMode) {
    WakelockPlus.enable();
  }

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatefulWidget {
  final Future<void> Function() initializeFirebase;

  const MainApp({super.key, this.initializeFirebase = _initializeFirebase});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = widget.initializeFirebase();
  }

  void _retryInitialization() {
    setState(() {
      _initialization = widget.initializeFirebase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('de', 'CH')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      home: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppInitializationErrorScreen(onRetry: _retryInitialization);
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const AppLoadingScreen(message: 'Stutz wird gestartet');
          }
          return const AppRouter();
        },
      ),
    );
  }
}

Future<void> _initializeFirebase() {
  return Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
