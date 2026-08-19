import 'package:flutter/material.dart';
import 'package:stutz/shared/widgets/styled_field_decoration.dart';

class StyledDropdown<T> extends StatelessWidget {
  final T value;
  final Map<T, String> items;
  final String label;
  final IconData icon;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final StyledFieldVariant variant;

  const StyledDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.enabled = true,
    this.variant = StyledFieldVariant.budget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: items.entries.map((e) {
          return DropdownMenuItem<T>(value: e.key, child: Text(e.value));
        }).toList(),
        onChanged: enabled ? onChanged : null,
        decoration: styledFieldDecoration(
          label: label,
          icon: icon,
          variant: variant,
        ),
      ),
    );
  }
}
