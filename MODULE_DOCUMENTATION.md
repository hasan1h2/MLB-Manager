# MLB Manager — Module Documentation

This document describes all 20 modules implemented in MLB Manager.

---

## 1. Dashboard
- **Scope**: Aggregates all personal, family, and multi-business activities.
- **Key Metrics**: Available Balance, Total Income, Total Expenses, Business Profit, Money Receivable, Money Payable, Total Savings, Total Assets.
- **Filters**: Today, Yesterday, Last 7 Days, This Month, Last Month, This Year, Custom Date Range.
- **Components**: Income vs Expense Chart, Monthly Trend, Business Profit Breakdown, Family Expense Distribution, Recent Activity Ledger, Due Reminders, Low Stock Indicators, Statistical AI Insights.

---

## 2. Personal Finance
- **Scope**: Tracks individual income streams and personal expenses.
- **Income Categories**: Salary, Freelance, Business, Rental, Agriculture, Service, Investments, Gifts, Other.
- **Expense Categories**: Personal Shopping, Food, Clothing, Transport, Healthcare, Education, Entertainment, Mobile/Internet, Travel, Misc.
- **Transactions**: Full CRUD, account selector, payment methods, attachments, tags, member tagging.

---

## 3. Family Management
- **Scope**: Profiles and permissions for household members.
- **Roles**: Owner, Administrator, Family Member, Viewer.
- **Features**: Profile photo, member-specific activity tracking, granular permissions for transaction creation, modification, report viewing, and administrative capabilities.

---

## 4. Household Shopping
- **Scope**: Multi-item grocery and household supply procurement.
- **Features**: Multi-item entry per bill, store identification, quantity and unit tracking, price comparison with past purchases, repeat shopping item lists, monthly grocery budget alerts, receipt scanner integration, and non-duplicating expense posting.

---

## 5. Multi-Business Management
- **Scope**: Independent ledger and profit-and-loss tracking for multiple enterprises.
- **Business Types**: Cattle, Grocery, Wholesale, Retail, Raw Materials, Agriculture, Manufacturing, Service, Custom.
- **Dashboards**: Independent balance sheet, sales, purchases, operating overheads, gross profit, net profit, receivables, payables, owner capital contributions, and owner withdrawals.

---

## 6. Cattle Management
- **Scope**: Specialized cattle farming and livestock accounting.
- **Features**: Tag number, breed, gender, weight, purchase record, seller tracking, lifecycle status (active, sold, deceased).
- **Cost Allocation**: Daily feed costs, medical/veterinary expenses, vaccines, labor, and transport.
- **Sales & Profit**: Sale price vs total allocated costs yielding exact individual animal net margin.

---

## 7. Inventory Management
- **Scope**: Stock control for retail, wholesale, and production businesses.
- **Features**: SKU, barcode, unit definition, purchase price, selling price, current stock, reorder levels.
- **Operations**: Stock In, Stock Out, Purchase receipt, Sales delivery, Returns, Adjustments, Damage/Wastage write-offs.
- **Valuation**: Weighted Average Costing (WAC) engine.

---

## 8. Customer & Supplier Management
- **Scope**: Commercial relationship management.
- **Features**: Contact directories, opening balances, transaction ledgers, credit terms, partial payment receipts/disbursements, and running balances.

---

## 9. Loan & Due Management
- **Scope**: Personal and business loans (Receivable & Payable).
- **Features**: Principal amount, due dates, payment history, settlement, overdue warnings, optional flat/reducing interest calculations.

---

## 10. Accounts & Wallets
- **Scope**: Real monetary repositories (Cash, Bank, bKash, Nagad, Rocket, Custom).
- **Features**: Double-entry journal balance calculations, internal non-revenue transfers, deposits, withdrawals, reconciliation statements.

---

## 11. Assets, Savings & Investments
- **Scope**: Wealth and long-term asset management.
- **Assets**: Land, buildings, gold, vehicles, machinery, cattle assets with estimated current valuation.
- **Savings Goals**: Target amounts, deadlines, linked accounts, progress meters.
- **Investments**: Capital outlay, returns, current valuation.

---

## 12. Budget Management
- **Scope**: Proactive fiscal guardrails.
- **Levels**: Personal, Family, Business, Category, Monthly, Yearly.
- **Features**: Spending limits, actual consumption, remaining allowances, warning thresholds (e.g. 80%), and over-budget alerts.

---

## 13. Reports & Analytics
- **Scope**: Comprehensive financial statements and operational audits.
- **Formats**: On-screen dynamic charts, PDF exports, Excel (.xlsx) spreadsheets, CSV data exports, and direct printing.
- **Statements**: Daily/Weekly/Monthly/Yearly Profit & Loss, Balance Sheet Summary, Cash Flow, Category Breakdown, Ledger Statements.

---

## 14. AI Assistant & Voice Input
- **Scope**: Natural language transaction capture and local data intelligence.
- **Voice Entry**: Bengali and English speech parsing into structured transactions (Product, Quantity, Unit, Price, Category) with mandatory user verification.
- **OCR Scanner**: Local image text recognition for store receipts with pre-commit field review.
- **Statistical Analytics**: Moving-average expense forecasts, anomaly alerts, and actionable financial summaries.

---

## 15. Notifications & Reminders
- **Scope**: Offline local schedule alerts.
- **Triggers**: Loan due dates, supplier payments, customer follow-ups, utility bills, salary payouts, low inventory thresholds, and budget alerts.

---

## 16. Documents & Attachments
- **Scope**: Local digital filing cabinet.
- **Support**: Invoices, receipts, contracts, certificates, animal photographs, product images stored securely on device storage with DB references.

---

## 17. Backup & Restore
- **Scope**: Data preservation and disaster recovery.
- **Formats**: Encrypted JSON, ZIP archive including attachments.
- **Safety**: Validation checksums, schema version verification, conflict alerts, and pre-restore confirmations.

---

## 18. Settings & Security
- **Scope**: Configuration and access governance.
- **Security**: 4-to-6 digit App PIN, Biometric authentication (fingerprint/face), auto-lock timer, obfuscated audit logs.
- **Preferences**: Language (Bengali default, English switchable), currency, number format, date format, dark/light themes.
