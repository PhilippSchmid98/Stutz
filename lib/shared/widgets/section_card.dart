import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final double totalMonthly;
  final double totalYearly;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final List<Widget> children;
  final VoidCallback? onHeaderTap;

  const SectionCard({
    super.key,
    required this.title,
    required this.totalMonthly,
    required this.totalYearly,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.children,
    this.onHeaderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: backgroundColor != Colors.white
            ? Border.all(color: iconColor.withValues(alpha: 0.2))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: onHeaderTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final List<String> parts = [];
                            if (totalMonthly > 0) {
                              parts.add(
                                "${totalMonthly.toStringAsFixed(2)} / Monat",
                              );
                            }
                            if (totalYearly > 0) {
                              parts.add(
                                "${totalYearly.toStringAsFixed(2)} / Jahr",
                              );
                            }
                            if (parts.isEmpty) return const SizedBox.shrink();
                            return Text(
                              parts.join("  -  "),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  if (totalYearly > 0)
                    Text(
                      "Ø ${(totalMonthly + totalYearly / 12).toStringAsFixed(0)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: iconColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: iconColor.withValues(alpha: 0.1),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class SubsectionTitle extends StatelessWidget {
  final String title;

  const SubsectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
