# MLB Manager — Database Schema & Architecture Specification

## Database Engine
- **Engine**: SQLite via Drift ORM (`sqlite3_flutter_libs`)
- **Primary Keys**: UUID (v4) stored as TEXT
- **Date Storage**: UTC Unix Timestamp (Milliseconds or Seconds as INTEGER)
- **Currency Storage**: Exact Integer Minor Units (1 BDT = 100 Poisha). Zero floating-point numbers for currency!
- **Foreign Keys**: Enabled (`PRAGMA foreign_keys = ON;`)
- **Indexes**: On foreign keys, transaction dates, business IDs, categories, accounts, and party IDs.

---

## Complete Table Definitions

### 1. Core Tables
1. **family_members**
   - `id`: TEXT PRIMARY KEY
   - `name`: TEXT NOT NULL
   - `phone`: TEXT NULL
   - `relationship`: TEXT NULL
   - `role`: TEXT NOT NULL ('owner', 'admin', 'member', 'viewer')
   - `photo_path`: TEXT NULL
   - `is_active`: INTEGER NOT NULL DEFAULT 1
   - `created_at`: INTEGER NOT NULL
   - `updated_at`: INTEGER NOT NULL

2. **businesses**
   - `id`: TEXT PRIMARY KEY
   - `name`: TEXT NOT NULL
   - `business_type`: TEXT NOT NULL
   - `description`: TEXT NULL
   - `opening_date`: INTEGER NOT NULL
   - `initial_capital_minor`: INTEGER NOT NULL DEFAULT 0
   - `location`: TEXT NULL
   - `phone`: TEXT NULL
   - `status`: TEXT NOT NULL DEFAULT 'active'
   - `created_at`: INTEGER NOT NULL
   - `updated_at`: INTEGER NOT NULL

3. **accounts**
   - `id`: TEXT PRIMARY KEY
   - `name`: TEXT NOT NULL
   - `account_type`: TEXT NOT NULL ('cash', 'bank', 'bkash', 'nagad', 'rocket', 'other_wallet', 'custom')
   - `owner_member_id`: TEXT NULL REFERENCES family_members(id)
   - `business_id`: TEXT NULL REFERENCES businesses(id)
   - `opening_balance_minor`: INTEGER NOT NULL DEFAULT 0
   - `currency_code`: TEXT NOT NULL DEFAULT 'BDT'
   - `is_active`: INTEGER NOT NULL DEFAULT 1
   - `created_at`: INTEGER NOT NULL
   - `updated_at`: INTEGER NOT NULL

4. **categories**
   - `id`: TEXT PRIMARY KEY
   - `name_bn`: TEXT NOT NULL
   - `name_en`: TEXT NOT NULL
   - `category_type`: TEXT NOT NULL ('income', 'expense')
   - `parent_id`: TEXT NULL REFERENCES categories(id)
   - `scope`: TEXT NOT NULL ('personal', 'family', 'business', 'both')
   - `icon`: TEXT NULL
   - `color`: TEXT NULL
   - `is_system`: INTEGER NOT NULL DEFAULT 0
   - `created_at`: INTEGER NOT NULL

5. **transactions**
   - `id`: TEXT PRIMARY KEY
   - `transaction_number`: TEXT NOT NULL
   - `transaction_type`: TEXT NOT NULL ('income', 'expense', 'transfer')
   - `scope_type`: TEXT NOT NULL ('personal', 'family', 'business')
   - `family_member_id`: TEXT NULL REFERENCES family_members(id)
   - `business_id`: TEXT NULL REFERENCES businesses(id)
   - `category_id`: TEXT NULL REFERENCES categories(id)
   - `account_id`: TEXT NULL REFERENCES accounts(id)
   - `amount_minor`: INTEGER NOT NULL
   - `transaction_date`: INTEGER NOT NULL
   - `description`: TEXT NULL
   - `payment_status`: TEXT NOT NULL DEFAULT 'paid' ('paid', 'due', 'partial')
   - `source_type`: TEXT NULL ('manual', 'voice', 'ocr', 'shopping', 'cattle', 'sale', 'purchase')
   - `source_id`: TEXT NULL
   - `created_by_member_id`: TEXT NULL REFERENCES family_members(id)
   - `created_at`: INTEGER NOT NULL
   - `updated_at`: INTEGER NOT NULL
   - `deleted_at`: INTEGER NULL

