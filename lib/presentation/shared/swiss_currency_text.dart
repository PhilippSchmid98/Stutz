import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SwissCurrencyText extends StatelessWidget {
  final double amount;
  final TextStyle? amountStyle;

  const SwissCurrencyText({super.key, required this.amount, this.amountStyle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Schweizer Zahlenformat: 6'450.00 (wie in den Screenshots)
    final formatter = NumberFormat.currency(
      locale: 'de_CH',
      symbol: '',
      decimalDigits: 2,
    );
    final formattedAmount = formatter.format(amount).trim();

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: formattedAmount,
            // Fallback auf headlineMedium (Authoritative Voice)
            style: amountStyle ?? theme.textTheme.headlineMedium,
          ),
          const TextSpan(text: ' '), // Abstand
          TextSpan(
            text: 'CHF',
            // Inter, functional voice, on-surface-variant
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
