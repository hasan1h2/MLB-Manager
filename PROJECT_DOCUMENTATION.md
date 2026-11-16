# MY LIFE & BUSINESS MANAGER
## Professional Project Requirements Specification (SRS + PRD)

Project Name My Life & Business Manager  
Short Name MLB Manager  
Application Type Personal Finance, Family Management & Multi-Business Accounting  
Platform Android  
Framework Flutter  
Language Dart  
State Management GetX  
Database SQLite with Drift ORM  
Architecture Modular, Feature-Based, Offline-First  
UI Languages Bengali and English  
Document Version 1.0.0  
Project Status Initial Development Specification

---

# 1. PROJECT OVERVIEW

## 1.1 Project Purpose

My Life & Business Manager is an offline-first Flutter application designed to manage personal finances, family expenses, household shopping, multiple businesses, income, expenses, assets, liabilities, inventory, customers, suppliers, and financial reports from a single Android application.

The application will allow users to manage all personal, family, and business financial activities independently while providing a consolidated financial overview.

## 1.2 Main Objectives

1. Manage personal income and expenses.
2. Maintain complete household shopping records.
3. Manage multiple family members and their financial activities.
4. Manage multiple businesses independently.
5. Maintain cattle buying, selling, feeding, treatment, and profit records.
6. Manage raw materials and inventory.
7. Maintain customer and supplier accounts.
8. Track money receivable and payable.
9. Manage cash, bank, and mobile financial accounts.
10. Track savings, investments, and assets.
11. Generate monthly, yearly, and custom financial reports.
12. Support voice-based transaction entry.
13. Extract transaction details from receipt images using OCR.
14. Generate intelligent financial insights.
15. Predict future expenses using historical financial data.
16. Protect all financial data through local security and backup.

## 1.3 Core Design Principles

- Offline-first operation.
- No mandatory account registration.
- Family-member-based data organization.
- Multiple independent business accounts.
- Accurate financial calculations.
- Bengali and English localization.
- Modular Flutter architecture.
- Local database as the primary data source.
- Future cloud synchronization compatibility.
- No hardcoded demo data in production.
- User confirmation before saving AI-extracted data.

---

# 2. APPLICATION MODULES

The application will contain the following primary modules.

1. Dashboard
2. Personal Finance
3. Family Management
4. Household Shopping
5. Business Management
6. Cattle Management
7. Inventory Management
8. Customer Management
9. Supplier Management
10. Income & Expense
11. Accounts & Wallets
12. Loan & Due Management
13. Assets & Savings
14. Budget Management
15. Reports & Analytics
16. AI Assistant
17. Documents & Attachments
18. Notifications & Reminders
19. Backup & Restore
20. Settings & Security

---

# 3. USER & FAMILY MANAGEMENT

## 3.1 Family Profiles

The application must support multiple family-member profiles on the same device.

Each family member must have

- Unique member ID
- Full name
- Profile photo
- Phone number (optional)
- Relationship
- Role
- Date of joining
- Status
- Notes

## 3.2 Roles and Permissions

Initial roles

- Owner
- Administrator
- Family Member
- Viewer

Permission examples

 Feature  Owner  Admin  Member  Viewer 
---------------
 View dashboard  Yes  Yes  Limited  Yes 
 Add transaction  Yes  Yes  Permission-based  No 
 Edit transaction  Yes  Yes  Own records  No 
 Delete transaction  Yes  Restricted  No  No 
 Manage family  Yes  Yes  No  No 
 Manage business  Yes  Permission-based  Permission-based  No 
 View reports  Yes  Yes  Limited  Yes 
 Manage backup  Yes  No  No  No 

All permissions must be configurable.

Important These roles provide application-level access on one device. They do not provide separate device authentication or remote multi-user access.

---

# 4. DASHBOARD

The Dashboard must provide an overview of the entire financial situation.

## 4.1 Summary Cards

- Total Available Balance
- Total Income
- Total Expenses
- Business Profit
- Money Receivable
- Money Payable
- Total Savings
- Total Assets

## 4.2 Dashboard Filters

- Today
- Yesterday
- Last 7 Days
- This Month
- Last Month
- This Year
- Custom Date Range

## 4.3 Dashboard Sections

- Income vs Expense Chart
- Monthly Spending Chart
- Business-wise Profit Chart
- Family Expense Breakdown
- Recent Transactions
- Upcoming Payments
- Outstanding Receivables
- Low Stock Alerts
- Financial Insights

## 4.4 Dashboard Rules

Every dashboard value must be calculated from actual database records.

Do not count internal transfers as income or expenses.

Do not count loan repayments as new income or duplicate expenses.

Separate operating profit from cash balance.

---

# 5. PERSONAL FINANCE MODULE

Manage all personal financial activities.

## 5.1 Income Categories

- Salary
- Freelancing
- Business Income
- Rental Income
- Agriculture Income
- Service Income
- Investment Return
- Gifts
- Other Income

