import 'package:stutz/presentation/screens/onboarding/welcome_screen.dart';
import 'package:stutz/data/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stutz/presentation/providers/dashboard_providers.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/screens/monthly_detail_screen.dart';
import 'package:stutz/presentation/screens/transactions/add_transaction_dialog.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:stutz/presentation/screens/yearly_detail_screen.dart';
import 'package:stutz/presentation/screens/widgets/cloud_status_icon.dart';

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
              // 1. Clean logout (Google + Firebase)
              // Using AuthService, as it cleans up both
              final auth = ref.read(authServiceProvider);
              await auth.signOut();

              // 2. Clear SharedPreferences (App Reset)
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // 3. Navigation
              if (context.mounted) {
                // Navigate directly to widget since '/' is not defined as a route
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                  (route) => false, // Remove all previous screens from the stack
                );
              }
            },
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // FAB for new transactions
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

          final currentMonth = stats.first; // Index 0 is the current month
          final pastMonths = stats.sublist(1); // Remaining months

          return SingleChildScrollView(
            // Increased bottom padding to prevent FAB overlap
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

                // 1. Large card for current month (circular)
                _CurrentMonthCard(status: currentMonth),

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

                // 2. List of past months (linear)
                ...pastMonths.map((m) => _PastMonthTile(status: m)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGETS
// -----------------------------------------------------------------------------

class _CurrentMonthCard extends StatelessWidget {
  final MonthlyBudgetStatus status;

  const _CurrentMonthCard({required this.status});

  @override
  Widget build(BuildContext context) {
    Color progressColor = Colors.teal;
    if (status.percentage > 1.0) {
      progressColor = Colors.red;
    } else if (status.percentage > 0.85) {
      progressColor = Colors.orange;
    }

    final percentDisplay = (status.percentage * 100)
        .clamp(0, 999)
        .toStringAsFixed(0);

    final safePercent = status.percentage.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MonthlyDetailScreen(month: status.month),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              DateFormat('MMMM yyyy', 'de_DE').format(status.month),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              status.remaining >= 0
                  ? "Verfügbares Budget"
                  : "Budget überschritten",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 24),

            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 12.0,
              animation: true,
              animationDuration: 1000,
              percent: safePercent,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: progressColor,
              backgroundColor: Colors.grey.shade100,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${status.remaining.abs().toStringAsFixed(0)}.-",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: status.remaining >= 0 ? Colors.black : Colors.red,
                    ),
                  ),
                  Text(
                    "CHF",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              footer: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatColumn(
                      label: "Ausgegeben",
                      value: status.totalSpent.toStringAsFixed(0),
                      color: Colors.grey.shade800,
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    _StatColumn(
                      label: "Geplant",
                      value: status.totalPlanned.toStringAsFixed(0),
                      color: Colors.grey.shade800,
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    _StatColumn(
                      label: "Verbraucht",
                      value: "$percentDisplay%",
                      color: progressColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
      ],
    );
  }
}

class _PastMonthTile extends StatelessWidget {
  final MonthlyBudgetStatus status;

  const _PastMonthTile({required this.status});

  @override
  Widget build(BuildContext context) {
    Color barColor = Colors.teal;
    if (status.percentage > 1.0) {
      barColor = Colors.red;
    } else if (status.percentage > 0.85) {
      barColor = Colors.orange;
    }

    final safePercent = status.percentage.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MonthlyDetailScreen(month: status.month),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM', 'de_DE').format(status.month),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        DateFormat('yy', 'de_DE').format(status.month),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Ausgaben",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "${(status.percentage * 100).toStringAsFixed(0)}%",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: barColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'Roboto',
                          ),
                          children: [
                            TextSpan(
                              text: "${status.totalSpent.toStringAsFixed(0)} ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "/ ${status.totalPlanned.toStringAsFixed(0)} CHF",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearPercentIndicator(
              lineHeight: 8.0,
              percent: safePercent,
              animation: true,
              animationDuration: 800,
              barRadius: const Radius.circular(4),
              progressColor: barColor,
              backgroundColor: Colors.grey.shade100,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