6. **transaction_entries** (Double-entry journal entries)
   - `id`: TEXT PRIMARY KEY
   - `transaction_id`: TEXT NOT NULL REFERENCES transactions(id) ON DELETE CASCADE
   - `account_id`: TEXT NOT NULL REFERENCES accounts(id)
   - `debit_minor`: INTEGER NOT NULL DEFAULT 0
   - `credit_minor`: INTEGER NOT NULL DEFAULT 0
   - `created_at`: INTEGER NOT NULL

7. **transaction_attachments**
   - `id`: TEXT PRIMARY KEY
   - `transaction_id`: TEXT NOT NULL REFERENCES transactions(id) ON DELETE CASCADE
   - `file_path`: TEXT NOT NULL
   - `file_type`: TEXT NULL
   - `created_at`: INTEGER NOT NULL

---

### 2. Household Tables
8. **shopping_records**
   - `id`: TEXT PRIMARY KEY
   - `shopping_date`: INTEGER NOT NULL
   - `store_name`: TEXT NULL
   - `purchased_by_member_id`: TEXT NULL REFERENCES family_members(id)
   - `subtotal_minor`: INTEGER NOT NULL DEFAULT 0
   - `discount_minor`: INTEGER NOT NULL DEFAULT 0
   - `total_minor`: INTEGER NOT NULL DEFAULT 0
   - `paid_minor`: INTEGER NOT NULL DEFAULT 0
   - `due_minor`: INTEGER NOT NULL DEFAULT 0
   - `notes`: TEXT NULL
   - `created_at`: INTEGER NOT NULL

9. **shopping_items**
   - `id`: TEXT PRIMARY KEY
   - `shopping_record_id`: TEXT NOT NULL REFERENCES shopping_records(id) ON DELETE CASCADE
   - `product_name`: TEXT NOT NULL
   - `quantity`: REAL NOT NULL
   - `unit`: TEXT NOT NULL
   - `unit_price_minor`: INTEGER NOT NULL
   - `total_minor`: INTEGER NOT NULL
   - `category_id`: TEXT NULL REFERENCES categories(id)

10. **shopping_lists**
    - `id`: TEXT PRIMARY KEY
    - `name`: TEXT NOT NULL
    - `created_by_member_id`: TEXT NULL REFERENCES family_members(id)
    - `status`: TEXT NOT NULL DEFAULT 'active'
    - `created_at`: INTEGER NOT NULL

11. **shopping_list_items**
    - `id`: TEXT PRIMARY KEY
    - `shopping_list_id`: TEXT NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE
    - `item_name`: TEXT NOT NULL
    - `quantity`: REAL NOT NULL DEFAULT 1.0
    - `unit`: TEXT NOT NULL
    - `is_purchased`: INTEGER NOT NULL DEFAULT 0

---

### 3. Customer & Supplier Tables
12. **customers**
    - `id`: TEXT PRIMARY KEY
    - `business_id`: TEXT NOT NULL REFERENCES businesses(id)
    - `name`: TEXT NOT NULL
    - `phone`: TEXT NULL
    - `address`: TEXT NULL
    - `opening_balance_minor`: INTEGER NOT NULL DEFAULT 0
    - `notes`: TEXT NULL
    - `created_at`: INTEGER NOT NULL

13. **suppliers**
    - `id`: TEXT PRIMARY KEY
    - `business_id`: TEXT NOT NULL REFERENCES businesses(id)
    - `name`: TEXT NOT NULL
    - `phone`: TEXT NULL
    - `address`: TEXT NULL
    - `opening_balance_minor`: INTEGER NOT NULL DEFAULT 0
    - `notes`: TEXT NULL
    - `created_at`: INTEGER NOT NULL