## 5.2 Expense Categories

- Personal Shopping
- Food
- Clothing
- Transport
- Healthcare
- Education
- Entertainment
- Mobile & Internet
- Travel
- Other Expenses

## 5.3 Transaction Fields

- Transaction ID
- Transaction Type
- Amount
- Category
- Account
- Date
- Description
- Payment Method
- Attachment
- Created By
- Notes

---

# 6. FAMILY & HOUSEHOLD MANAGEMENT

## 6.1 Household Expense Categories

Food and groceries

- Rice
- Lentils
- Cooking Oil
- Salt
- Sugar
- Fish
- Meat
- Chicken
- Eggs
- Vegetables
- Fruits
- Spices
- Milk

Household supplies

- Soap
- Shampoo
- Detergent
- Cleaning Products
- Kitchen Supplies
- Gas
- Electricity
- Water
- Internet

Other family expenses

- Rent
- Medical
- Education
- Clothing
- Transportation
- Family Events
- Maintenance
- Miscellaneous

## 6.2 Shopping Records

Every shopping record must support multiple products.

Fields

- Shopping ID
- Shopping Date
- Store Name
- Product Name
- Quantity
- Unit
- Unit Price
- Total Price
- Discount
- Payment Status
- Paid Amount
- Due Amount
- Purchased By
- Notes
- Receipt Image

## 6.3 Shopping Features

- Daily Shopping Entry
- Monthly Shopping Summary
- Product-wise Expense
- Shop-wise Expense
- Family Member-wise Expense
- Shopping List
- Monthly Grocery Budget
- Previous Price Comparison
- Receipt Attachment
- Repeat Shopping Items

## 6.4 Important Rule

Shopping records must be linked to the household expense module.

Do not create duplicate expenses when a shopping bill is already registered.

---

# 7. MULTI-BUSINESS MANAGEMENT

The system must support unlimited business profiles subject to device storage.

## 7.1 Business Types

- Cattle Business
- Grocery Business
- Wholesale Business
- Retail Business
- Raw Materials Business
- Agricultural Business
- Manufacturing Business
- Service Business
- Custom Business

## 7.2 Business Profile

Fields

- Business ID
- Business Name
- Business Type
- Description
- Opening Date
- Initial Capital
- Business Location
- Contact Number
- Business Status
- Notes

## 7.3 Business Dashboard

Each business must have an independent dashboard.

Display

- Total Investment
- Total Sales
- Total Purchases
- Operating Expenses
- Gross Profit
- Net Profit
- Cash Balance
- Inventory Value
- Customer Receivables
- Supplier Payables

## 7.4 Business Financial Activities

- Capital Investment
- Sales
- Purchases
- Operating Expenses
- Salary
- Rent
- Transportation
- Utility Bills
- Owner Withdrawal
- Owner Contribution
- Profit & Loss

Every business transaction must be linked to its business ID.

Family transactions and business transactions must remain separate.

---

# 8. CATTLE MANAGEMENT MODULE

A specialized cattle accounting system.

## 8.1 Cattle Registration

Fields

- Cattle ID
- Tag Number
- Name
- Photo
- Breed
- Gender
- Age
- Weight
- Color
- Purchase Date
- Purchase Price
- Seller
- Current Status
- Notes

## 8.2 Cattle Expense Records

- Daily Feed Cost
- Medical Expenses
- Vaccination
- Veterinary Fees
- Labor Cost
- Transportation
- Other Expenses

## 8.3 Cattle Sales

- Sale Date
- Buyer
- Sale Price
- Payment Status
- Paid Amount
- Outstanding Amount

## 8.4 Individual Cattle Profit

Total Cost = Purchase Cost + Feed Cost + Medical Cost + Labor Cost + Other Allocated Costs.

Net Profit = Sale Price - Total Cost.

Unsold cattle must remain in inventoryassets and must not be treated as sold revenue.

---

# 9. INVENTORY MANAGEMENT

The inventory system must support different business types.

## 9.1 Product Fields

- Product ID
- SKU
- Barcode
- Product Name
- Category
- Unit
- Purchase Price
- Selling Price
- Current Stock
- Minimum Stock
- Storage Location
- Description
- Status

## 9.2 Inventory Operations

- Stock In
- Stock Out
- Purchase
- Sale
- Return
- Adjustment
- Damage
- Wastage
- Stock Transfer

## 9.3 Stock Calculation

Current Stock = Opening Stock + Total Stock In - Total Stock Out + Adjustments.

All stock changes must create inventory movement records.

## 9.4 Additional Features

- Low Stock Alert
- Stock History
- Product-wise Profit
- Purchase History
- Sales History
- Supplier-wise Purchase
- Inventory Valuation

Use weighted average cost for the initial inventory valuation method. Keep the costing method configurable for future versions.

---

