# 02 Architecture

## Clean Architecture Layer Structure

- **lib/domain/**
  - entities/
  - repositories/
  - usecases/
- **lib/data/**
  - datasources/
  - models/ (DTOs)
  - repositories/ (implementations)
- **lib/presentation/**
  - screens/
  - widgets/
  - providers/


## Data Modeling: Recursive/Nested Expenses

### Composite Pattern for Expenses
- Each expense category or item is a node in a tree.
- **Fields:**
  - id (unique)
  - parentId (nullable, for root nodes)
  - name
  - amount (nullable for non-leaf)
  - interval (Monthly/Yearly, nullable for non-leaf)
  - type (Fixed/Variable, only for leaf)
  - children (virtual, resolved by parentId)

### Drift Implementation
- Use a flat table with parentId links for flexibility and easier querying (Drift/SQLite is relational and well-suited for this).
- Each node references its parent by parentId (null for root).
- Aggregation is done recursively in code or via SQL queries.

### Repository Interface Example
```dart
abstract class ExpenseRepository {
  Future<List<ExpenseNode>> getExpenseTree();
  Future<void> addExpenseNode(ExpenseNode node);
  Future<void> updateExpenseNode(ExpenseNode node);
  Future<void> deleteExpenseNode(String id);
  // ...other methods for aggregation, etc.
}
```

## ER/Class Diagram (Textual)
- **IncomeSource**: id, name, amount, interval, group
- **ExpenseNode**: id, parentId, name, amount, interval, type
- **Transaction**: id, expenseNodeId, amount, dateTime

(Relationships: ExpenseNode has parentId; Transaction links to ExpenseNode)