14. **party_payments**
    - `id`: TEXT PRIMARY KEY
    - `party_type`: TEXT NOT NULL ('customer', 'supplier')
    - `party_id`: TEXT NOT NULL
    - `business_id`: TEXT NOT NULL REFERENCES businesses(id)
    - `transaction_id`: TEXT NULL REFERENCES transactions(id)
    - `amount_minor`: INTEGER NOT NULL
    - `payment_date`: INTEGER NOT NULL
    - `payment_method`: TEXT NULL
    - `notes`: TEXT NULL

---

### 4. Inventory Tables
15. **products**
    - `id`: TEXT PRIMARY KEY
    - `business_id`: TEXT NOT NULL REFERENCES businesses(id)
    - `sku`: TEXT NULL
    - `barcode`: TEXT NULL
    - `name`: TEXT NOT NULL
    - `category_id`: TEXT NULL REFERENCES categories(id)
    - `unit`: TEXT NOT NULL
    - `purchase_price_minor`: INTEGER NOT NULL DEFAULT 0
    - `selling_price_minor`: INTEGER NOT NULL DEFAULT 0
    - `opening_quantity`: REAL NOT NULL DEFAULT 0.0
    - `minimum_stock`: REAL NOT NULL DEFAULT 0.0
    - `is_active`: INTEGER NOT NULL DEFAULT 1
    - `created_at`: INTEGER NOT NULL

16. **inventory_movements**
    - `id`: TEXT PRIMARY KEY
    - `product_id`: TEXT NOT NULL REFERENCES products(id)
    - `business_id`: TEXT NOT NULL REFERENCES businesses(id)
    - `movement_type`: TEXT NOT NULL ('in', 'out', 'purchase', 'sale', 'return', 'adjustment', 'damage', 'wastage', 'transfer')
    - `quantity`: REAL NOT NULL
    - `unit_cost_minor`: INTEGER NOT NULL DEFAULT 0
    - `reference_type`: TEXT NULL
    - `reference_id`: TEXT NULL
    - `movement_date`: INTEGER NOT NULL
    - `notes`: TEXT NULL

17. **purchase_records**
    - `id`: TEXT PRIMARY KEY
    - `business_id`: TEXT NOT NULL REFERENCES businesses(id)
    - `supplier_id`: TEXT NULL REFERENCES suppliers(id)
    - `purchase_date`: INTEGER NOT NULL
    - `subtotal_minor`: INTEGER NOT NULL DEFAULT 0
    - `discount_minor`: INTEGER NOT NULL DEFAULT 0
    - `total_minor`: INTEGER NOT NULL DEFAULT 0
    - `paid_minor`: INTEGER NOT NULL DEFAULT 0
    - `due_minor`: INTEGER NOT NULL DEFAULT 0

18. **purchase_items**
    - `id`: TEXT PRIMARY KEY
    - `purchase_id`: TEXT NOT NULL REFERENCES purchase_records(id) ON DELETE CASCADE
    - `product_id`: TEXT NOT NULL REFERENCES products(id)
    - `quantity`: REAL NOT NULL
    - `unit_cost_minor`: INTEGER NOT NULL
    - `total_minor`: INTEGER NOT NULL

19. **sales_records**
    - `id`: TEXT PRIMARY KEY
    - `business_id`: TEXT NOT NULL REFERENCES businesses(id)
    - `customer_id`: TEXT NULL REFERENCES customers(id)
    - `sale_date`: INTEGER NOT NULL
    - `subtotal_minor`: INTEGER NOT NULL DEFAULT 0
    - `discount_minor`: INTEGER NOT NULL DEFAULT 0
    - `total_minor`: INTEGER NOT NULL DEFAULT 0
    - `paid_minor`: INTEGER NOT NULL DEFAULT 0
    - `due_minor`: INTEGER NOT NULL DEFAULT 0