# 10. CUSTOMER & SUPPLIER MANAGEMENT

## 10.1 Customer

- Customer ID
- Name
- Phone
- Address
- Opening Balance
- Total Sales
- Total Received
- Outstanding Due
- Notes

## 10.2 Supplier

- Supplier ID
- Name
- Phone
- Address
- Opening Balance
- Total Purchases
- Total Paid
- Outstanding Payable
- Notes

Each customer and supplier must have a transaction ledger.

Customer and supplier balances must be calculated from opening balances and subsequent transactions.

---

# 11. LOAN & DUE MANAGEMENT

Two primary sections

## 11.1 Receivable

Money owed to the user.

- Person Name
- Phone
- Principal Amount
- Transaction Date
- Due Date
- Paid Amount
- Remaining Amount
- Notes

## 11.2 Payable

Money owed by the user.

- Creditor Name
- Phone
- Principal Amount
- Borrowing Date
- Due Date
- Paid Amount
- Remaining Amount
- Interest Terms (optional)

## 11.3 Features

- Partial Payment
- Full Settlement
- Payment History
- Due Date Reminder
- Person-wise Statement
- Overdue List
- Interest Calculation (only when configured)

Loan principal is not income or expense. Interest must be recorded separately.

---

# 12. ACCOUNTS & WALLETS

Supported account types

- Cash
- Bank Account
- bKash
- Nagad
- Rocket
- Other Mobile Wallet
- Custom Account

Fields

- Account ID
- Account Name
- Account Type
- Opening Balance
- Current Balance
- Owner
- Currency
- Status

Features

- Account Transfer
- Deposit
- Withdrawal
- Account Statement
- Opening Balance Adjustment
- Account Reconciliation

Transfers between accounts must not affect total income or expenses.

---

# 13. ASSETS, SAVINGS & INVESTMENTS

## 13.1 Assets

- Land
- House
- Gold
- Vehicle
- Cattle
- Equipment
- Machinery
- Other Assets

Fields

- Asset ID
- Asset Name
- Asset Category
- Purchase Date
- Purchase Value
- Current Estimated Value
- Ownership
- Location
- Notes
- Photo

## 13.2 Savings

- Savings Goal
- Target Amount
- Current Amount
- Start Date
- Target Date
- Linked Account

## 13.3 Investment

- Investment Name
- Investment Type
- Initial Capital
- Additional Investment
- Withdrawal
- Return
- Current Estimated Value

Investment principal must not be counted as operating income.

---

# 14. BUDGET MANAGEMENT

Budget levels

- Personal Budget
- Family Budget
- Business Budget
- Category Budget
- Monthly Budget
- Yearly Budget

Features

- Set Spending Limit
- Actual Spending
- Remaining Budget
- Budget Utilization
- Warning at Configurable Threshold
- Over-budget Alert
- Historical Comparison

---

# 15. AI FEATURES

AI features must be optional and must never automatically modify financial records without user confirmation.

## 15.1 Voice Transaction Entry

Example Bengali command

আজ বাজার থেকে ২ কেজি চাল ১৪০ টাকা এবং ১ লিটার তেল ১৮০ টাকা কিনেছি।

Expected workflow

1. Start voice recording.
2. Convert speech into text.
3. Identify product names.
4. Identify quantities and units.
5. Identify prices.
6. Calculate totals.
7. Suggest transaction categories.
8. Show a review screen.
9. User confirms.
10. Save records to SQLite.

Voice recognition must support Bengali and English where supported by the device.

## 15.2 OCR Receipt Scanner

Supported input

- Camera
- Gallery Image

Extract

- Shop Name
- Receipt Date
- Product Name
- Quantity
- Unit Price
- Total Price
- Discount
- Grand Total

OCR workflow

Image → Text Recognition → Field Extraction → Validation → Review → Save.

Do not automatically trust OCR output.

## 15.3 AI Financial Reports

Generate insights such as

- Highest spending category.
- Monthly expense changes.
- Business-wise profitability.
- Unusual expense detection.
- Outstanding customer balances.
- Inventory movement analysis.
- Budget performance.

Use actual database data only.

## 15.4 Expense Prediction

Prediction should use historical transaction data.

Initial prediction features

- Monthly Expense Forecast
- Category-wise Expense Forecast
- Household Grocery Forecast
- Business Operating Cost Forecast
- Savings Projection

The first version should use local statistical forecasting methods, such as moving averages and trend analysis.

Predictions must display
- Forecast Amount
- Forecast Period
- Historical Data Range
- ConfidenceUncertainty Indicator

Do not present estimates as guaranteed financial outcomes.

## 15.5 AI Privacy

- No financial data should be uploaded automatically.
- Online AI processing requires explicit user consent.
- Local OCR and offline statistical reports should be preferred.
- Never store voice recordings unless the user explicitly enables it.
- Allow users to delete temporary images and extracted text.

---

