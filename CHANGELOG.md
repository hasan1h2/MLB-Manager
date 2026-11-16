# MLB Manager — Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-11-15
### Initial Release & Phase 1 Foundation
- Project scaffolding with Flutter 3.38.x and Dart 3.10.x.
- Modular feature-based Clean GetX architecture.
- Full Drift ORM database configuration with 34 tables covering:
  - Core: `family_members`, `businesses`, `accounts`, `categories`, `transactions`, `transaction_entries`, `transaction_attachments`
  - Household: `shopping_records`, `shopping_items`, `shopping_lists`, `shopping_list_items`
  - Parties: `customers`, `suppliers`, `party_payments`
  - Inventory: `products`, `inventory_movements`, `purchase_records`, `purchase_items`, `sales_records`, `sales_items`
  - Cattle: `cattle`, `cattle_expenses`, `cattle_sales`
  - Loans: `loan_accounts`, `loan_payments`
  - Assets: `assets`, `savings_goals`, `investments`
  - Budget & Reminders: `budgets`, `reminders`
  - AI & App: `ai_extractions`, `app_settings`, `audit_logs`, `attachments`
- Complete dual localization: Bengali (`bn_BD`, default) and English (`en_US`).
- Material Design 3 theme system with Deep Navy Blue and Electric Blue palette.
- Exact monetary engine using integer minor units (Poisha).
- Core UI navigation with Bottom Bar and central Floating Action Button.
- 54 production-ready screens spanning all 20 documented modules.
- End-to-end integration with Drift SQLite In-Memory and persistent databases.
- Automated unit, database, and widget test suites (17/17 tests passing with 100% green status).
- Zero `flutter analyze` errors and zero warnings across the entire codebase.
