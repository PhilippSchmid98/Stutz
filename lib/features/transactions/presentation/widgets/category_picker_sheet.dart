import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/shared/widgets/app_bottom_sheet.dart';
import 'package:stutz/shared/widgets/styled_field_decoration.dart';

class CategoryPickerSheet extends StatefulWidget {
  final AsyncValue<List<ExpenseNode>> categories;
  final String? selectedNodeId;

  const CategoryPickerSheet({
    super.key,
    required this.categories,
    required this.selectedNodeId,
  });

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Kategorie wählen',
      actions: const [],
      content: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.56,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration:
                  styledFieldDecoration(
                    label: 'Kategorie suchen',
                    icon: Icons.search,
                    variant: StyledFieldVariant.transaction,
                  ).copyWith(
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Suche löschen',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildCategoryList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return widget.categories.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Text(
          'Kategorien konnten nicht geladen werden.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      data: (categories) {
        final normalizedQuery = _query.trim().toLowerCase();
        final filtered = normalizedQuery.isEmpty
            ? categories
            : categories
                  .where(
                    (category) =>
                        category.name.toLowerCase().contains(normalizedQuery),
                  )
                  .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              normalizedQuery.isEmpty
                  ? 'Noch keine variablen Kategorien vorhanden.'
                  : 'Keine passende Kategorie gefunden.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        final colorScheme = Theme.of(context).colorScheme;
        return ListView.separated(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final category = filtered[index];
            final isSelected = category.id == widget.selectedNodeId;
            return Material(
              color: isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.35)
                  : colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => Navigator.pop(context, category),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check, color: colorScheme.primary),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