# 16. REPORTS & ANALYTICS

## 16.1 Financial Reports

- Daily Report
- Weekly Report
- Monthly Report
- Yearly Report
- Custom Date Report
- Income Report
- Expense Report
- Profit & Loss Report
- Cash Flow Report
- Balance Sheet Summary

## 16.2 Family Reports

- Member-wise Expense
- Household Shopping Report
- Grocery Price Comparison
- Category-wise Expense
- Monthly Budget Report

## 16.3 Business Reports

- Business-wise Profit & Loss
- Sales Report
- Purchase Report
- Inventory Report
- Customer Due Report
- Supplier Payable Report
- Cattle Profit Report
- Capital Investment Report

## 16.4 Export

- PDF
- Excel
- CSV
- Print

All reports must support date filters and relevant accountbusiness filters.

---

# 17. NOTIFICATIONS & REMINDERS

- Loan Due Reminder
- Supplier Payment Reminder
- Customer Collection Reminder
- Bill Payment Reminder
- Salary Reminder
- Low Stock Alert
- Budget Alert
- Savings Reminder
- Custom Reminder

Notifications must work locally without internet.

Users must be able to configure or disable each notification type.

---

# 18. DOCUMENTS & ATTACHMENTS

Allow attachment of

- Purchase Receipts
- Sales Receipts
- Contracts
- Loan Agreements
- Cattle Photos
- Product Photos
- Supplier Documents
- Other Files

Files must be stored in application-managed local storage.

The database must store file references, not large binary files directly.

---

# 19. BACKUP & RESTORE

## 19.1 Backup Formats

- JSON Backup
- ZIP Backup with Attachments
- CSV Export
- PDF Reports

## 19.2 Backup Features

- Manual Backup
- Scheduled Local Backup
- Backup History
- Restore Backup
- Backup Validation
- Backup Version
- Export to User-selected Storage Location

Google Drive backup is not part of the initial offline-only version.

The application must provide a reliable way to export backups to a user-selected location.

Before restoring, validate the backup and ask for confirmation.

Never overwrite existing financial records silently.

---

# 20. SETTINGS & SECURITY

## 20.1 Settings

- Language Selection
- Currency Selection
- Date Format
- Number Format
- Theme
- Default Account
- Default Business
- Notification Settings
- Backup Settings

## 20.2 Security

- App PIN
- Biometric Lock
- Auto Lock
- Session Lock
- Secure Sensitive Settings
- Local Data Protection

Use secure storage for encryption keys and sensitive credentials.

Use encrypted local database storage where supported and properly implemented.

Financial records must not be exposed through debug logs.

---

# 21. UIUX REQUIREMENTS

## 21.1 Design Style

Design a premium, modern, clean financial dashboard.

Recommended design

- Primary Color Deep Navy Blue
- Secondary Color Electric Blue
- Background Light Neutral
- Dark Mode Deep Navy  Charcoal
- Income Green
- Expense Red
- Warning Amber
- Card Style Rounded Corners
- Layout Responsive Material Design 3

## 21.2 Navigation

Bottom Navigation

1. Home
2. Transactions
3. Business
4. Reports
5. More

A prominent Add Transaction action must be accessible throughout the application.

## 21.3 Main Screens

1. Splash Screen
2. Onboarding
3. Language Selection
4. App PIN Setup
5. Family Profile Setup
6. Main Dashboard
7. Transaction List
8. Add Income
9. Add Expense
10. Transfer
11. Transaction Details
12. Category Management
13. Family Management
14. Shopping List
15. Shopping Entry
16. Shopping History
17. Business List
18. Add Business
19. Business Dashboard
20. Cattle List
21. Add Cattle
22. Cattle Details
23. Cattle Expenses
24. Cattle Sale
25. Product List
26. Product Details
27. Inventory Movement
28. Purchase Entry
29. Sales Entry
30. Customer List
31. Supplier List
32. Customer Ledger
33. Supplier Ledger
34. Receivable List
35. Payable List
36. Payment Entry
37. Account List
38. Account Details
39. Account Transfer
40. Assets
41. Savings
42. Investments
43. Budget
44. Reports
45. Report Details
46. AI Assistant
47. Voice Entry
48. Receipt Scanner
49. OCR Review
50. Notifications
51. Documents
52. Backup & Restore
53. Settings
54. Family Member Permissions

Every screen must have loading, empty, success, and error states where relevant.

---

# 22. DATABASE ARCHITECTURE

Database Engine SQLite  
ORM Drift  
Primary Key UUID  
Foreign Keys Enabled  
Date Storage UTC Unix timestamp or standardized ISO-8601 UTC string  
Currency Integer minor units (for BDT, 1 Taka = 100 Poisha)  
Soft Delete Supported for important business records  
Schema Versioning Mandatory

All financial amounts must use integer minor units or another exact decimal representation. Never use floating-point arithmetic for money.

