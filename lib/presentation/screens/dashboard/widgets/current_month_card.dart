import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/screens/dashboard/widgets/stat_column.dart';
import 'package:stutz/presentation/screens/monthly_detail_screen.dart';

class CurrentMonthCard extends StatelessWidget {
  final MonthlyBudgetStatus status;

  const CurrentMonthCard({super.key, required this.status});

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
                    StatColumn(
                      label: "Ausgegeben",
                      value: status.totalSpent.toStringAsFixed(0),
                      color: Colors.grey.shade800,
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    StatColumn(
                      label: "Geplant",
                      value: status.totalPlanned.toStringAsFixed(0),
                      color: Colors.grey.shade800,
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    StatColumn(
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
