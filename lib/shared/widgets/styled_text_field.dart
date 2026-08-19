import 'package:flutter/material.dart';
import 'package:stutz/shared/widgets/styled_field_decoration.dart';

class StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? suffixText;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final bool enabled;
  final StyledFieldVariant variant;

  const StyledTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.suffixText,
    this.validator,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.enabled = true,
    this.variant = StyledFieldVariant.budget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        autofocus: autofocus,
        enabled: enabled,
        maxLines: maxLines,
        decoration: styledFieldDecoration(
          label: label,
          icon: icon,
          suffixText: suffixText,
          variant: variant,
        ),
        validator:
            validator ?? (v) => v == null || v.isEmpty ? 'Pflichtfeld' : null,
      ),
    );
  }
}