20. **sales_items**
    - `id`: TEXT PRIMARY KEY
    - `sale_id`: TEXT NOT NULL REFERENCES sales_records(id) ON DELETE CASCADE
    - `product_id`: TEXT NOT NULL REFERENCES products(id)
    - `quantity`: REAL NOT NULL
    - `unit_price_minor`: INTEGER NOT NULL
    - `unit_cost_minor`: INTEGER NOT NULL
    - `total_minor`: INTEGER NOT NULL

---

### 5. Cattle Tables
21. **cattle**
    - `id`: TEXT PRIMARY KEY
    - `business_id`: TEXT NOT NULL REFERENCES businesses(id)
    - `tag_number`: TEXT NOT NULL
    - `name`: TEXT NULL
    - `breed`: TEXT NULL
    - `gender`: TEXT NULL ('bull', 'cow', 'steer', 'heifer', 'calf')
    - `birth_date`: INTEGER NULL
    - `estimated_age`: TEXT NULL
    - `weight_kg`: REAL NULL
    - `purchase_date`: INTEGER NOT NULL
    - `purchase_price_minor`: INTEGER NOT NULL
    - `seller_id`: TEXT NULL
    - `status`: TEXT NOT NULL DEFAULT 'active' ('active', 'sold', 'deceased', 'quarantined')
    - `photo_path`: TEXT NULL
    - `created_at`: INTEGER NOT NULL

22. **cattle_expenses**
    - `id`: TEXT PRIMARY KEY
    - `cattle_id`: TEXT NOT NULL REFERENCES cattle(id) ON DELETE CASCADE
    - `expense_type`: TEXT NOT NULL ('feed', 'medical', 'vaccination', 'vet', 'labor', 'transport', 'other')
    - `amount_minor`: INTEGER NOT NULL
    - `expense_date`: INTEGER NOT NULL
    - `description`: TEXT NULL
    - `transaction_id`: TEXT NULL REFERENCES transactions(id)

23. **cattle_sales**
    - `id`: TEXT PRIMARY KEY
    - `cattle_id`: TEXT NOT NULL REFERENCES cattle(id)
    - `buyer_name`: TEXT NOT NULL
    - `sale_date`: INTEGER NOT NULL
    - `sale_price_minor`: INTEGER NOT NULL
    - `paid_minor`: INTEGER NOT NULL
    - `due_minor`: INTEGER NOT NULL
    - `notes`: TEXT NULL

---

### 6. Loan & Due Tables
24. **loan_accounts**
    - `id`: TEXT PRIMARY KEY
    - `party_name`: TEXT NOT NULL
    - `phone`: TEXT NULL
    - `loan_type`: TEXT NOT NULL ('receivable', 'payable')
    - `business_id`: TEXT NULL REFERENCES businesses(id)
    - `principal_minor`: INTEGER NOT NULL
    - `interest_type`: TEXT NULL ('none', 'flat', 'reducing')
    - `interest_rate`: REAL NOT NULL DEFAULT 0.0
    - `start_date`: INTEGER NOT NULL
    - `due_date`: INTEGER NOT NULL
    - `status`: TEXT NOT NULL DEFAULT 'active' ('active', 'settled', 'overdue')
    - `notes`: TEXT NULL

25. **loan_payments**
    - `id`: TEXT PRIMARY KEY
    - `loan_id`: TEXT NOT NULL REFERENCES loan_accounts(id) ON DELETE CASCADE
    - `transaction_id`: TEXT NULL REFERENCES transactions(id)
    - `principal_paid_minor`: INTEGER NOT NULL
    - `interest_paid_minor`: INTEGER NOT NULL DEFAULT 0
    - `payment_date`: INTEGER NOT NULL
    - `notes`: TEXT NULL

---

### 7. Assets & Savings Tables
26. **assets**
    - `id`: TEXT PRIMARY KEY
    - `name`: TEXT NOT NULL
    - `category`: TEXT NOT NULL ('land', 'house', 'gold', 'vehicle', 'cattle', 'equipment', 'machinery', 'other')
    - `owner_member_id`: TEXT NOT NULL REFERENCES family_members(id)
    - `business_id`: TEXT NULL REFERENCES businesses(id)
    - `purchase_date`: INTEGER NOT NULL
    - `purchase_value_minor`: INTEGER NOT NULL
    - `current_value_minor`: INTEGER NOT NULL
    - `notes`: TEXT NULL
    - `photo_path`: TEXT NULL

