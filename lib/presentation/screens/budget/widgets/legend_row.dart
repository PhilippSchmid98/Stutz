import 'package:flutter/material.dart';

class LegendRow extends StatelessWidget {
  const LegendRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(Icons.lock_outline, "Fixkosten"),
          const SizedBox(width: 16),
          _legendItem(Icons.shopping_bag_outlined, "Variable Kosten"),
          const SizedBox(width: 16),
          _legendItem(Icons.folder_outlined, "Gruppe"),
        ],
      ),
    );
  }

  Widget _legendItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
