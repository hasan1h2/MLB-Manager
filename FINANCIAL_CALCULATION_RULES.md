# MLB Manager — Financial Calculation Rules Engine

## Core Mathematical Principles
1. **Integer Minor Units (Poisha)**:
   - $1\ \text{BDT} = 100\ \text{Poisha}$.
   - All balances, debits, credits, invoices, payments, and valuations are computed as 64-bit integer values (`int`).
   - Floating-point representations (`double`) are strictly prohibited for monetary amounts to prevent cumulative floating-point rounding errors.
   - For display, `amount_minor` is formatted with decimal point: `(amountMinor / 100).toStringAsFixed(2)`.

2. **Double-Entry Journal Balancing**:
   - For every posted financial transaction:
     $$\sum \text{Debit Minor} = \sum \text{Credit Minor}$$
   - When a transaction is saved, atomic execution within an SQLite transaction ensures either all journal entries commit or none do.

---

## 1. Account Balance Formula
$$\text{Account Balance} = \text{Opening Balance} + \sum \text{Credits} - \sum \text{Debits}$$
Depending on account classification (Asset / Liability / Equity / Revenue / Expense):
- **Asset / Bank / Cash / Mobile Wallets**:
  - Increased by Debits (Cash coming in)
  - Decreased by Credits (Cash going out)
  - Balance = Opening Balance + Inflows - Outflows
- **Liability / Loans Payable**:
  - Increased by Credits (Borrowing)
  - Decreased by Debits (Repayment)

---

## 2. Net Cash Flow
$$\text{Net Cash Flow} = \text{Total Cash Inflows} - \text{Total Cash Outflows}$$
*Crucial Constraint*: Internal transfers between accounts (e.g., Cash to Bank, Bank to bKash) must **never** be counted as consolidated Income or Expense. They only modify individual account balances while net cash flow across the consolidated ecosystem remains unchanged.

---

## 3. Net Profit & Loss
$$\text{Gross Profit} = \text{Revenue} - \text{Cost of Goods Sold (COGS)}$$
$$\text{Net Profit} = \text{Gross Profit} - \text{Operating Expenses}$$
- **Revenue**: Total sales of goods and services during the period.
- **COGS**: Total cost of inventory items sold or direct production costs.
- **Operating Expenses**: Salaries, rent, utilities, transport, depreciation, and other business overheads.
- **Owner Equity Withdrawals / Contributions**: Capital transfers between owner and business do not affect Net Profit.

---

## 4. Customer Receivables & Supplier Payables
### Customer Outstanding Due:
$$\text{Customer Due} = \text{Opening Balance} + \text{Total Credit Sales} - \text{Total Collections} - \text{Returns / Adjustments}$$

### Supplier Outstanding Payable:
$$\text{Supplier Payable} = \text{Opening Balance} + \text{Total Credit Purchases} - \text{Total Payments Made} - \text{Returns / Adjustments}$$

---

## 5. Inventory Valuation & Weighted Average Costing
$$\text{Current Stock Quantity} = \text{Opening Stock} + \text{Total Stock In} - \text{Total Stock Out} + \text{Adjustments}$$

### Weighted Average Cost (WAC):
When a new purchase arrives:
$$\text{New WAC} = \frac{(\text{Existing Quantity} \times \text{Old WAC}) + (\text{New Quantity} \times \text{New Unit Cost})}{\text{Existing Quantity} + \text{New Quantity}}$$
When selling an item, the Cost of Goods Sold is recorded at the current WAC.

---

## 6. Cattle Profitability Engine
For each cattle record:
$$\text{Total Cost} = \text{Purchase Price} + \sum \text{Feed Costs} + \sum \text{Medical Costs} + \sum \text{Vaccine/Vet Costs} + \sum \text{Labor Costs} + \sum \text{Allocated Other Costs}$$
$$\text{Net Cattle Profit} = \text{Sale Price} - \text{Total Cost}$$
*Inventory Asset Principle*: Unsold active cattle are accounted for as biological assets/inventory at cost. They are never recorded as revenue until sold.

---

## 7. Budget Tracking & Threshold Warnings
$$\text{Budget Utilization (\%)} = \left(\frac{\text{Actual Expense Minor}}{\text{Budget Limit Minor}}\right) \times 100$$
$$\text{Remaining Budget Minor} = \text{Budget Limit Minor} - \text{Actual Expense Minor}$$
- If $\text{Utilization} \ge \text{Alert Percentage}$ (default 80%), trigger proactive warning.
- If $\text{Actual Expense} > \text{Budget Limit}$, flag budget as Over-Budget.

---

## 8. Household Shopping Integration
- A household shopping bill consists of multiple item line entries.
- The shopping bill creates a single consolidated expense transaction linked to the designated payment account and the "Household Shopping" category.
- Line items are tracked individually for product-wise, shop-wise, and price-trend analysis without generating duplicate expense journal entries.