## 22.1 Core Tables

### family_members

- id TEXT PRIMARY KEY
- name TEXT NOT NULL
- phone TEXT NULL
- relationship TEXT NULL
- role TEXT NOT NULL
- photo_path TEXT NULL
- is_active INTEGER
- created_at INTEGER
- updated_at INTEGER

### businesses

- id TEXT PRIMARY KEY
- name TEXT NOT NULL
- business_type TEXT
- description TEXT
- opening_date INTEGER
- initial_capital_minor INTEGER
- location TEXT
- phone TEXT
- status TEXT
- created_at INTEGER
- updated_at INTEGER

### accounts

- id TEXT PRIMARY KEY
- name TEXT NOT NULL
- account_type TEXT
- owner_member_id TEXT NULL
- business_id TEXT NULL
- opening_balance_minor INTEGER
- currency_code TEXT DEFAULT 'BDT'
- is_active INTEGER
- created_at INTEGER
- updated_at INTEGER

### categories

- id TEXT PRIMARY KEY
- name_bn TEXT NOT NULL
- name_en TEXT NOT NULL
- category_type TEXT
- parent_id TEXT NULL
- scope TEXT
- icon TEXT
- color TEXT
- is_system INTEGER
- created_at INTEGER

### transactions

- id TEXT PRIMARY KEY
- transaction_number TEXT
- transaction_type TEXT NOT NULL
- scope_type TEXT NOT NULL
- family_member_id TEXT NULL
- business_id TEXT NULL
- category_id TEXT NULL
- account_id TEXT NULL
- amount_minor INTEGER NOT NULL
- transaction_date INTEGER
- description TEXT
- payment_status TEXT
- source_type TEXT
- source_id TEXT NULL
- created_by_member_id TEXT NULL
- created_at INTEGER
- updated_at INTEGER
- deleted_at INTEGER NULL

### transaction_entries

- id TEXT PRIMARY KEY
- transaction_id TEXT NOT NULL
- account_id TEXT NOT NULL
- debit_minor INTEGER
- credit_minor INTEGER
- created_at INTEGER

### transaction_attachments

- id TEXT PRIMARY KEY
- transaction_id TEXT NOT NULL
- file_path TEXT NOT NULL
- file_type TEXT
- created_at INTEGER

## 22.2 Household Tables

### shopping_records

- id TEXT PRIMARY KEY
- shopping_date INTEGER
- store_name TEXT
- purchased_by_member_id TEXT
- subtotal_minor INTEGER
- discount_minor INTEGER
- total_minor INTEGER
- paid_minor INTEGER
- due_minor INTEGER
- notes TEXT
- created_at INTEGER

### shopping_items

- id TEXT PRIMARY KEY
- shopping_record_id TEXT NOT NULL
- product_name TEXT NOT NULL
- quantity REAL
- unit TEXT
- unit_price_minor INTEGER
- total_minor INTEGER
- category_id TEXT NULL

### shopping_lists

- id TEXT PRIMARY KEY
- name TEXT
- created_by_member_id TEXT
- status TEXT
- created_at INTEGER

### shopping_list_items

- id TEXT PRIMARY KEY
- shopping_list_id TEXT
- item_name TEXT
- quantity REAL
- unit TEXT
- is_purchased INTEGER

## 22.3 Customer & Supplier Tables

### customers

- id TEXT PRIMARY KEY
- business_id TEXT
- name TEXT
- phone TEXT
- address TEXT
- opening_balance_minor INTEGER
- notes TEXT
- created_at INTEGER

### suppliers

- id TEXT PRIMARY KEY
- business_id TEXT
- name TEXT
- phone TEXT
- address TEXT
- opening_balance_minor INTEGER
- notes TEXT
- created_at INTEGER

### party_payments

- id TEXT PRIMARY KEY
- party_type TEXT
- party_id TEXT
- business_id TEXT
- transaction_id TEXT
- amount_minor INTEGER
- payment_date INTEGER
- payment_method TEXT
- notes TEXT

## 22.4 Inventory Tables

### products

- id TEXT PRIMARY KEY
- business_id TEXT
- sku TEXT
- barcode TEXT
- name TEXT
- category_id TEXT
- unit TEXT
- purchase_price_minor INTEGER
- selling_price_minor INTEGER
- opening_quantity REAL
- minimum_stock REAL
- is_active INTEGER
- created_at INTEGER

### inventory_movements

- id TEXT PRIMARY KEY
- product_id TEXT
- business_id TEXT
- movement_type TEXT
- quantity REAL
- unit_cost_minor INTEGER
- reference_type TEXT
- reference_id TEXT
- movement_date INTEGER
- notes TEXT

### purchase_records

- id TEXT PRIMARY KEY
- business_id TEXT
- supplier_id TEXT
- purchase_date INTEGER
- subtotal_minor INTEGER
- discount_minor INTEGER
- total_minor INTEGER
- paid_minor INTEGER
- due_minor INTEGER