27. **savings_goals**
    - `id`: TEXT PRIMARY KEY
    - `name`: TEXT NOT NULL
    - `target_amount_minor`: INTEGER NOT NULL
    - `current_amount_minor`: INTEGER NOT NULL DEFAULT 0
    - `start_date`: INTEGER NOT NULL
    - `target_date`: INTEGER NOT NULL
    - `linked_account_id`: TEXT NULL REFERENCES accounts(id)
    - `status`: TEXT NOT NULL DEFAULT 'in_progress'

28. **investments**
    - `id`: TEXT PRIMARY KEY
    - `name`: TEXT NOT NULL
    - `investment_type`: TEXT NOT NULL
    - `initial_amount_minor`: INTEGER NOT NULL
    - `current_value_minor`: INTEGER NOT NULL
    - `investment_date`: INTEGER NOT NULL
    - `business_id`: TEXT NULL REFERENCES businesses(id)
    - `notes`: TEXT NULL

---

### 8. Budget & Reminder Tables
29. **budgets**
    - `id`: TEXT PRIMARY KEY
    - `name`: TEXT NOT NULL
    - `scope_type`: TEXT NOT NULL ('personal', 'family', 'business')
    - `business_id`: TEXT NULL REFERENCES businesses(id)
    - `category_id`: TEXT NULL REFERENCES categories(id)
    - `period_type`: TEXT NOT NULL ('monthly', 'yearly')
    - `start_date`: INTEGER NOT NULL
    - `end_date`: INTEGER NOT NULL
    - `limit_minor`: INTEGER NOT NULL
    - `alert_percentage`: INTEGER NOT NULL DEFAULT 80
    - `status`: TEXT NOT NULL DEFAULT 'active'

30. **reminders**
    - `id`: TEXT PRIMARY KEY
    - `title`: TEXT NOT NULL
    - `description`: TEXT NULL
    - `reminder_type`: TEXT NOT NULL ('loan_due', 'supplier_payable', 'customer_collection', 'bill_payment', 'salary', 'low_stock', 'budget_alert', 'savings', 'custom')
    - `reference_id`: TEXT NULL
    - `scheduled_at`: INTEGER NOT NULL
    - `repeat_rule`: TEXT NULL
    - `is_completed`: INTEGER NOT NULL DEFAULT 0
    - `notification_enabled`: INTEGER NOT NULL DEFAULT 1

---

### 9. AI & Application Tables
31. **ai_extractions**
    - `id`: TEXT PRIMARY KEY
    - `extraction_type`: TEXT NOT NULL ('voice', 'ocr')
    - `source_file_path`: TEXT NULL
    - `extracted_text`: TEXT NOT NULL
    - `extracted_data_json`: TEXT NOT NULL
    - `status`: TEXT NOT NULL DEFAULT 'pending' ('pending', 'confirmed', 'discarded')
    - `created_at`: INTEGER NOT NULL

32. **app_settings**
    - `id`: TEXT PRIMARY KEY
    - `setting_key`: TEXT NOT NULL UNIQUE
    - `setting_value`: TEXT NOT NULL
    - `updated_at`: INTEGER NOT NULL

33. **audit_logs**
    - `id`: TEXT PRIMARY KEY
    - `member_id`: TEXT NULL REFERENCES family_members(id)
    - `action`: TEXT NOT NULL
    - `entity_type`: TEXT NOT NULL
    - `entity_id`: TEXT NOT NULL
    - `timestamp`: INTEGER NOT NULL
    - `details_json`: TEXT NULL

34. **attachments**
    - `id`: TEXT PRIMARY KEY
    - `file_name`: TEXT NOT NULL
    - `file_path`: TEXT NOT NULL
    - `mime_type`: TEXT NULL
    - `file_size`: INTEGER NOT NULL DEFAULT 0
    - `created_at`: INTEGER NOT NULL
