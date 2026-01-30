import 'package:flutter/material.dart';
import 'package:stutz/presentation/screens/dashboard_screen.dart';
import 'package:stutz/presentation/screens/budget_planning_table_screen.dart';
import 'package:stutz/presentation/screens/transactions/transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Lokaler State für den Index – das ist hier völlig ausreichend
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Die Screens, zwischen denen wir wechseln
    const screens = [
      DashboardScreen(),
      BudgetPlanningTableScreen(),
      TransactionScreen(),
    ];

    return Scaffold(
      // IndexedStack hält den State der Screens (z.B. Scrollposition)
      body: IndexedStack(index: _currentIndex, children: screens),

      // Navigation Bar
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          // setState baut das Widget neu mit dem neuen Index
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Planung',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Ausgaben',
          ),
        ],
      ),
    );
  }
}