### purchase_items

- id TEXT PRIMARY KEY
- purchase_id TEXT
- product_id TEXT
- quantity REAL
- unit_cost_minor INTEGER
- total_minor INTEGER

### sales_records

- id TEXT PRIMARY KEY
- business_id TEXT
- customer_id TEXT NULL
- sale_date INTEGER
- subtotal_minor INTEGER
- discount_minor INTEGER
- total_minor INTEGER
- paid_minor INTEGER
- due_minor INTEGER

### sales_items

- id TEXT PRIMARY KEY
- sale_id TEXT
- product_id TEXT
- quantity REAL
- unit_price_minor INTEGER
- unit_cost_minor INTEGER
- total_minor INTEGER

## 22.5 Cattle Tables

### cattle

- id TEXT PRIMARY KEY
- business_id TEXT
- tag_number TEXT
- name TEXT
- breed TEXT
- gender TEXT
- birth_date INTEGER NULL
- estimated_age TEXT
- weight_kg REAL
- purchase_date INTEGER
- purchase_price_minor INTEGER
- seller_id TEXT NULL
- status TEXT
- photo_path TEXT
- created_at INTEGER

### cattle_expenses

- id TEXT PRIMARY KEY
- cattle_id TEXT
- expense_type TEXT
- amount_minor INTEGER
- expense_date INTEGER
- description TEXT
- transaction_id TEXT NULL

### cattle_sales

- id TEXT PRIMARY KEY
- cattle_id TEXT
- buyer_name TEXT
- sale_date INTEGER
- sale_price_minor INTEGER
- paid_minor INTEGER
- due_minor INTEGER
- notes TEXT

## 22.6 Loan & Due Tables

### loan_accounts

- id TEXT PRIMARY KEY
- party_name TEXT
- phone TEXT
- loan_type TEXT
- business_id TEXT NULL
- principal_minor INTEGER
- interest_type TEXT
- interest_rate REAL
- start_date INTEGER
- due_date INTEGER
- status TEXT
- notes TEXT

### loan_payments

- id TEXT PRIMARY KEY
- loan_id TEXT
- transaction_id TEXT
- principal_paid_minor INTEGER
- interest_paid_minor INTEGER
- payment_date INTEGER
- notes TEXT

## 22.7 Assets & Savings Tables

### assets

- id TEXT PRIMARY KEY
- name TEXT
- category TEXT
- owner_member_id TEXT
- business_id TEXT NULL
- purchase_date INTEGER
- purchase_value_minor INTEGER
- current_value_minor INTEGER
- notes TEXT
- photo_path TEXT

### savings_goals

- id TEXT PRIMARY KEY
- name TEXT
- target_amount_minor INTEGER
- current_amount_minor INTEGER
- start_date INTEGER
- target_date INTEGER
- linked_account_id TEXT NULL
- status TEXT

### investments

- id TEXT PRIMARY KEY
- name TEXT
- investment_type TEXT
- initial_amount_minor INTEGER
- current_value_minor INTEGER
- investment_date INTEGER
- business_id TEXT NULL
- notes TEXT

## 22.8 Budget & Reminder Tables

### budgets

- id TEXT PRIMARY KEY
- name TEXT
- scope_type TEXT
- business_id TEXT NULL
- category_id TEXT NULL
- period_type TEXT
- start_date INTEGER
- end_date INTEGER
- limit_minor INTEGER
- alert_percentage INTEGER
- status TEXT

### reminders

- id TEXT PRIMARY KEY
- title TEXT
- description TEXT
- reminder_type TEXT
- reference_id TEXT NULL
- scheduled_at INTEGER
- repeat_rule TEXT NULL
- is_completed INTEGER
- notification_enabled INTEGER

## 22.9 AI & Application Tables

### ai_extractions

- id TEXT PRIMARY KEY
- extraction_type TEXT
- source_file_path TEXT NULL
- extracted_text TEXT
- extracted_data_json TEXT
- status TEXT
- created_at INTEGER

### app_settings

- id TEXT PRIMARY KEY
- setting_key TEXT UNIQUE
- setting_value TEXT
- updated_at INTEGER

### audit_logs

- id TEXT PRIMARY KEY
- member_id TEXT NULL
- action TEXT
- entity_type TEXT
- entity_id TEXT
- timestamp INTEGER
- details_json TEXT

### attachments

- id TEXT PRIMARY KEY
- file_name TEXT
- file_path TEXT
- mime_type TEXT
- file_size INTEGER
- created_at INTEGER

Note All foreign keys must be properly implemented in the actual database. Add indexes for transaction dates, business IDs, account IDs, product IDs, and party IDs. Add database migrations whenever the schema changes.

---

# 23. FINANCIAL CALCULATION RULES

The financial engine must be centralized.

## 23.1 Account Balance

