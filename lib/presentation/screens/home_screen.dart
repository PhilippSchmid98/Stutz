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
  // Local state for index is sufficient here
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Screens we switch between
    const screens = [
      DashboardScreen(),
      BudgetPlanningTableScreen(),
      TransactionScreen(),
    ];

    return Scaffold(
      // IndexedStack maintains screen state (e.g., scroll position)
      body: IndexedStack(index: _currentIndex, children: screens),

      // Navigation bar
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          // setState rebuilds the widget with new index
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
