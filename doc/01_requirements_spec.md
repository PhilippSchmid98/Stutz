# 01 Requirements Specification

## App Name
**BudgetVibe** (suggested, but open to alternatives)

## Purpose
A personal finance app for budget planning and expense tracking, supporting nested categories and clear distinction between fixed and variable costs.

## Functional Requirements

### 1. Budget Planning (Core Model)
- **Income (Einnahmen):**
  - Multiple sources, each with Name, Amount, Interval (Monthly/Yearly)
  - Grouped as "Main Income" and "Additional Income"
  - Yearly income is divided by 12 for monthly view
- **Expenses (Ausgaben):**
  - Composite (tree) structure: Main Categories → Sub-Groups → Leaf Expenses
  - Leaf nodes: Name, Amount, Interval (Monthly/Yearly), Type (Fixed/Variable)
  - Aggregation: Totals at every level, yearly values shown as monthly averages
  - Visuals: Indentation and bolding to show hierarchy

### 2. Dashboard & Overview
- Show total monthly income and expenses
- Show surplus/deficit with green/red indicator

### 3. Variable Expense Tracking
- Only for variable leaf nodes
- Log transactions: Amount, Date, Time
- Fixed costs are not tracked manually
- Tracking resets monthly

### 4. Analysis
- Compare planned vs. actual spending for variable items (current month)

## Non-Functional & Technical Requirements
- **Flutter (Latest Stable)**
- **Clean Architecture** (Domain, Data, Presentation layers)
- **Drift** (SQLite) for local-first storage, strict repository pattern
  - The UI must NOT know about Drift. It should only talk to the Repository Interface. This is to facilitate a future migration to a Cloud Backend (e.g., Firebase/Supabase) without rewriting the app logic.
- **State Management:** Riverpod (flutter_riverpod), riverpod_generator, hooks_riverpod
- **Data Modeling:** freezed
- **UI/UX:** Material 3