Account Balance = Opening Balance + Total Credits - Total Debits.

Use the appropriate debitcredit direction for each account type.

## 23.2 Net Cash Flow

Net Cash Flow = Cash Inflows - Cash Outflows.

Exclude internal transfers from consolidated income and expense totals.

## 23.3 Net Profit

Net Profit = Revenue - Cost of Goods Sold - Operating Expenses.

## 23.4 Receivable

Outstanding Receivable = Opening Receivable + New Credit Sales + Loans Given - Collections - Adjustments.

## 23.5 Payable

Outstanding Payable = Opening Payable + New Credit Purchases + Loans Received - Payments - Adjustments.

## 23.6 Inventory

Stock Quantity = Opening Stock + Stock In - Stock Out + Adjustments.

## 23.7 Double-Entry Accounting

All financial events should be represented by balanced journal entries.

For every posted journal transaction

Total Debit = Total Credit.

Each posted transaction must be saved atomically in a database transaction.

Do not directly change account balances as an independent operation.

Calculate balances from journal entries or maintain validated cached balances that can be rebuilt.

Use reversal entries for posted financial corrections instead of silently changing historical financial records.

---

# 24. FLUTTER TECHNICAL ARCHITECTURE

Use a modular feature-based architecture.

## 24.1 Architecture Layers

Presentation Layer
- Screens
- Widgets
- GetX Controllers
- Bindings

Domain Layer
- Entities
- Repository Interfaces
- Use Cases
- Business Rules

Data Layer
- Drift Tables
- DAO
- Models
- Repository Implementations
- Local Data Sources

Core Layer
- Routes
- Theme
- Localization
- Database
- Error Handling
- Security
- Utilities
- Constants

## 24.2 Suggested Project Folder Structure

lib
  main.dart

  app
    app.dart
    routes
      app_pages.dart
      app_routes.dart
    bindings
      initial_binding.dart

  core
    constants
    theme
    localization
    database
      app_database.dart
      tables
      daos
      migrations
    security
    utils
    errors
    services
    widgets

  features

    dashboard
      data
      domain
      presentation

    authentication
      data
      domain
      presentation

    family
      data
      domain
      presentation

    personal_finance
      data
      domain
      presentation

    household
      data
      domain
      presentation

    transactions
      data
      domain
      presentation

    business
      data
      domain
      presentation

    cattle
      data
      domain
      presentation

    inventory
      data
      domain
      presentation

    customers
      data
      domain
      presentation

    suppliers
      data
      domain
      presentation

    loans
      data
      domain
      presentation

    accounts
      data
      domain
      presentation

    assets
      data
      domain
      presentation

    budgets
      data
      domain
      presentation

    reports
      data
      domain
      presentation

    ai_assistant
      data
      domain
      presentation

    reminders
      data
      domain
      presentation

    documents
      data
      domain
      presentation

    backup
      data
      domain
      presentation

    settings
      data
      domain
      presentation

  shared
    models
    widgets
    enums
    helpers

## 24.3 GetX Rules

- Use Bindings for dependency injection.
- Use Controllers for UI state.
- Use Services for reusable application services.
- Use Obx only for reactive UI sections.
- Do not put database queries directly inside widgets.
- Do not put financial calculations inside UI components.
- Keep controllers lightweight.
- Use repository and use-case layers for business logic.
- Avoid unnecessary global controllers.

## 24.4 Repository Pattern

Example

TransactionController
    ↓
CreateTransactionUseCase
    ↓
TransactionRepository
    ↓
TransactionRepositoryImpl
    ↓
TransactionDao
    ↓
SQLite  Drift

The UI must never directly access SQLite.

---

# 25. RECOMMENDED FLUTTER PACKAGES

Use compatible stable package versions at implementation time.

Core
- get
- drift
- sqlite3_flutter_libs
- path_provider
- path
- uuid

UI
- flutter_svg
- google_fonts
- fl_chart
- intl
- responsive_framework

Storage
- shared_preferences
- flutter_secure_storage
- file_picker
- image_picker

Documents
- pdf
- printing
- excel
- csv
- archive

AI  Input
- speech_to_text
- google_mlkit_text_recognition

Notifications
- flutter_local_notifications

Security
- local_auth
- cryptography
- sqlcipher-compatible solution where properly supported

Development
- build_runner
- drift_dev
- flutter_lints

Package compatibility, Android permissions, SDK requirements, and licensing must be checked before installation.

---

# 26. PERFORMANCE & RELIABILITY REQUIREMENTS

- Application must work without internet.
- Database queries must use indexes where appropriate.
- Large lists must support pagination.
- Use database transactions for multi-table financial operations.
- Prevent duplicate transaction submission.
- Handle application crashes safely.
- Validate all monetary inputs.
- Validate quantities and units.
- Support Bengali Unicode.
- Use responsive layouts for different Android screen sizes.
- Do not load all historical transactions into memory.
- Maintain database migration compatibility.
- Do not block the UI thread with large file or image operations.
- Provide clear error messages.

