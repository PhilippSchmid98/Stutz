import 'package:flutter/material.dart';
import 'package:stutz/presentation/shared/swiss_currency_text.dart';

class ExpandableExpenseGroup extends StatefulWidget {
  final String title;
  final int itemCount;
  final double totalAmount;

  const ExpandableExpenseGroup({
    super.key,
    required this.title,
    required this.itemCount,
    required this.totalAmount,
  });

  @override
  State<ExpandableExpenseGroup> createState() => _ExpandableExpenseGroupState();
}

class _ExpandableExpenseGroupState extends State<ExpandableExpenseGroup> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // Basis-Karte (surface-container-lowest)
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16.0), // rounded-lg
      ),
      child: Column(
        children: [
          // --- HEADER (Klickbar zum Aufklappen) ---
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                // Farbwechsel bei Expansion zu surface-container-high
                color: _isExpanded
                    ? theme.colorScheme.surfaceContainerHighest
                    : Colors.transparent,
                borderRadius: _isExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(16))
                    : BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.folder,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.itemCount} POSTEN',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Hier würdest du idealerweise dein SwissCurrencyText Widget einbauen!
                  const SwissCurrencyText(amount: 2150),
                  const SizedBox(width: 12),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // --- BODY (Die einzelnen Posten, sichtbar wenn expanded) ---
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      // Keine Divider, nur Spacing-4 (16px)
                      children: [
                        _buildSubItem(
                          theme,
                          'Miete (inkl. NK)',
                          1850.00,
                          Icons.lock,
                        ),
                        const SizedBox(height: 16),
                        _buildSubItem(
                          theme,
                          'Internet & TV',
                          85.00,
                          Icons.lock,
                        ),
                        const SizedBox(height: 16),
                        _buildSubItem(
                          theme,
                          'Haushaltseinkauf',
                          215.00,
                          Icons.shopping_bag,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // Hilfsmethode für die Zeilen (z.B. "Miete")
  Widget _buildSubItem(
    ThemeData theme,
    String title,
    double amount,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight
                  .w500, // Fettdruck für Wichtigkeit, z.B. bei Haushaltseinkauf
            ),
          ),
        ),
        SwissCurrencyText(
          amount: 2150,
          amountStyle: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
