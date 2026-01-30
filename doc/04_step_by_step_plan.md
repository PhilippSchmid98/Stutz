# 04 Step-by-Step Plan

1. **Setup Project & Dependencies**
   - ✅ Initialize Flutter project
   - ✅ Add dependencies: drift, drift_flutter, sqlite3_flutter_libs, riverpod, hooks_riverpod, riverpod_generator, freezed, etc.


2. **Project Structure**
   - ✅ Create Clean Architecture folders: lib/domain, lib/data, lib/presentation

3. **Domain Layer**
   - ✅ Define entities: IncomeSource, ExpenseNode, Transaction
   - ✅ Define repository interfaces
   - ✅ Define use cases

4. **Data Layer**
   - ✅ Setup Drift tables and DAOs (DTOs)
   - ✅ Implement data sources
   - ✅ Implement repository implementations

5. **Presentation Layer**
   - ⬜ Setup providers (Riverpod)
   - ⬜ Build basic UI skeleton/screens (Dashboard, Budget Planning, Tracking, Analysis)

6. **Budget Planning Features**
   - ⬜ Implement income and expense management (tree structure)
   - ⬜ Aggregation logic for totals

7. **Dashboard**
   - ⬜ Show calculated totals and budget health

8. **Variable Expense Tracking**
   - ⬜ Log transactions for variable items
   - ⬜ Monthly reset logic

9. **Analysis Features**
   - ⬜ Compare planned vs. actual spending
   - ⬜ Visualizations (charts)

10. **Polish UI/UX**
   - ⬜ Material 3, responsive design, accessibility

11. **Testing & QA**
   - ⬜ Unit, widget, and integration tests

12. **Prepare for Cloud Migration**
   - ⬜ Ensure repository abstraction is strict
   - ⬜ Document migration steps
