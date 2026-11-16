# MLB Manager — Testing Documentation

## Test Strategy Overview
Testing in MLB Manager spans multiple layers to guarantee mathematical accuracy, data integrity, and UI reliability:

1. **Unit Tests**:
   - Financial calculation rules (Account Balance, COGS, Net Profit, WAC, Cattle Net Margin).
   - Minor unit integer arithmetic (Poisha conversions and zero floating-point drift).
   - Double-entry debit/credit equation balancing.
   - Budget alerts and threshold triggers.

2. **Database Tests**:
   - Drift table operations (CRUD).
   - Foreign key constraint enforcement.
   - Atomic multi-table transactions (e.g., Transaction + TransactionEntries + InventoryMovements).
   - Data migration and schema integrity.

3. **Integration Tests**:
   - End-to-end transaction flows (Income, Expense, Transfer).
   - Household multi-item shopping bill posting without duplicate expenses.
   - Multi-business isolation (Business A transactions cannot leak into Business B).
   - Cattle purchase, cost tracking, and sale margin realization.

4. **UI & Localization Tests**:
   - Bengali and English language switching verification.
   - Navigation and bottom navigation switching.
   - Form validation feedback and state transitions.

---

## Running the Automated Test Suite
```bash
flutter test
```
To run tests with code coverage:
```bash
flutter test --coverage
```