---

# 27. TESTING REQUIREMENTS

Unit Tests
- Income calculation
- Expense calculation
- Account transfer
- Profit calculation
- Loan balance
- Customer balance
- Supplier balance
- Inventory calculation
- Cattle profit
- Budget calculation

Database Tests
- Insert
- Update
- Delete
- Foreign key validation
- Database migration
- Backup
- Restore

Integration Tests
- Complete transaction flow
- Household shopping flow
- Business purchase flow
- Business sales flow
- Loan repayment flow
- Cattle purchase and sale
- OCR review and confirmation
- Voice transaction review

UI Tests
- Onboarding
- Dashboard
- Navigation
- Language switching
- Transaction entry
- Reports
- Settings

Financial calculation tests must use known expected results and must cover rounding, partial payments, returns, corrections, and transfers.

---

# 28. DEVELOPMENT PHASES

## PHASE 1 — FOUNDATION

- Flutter project setup
- Theme and localization
- GetX architecture
- Drift database
- Family profiles
- Accounts
- Categories
- Income and expense
- Transactions
- Dashboard
- Basic reports
- Local PIN

Deliverable A working offline personal and family accounting application.

## PHASE 2 — FAMILY MANAGEMENT

- Household shopping
- Shopping lists
- Family member permissions
- Budget
- Receivables
- Payables
- Savings
- Assets
- PDF and Excel reports

Deliverable Complete family finance management.

## PHASE 3 — BUSINESS MANAGEMENT

- Multiple businesses
- Business dashboards
- Customers
- Suppliers
- Purchase
- Sales
- Inventory
- Business profit and loss
- Business expenses

Deliverable Complete multi-business accounting.

## PHASE 4 — SPECIALIZED BUSINESS

- Cattle registration
- Cattle expenses
- Cattle sales
- Individual cattle profitability
- Stock and weight records

Deliverable Specialized cattle business management.

## PHASE 5 — AI & ADVANCED FEATURES

- Voice transaction entry
- Receipt OCR
- AI report insights
- Local expense forecasting
- Advanced analytics
- Smart notifications

Deliverable AI-assisted financial management.

## PHASE 6 — SECURITY & RELEASE

- Backup and restore
- Data encryption
- Performance optimization
- Complete testing
- Bug fixing
- Release signing
- Android APK  AAB generation

Deliverable Production-ready Android application.

---

# 29. IMPORTANT DEVELOPMENT RULES FOR AI CODE EDITORS

1. Read this entire specification before starting development.
2. Do not attempt to implement every module in one uncontrolled code-generation step.
3. First create the architecture, database, theme, routes, and localization.
4. Then implement modules phase by phase.
5. Complete and test each module before starting the next.
6. Keep the UI separate from business logic.
7. Use GetX consistently.
8. Use Drift for persistent relational data.
9. Never use mock data in production.
10. Demo data must be optional and clearly identified.
11. Never hardcode financial calculations in screens.
12. Do not count transfers as income or expenses.
13. Never double-count payments, shopping bills, or loan settlements.
14. Every business must have isolated records.
15. All money calculations must be precise.
16. Use database migrations for schema changes.
17. Preserve existing functionality when adding new features.
18. Do not redesign completed screens without approval.
19. Implement Bengali and English translations for every user-facing string.
20. Provide a working application after each development phase.
21. Run `flutter analyze` and relevant tests after each major module.
22. Maintain a README containing setup, architecture, package, and build instructions.
23. Maintain a CHANGELOG for important development changes.
24. Record known limitations and incomplete features honestly.
25. Never claim a feature is complete unless its implementation and tests support that claim.

---

# 30. FINAL ACCEPTANCE CRITERIA

The project will be considered complete when

- The application runs successfully on Android.
- All main modules work offline.
- Multiple family profiles can be created.
- Personal and family transactions are correctly separated.
- Multiple businesses can be created and managed.
- Cattle purchase, expense, and sale calculations work.
- Inventory quantities remain accurate.
- Customer and supplier balances are correct.
- Receivable and payable records work.
- Account transfers do not distort financial reports.
- Monthly and yearly reports are correct.
- Bengali and English switching works.
- Voice entry supports the available device recognition capabilities.
- OCR extraction includes a manual review step.
- Financial insights use actual stored records.
- Expense forecasts disclose uncertainty.
- Backup and restore work correctly.
- Sensitive information is protected.
- Database migrations and automated tests pass.
- No known critical financial calculation bug remains.

---

# END OF PROJECT SPECIFICATION

Project My Life & Business Manager  
Version 1.0.0  
Target Flutter Android  
Database Local SQLite  Drift  
Architecture Modular GetX  Feature-Based  Offline-First

This document is the baseline development specification. Any future modification should be documented with a version number and corresponding database migration requirements.