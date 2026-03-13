import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/screens/transactions/widgets/transaction_item.dart';

class DailyTransactionGroup extends StatelessWidget {
  final DailyTransactions group;

  const DailyTransactionGroup({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('dd.MM', 'de_DE');
    final weekDayFormat = DateFormat('EEEE', 'de_DE');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    dayFormat.format(group.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    weekDayFormat.format(group.date),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
              Text(
                '-${group.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            children: group.transactions
                .map((item) => TransactionItem(item: item))
                .toList(),
          ),
        ),
      ],
    );
  }
}
