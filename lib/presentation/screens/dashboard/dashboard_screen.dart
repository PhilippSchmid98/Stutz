import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stutz/data/auth_service.dart';
import 'package:stutz/presentation/providers/dashboard_providers.dart';
import 'package:stutz/presentation/screens/dashboard/widgets/current_month_card.dart';
import 'package:stutz/presentation/screens/dashboard/widgets/past_month_tile.dart';
import 'package:stutz/presentation/screens/onboarding/welcome_screen.dart';
import 'package:stutz/presentation/screens/transactions/add_transaction_dialog.dart';
import 'package:stutz/presentation/screens/widgets/cloud_status_icon.dart';
import 'package:stutz/presentation/screens/yearly_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardMonthlyStatsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          const CloudStatusIcon(),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: "Jahresübersicht",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const YearlyDetailScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final auth = ref.read(authServiceProvider);
              await auth.signOut();

              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'dashboard_fab',
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Neue Ausgabe"),
        elevation: 4,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddTransactionDialog(),
          );
        },
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (stats) {
          if (stats.isEmpty) return const Center(child: Text("Keine Daten"));

          final currentMonth = stats.first;
          final pastMonths = stats.sublist(1);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Aktueller Monat",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                CurrentMonthCard(status: currentMonth),
                const SizedBox(height: 32),
                const Text(
                  "Vergangene Monate",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                ...pastMonths.map((m) => PastMonthTile(status: m)),
              ],
            ),
          );
        },
      ),
    );
  }
}
