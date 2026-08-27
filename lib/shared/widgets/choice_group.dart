import 'package:flutter/material.dart';

class AppChoiceGroup<T> extends StatelessWidget {
  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  const AppChoiceGroup({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<T>(
              segments: items.entries
                  .map(
                    (entry) => ButtonSegment<T>(
                      value: entry.key,
                      label: Text(entry.value),
                    ),
                  )
                  .toList(),
              selected: {value},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) onChanged(selection.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.standard,
                tapTargetSize: MaterialTapTargetSize.padded,
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerLowest,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
