import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/screens/monthly_detail_screen.dart';

class PastMonthTile extends StatelessWidget {
  final MonthlyBudgetStatus status;

  const PastMonthTile({super.key, required this.status});

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
