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
  final VoidCallback? onEdit;
  final VoidCallback? onAdd;
  final bool expandable;
  final bool initiallyExpanded;

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
    this.onEdit,
    this.onAdd,
    this.expandable = false,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCardBody(
      title: title,
      totalMonthly: totalMonthly,
      totalYearly: totalYearly,
      icon: icon,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      onHeaderTap: onHeaderTap,
      onEdit: onEdit,
      onAdd: onAdd,
      expandable: expandable,
      initiallyExpanded: initiallyExpanded,
      children: children,
    );
  }
}

class _SectionCardBody extends StatefulWidget {
  final String title;
  final double totalMonthly;
  final double totalYearly;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final List<Widget> children;
  final VoidCallback? onHeaderTap;
  final VoidCallback? onEdit;
  final VoidCallback? onAdd;
  final bool expandable;
  final bool initiallyExpanded;

  const _SectionCardBody({
    required this.title,
    required this.totalMonthly,
    required this.totalYearly,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.children,
    required this.onHeaderTap,
    required this.onEdit,
    required this.onAdd,
    required this.expandable,
    required this.initiallyExpanded,
  });

  @override
  State<_SectionCardBody> createState() => _SectionCardBodyState();
}

class _SectionCardBodyState extends State<_SectionCardBody> {
  late bool _isExpanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasHeaderAction = widget.onEdit != null || widget.onAdd != null;
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.icon, color: widget.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildTotals(context),
              ],
            ),
          ),
          if (widget.totalYearly > 0)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                "Ø ${(widget.totalMonthly + widget.totalYearly / 12).toStringAsFixed(0)}",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: widget.iconColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (widget.onEdit != null)
            IconButton(
              tooltip: 'Bearbeiten',
              onPressed: widget.onEdit,
              icon: const Icon(Icons.edit_outlined),
              visualDensity: VisualDensity.compact,
            ),
          if (widget.onAdd != null)
            IconButton(
              tooltip: 'Eintrag hinzufügen',
              onPressed: widget.onAdd,
              icon: const Icon(Icons.add),
              visualDensity: VisualDensity.compact,
            ),
          if (widget.expandable)
            IconButton(
              tooltip: _isExpanded ? 'Einklappen' : 'Ausklappen',
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );

    final headerWithInteraction = widget.expandable
        ? header
        : widget.onHeaderTap != null
        ? InkWell(
            onTap: widget.onHeaderTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: header,
          )
        : header;

    return Card(
      color: widget.backgroundColor,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerWithInteraction,
          if ((!widget.expandable || _isExpanded) &&
              (hasHeaderAction || widget.children.isNotEmpty))
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: colorScheme.outlineVariant,
            ),
          if (!widget.expandable || _isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTotals(BuildContext context) {
    final parts = <String>[];
    if (widget.totalMonthly > 0) {
      parts.add("${widget.totalMonthly.toStringAsFixed(2)} / Monat");
    }
    if (widget.totalYearly > 0) {
      parts.add("${widget.totalYearly.toStringAsFixed(2)} / Jahr");
    }
    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join("  -  "),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
