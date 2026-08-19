import 'package:flutter/material.dart';

enum StyledFieldVariant { budget, transaction }

InputDecoration styledFieldDecoration({
  required String label,
  IconData? icon,
  String? suffixText,
  StyledFieldVariant variant = StyledFieldVariant.budget,
}) {
  if (variant == StyledFieldVariant.transaction) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: Colors.grey.shade400, size: 20),
      suffixText: suffixText,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),
    );
  }

  return InputDecoration(
    labelText: label,
    prefixIcon: icon == null ? null : Icon(icon, color: Colors.grey),
    suffixText: suffixText,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.teal, width: 2),
    ),
    filled: true,
    fillColor: Colors.grey.shade50,
  );
}
