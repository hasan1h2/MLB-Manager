abstract class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const languageSelection = '/language-selection';
  static const pinSetup = '/pin-setup';
  static const pinVerify = '/pin-verify';

  // Navigation Root
  static const mainNav = '/main-nav';

  // Dashboard
  static const dashboard = '/dashboard';

  // Transactions
  static const transactionList = '/transactions';
  static const addIncome = '/transactions/add-income';
  static const addExpense = '/transactions/add-expense';
  static const addTransfer = '/transactions/add-transfer';
  static const transactionDetails = '/transactions/details';
  static const categories = '/categories';

  // Family
  static const familyList = '/family';
  static const addFamilyMember = '/family/add';
  static const familyMemberDetails = '/family/details';
  static const familyPermissions = '/family/permissions';

  // Household Shopping
  static const householdShopping = '/shopping';
  static const shoppingEntry = '/shopping/entry';
  static const shoppingHistory = '/shopping/history';
  static const shoppingLists = '/shopping/lists';

  // Business
  static const businessList = '/business';
  static const addBusiness = '/business/add';
  static const businessDashboard = '/business/dashboard';

  // Cattle
  static const cattleList = '/cattle';
  static const addCattle = '/cattle/add';
  static const cattleDetails = '/cattle/details';
  static const cattleExpenses = '/cattle/expenses';
  static const cattleSale = '/cattle/sale';

  // Inventory
  static const productList = '/inventory';
  static const addProduct = '/inventory/add';
  static const productDetails = '/inventory/details';
  static const inventoryMovement = '/inventory/movement';
  static const purchaseEntry = '/inventory/purchase';
  static const salesEntry = '/inventory/sale';

  // Customers & Suppliers
  static const customerList = '/customers';
  static const addCustomer = '/customers/add';
  static const customerLedger = '/customers/ledger';
  static const supplierList = '/suppliers';
  static const addSupplier = '/suppliers/add';
  static const supplierLedger = '/suppliers/ledger';

  // Loans
  static const loanList = '/loans';
  static const addLoan = '/loans/add';
  static const loanDetails = '/loans/details';
  static const loanPayment = '/loans/payment';

  // Accounts
  static const accountList = '/accounts';
  static const addAccount = '/accounts/add';
  static const accountDetails = '/accounts/details';
  static const accountTransfer = '/accounts/transfer';

  // Assets, Savings, Investments
  static const assetsList = '/assets';
  static const addAsset = '/assets/add';
  static const savingsGoals = '/savings';
  static const addSavingsGoal = '/savings/add';
  static const investmentsList = '/investments';
  static const addInvestment = '/investments/add';

  // Budgets
  static const budgetList = '/budgets';
  static const addBudget = '/budgets/add';

  // Reports
  static const reports = '/reports';
  static const reportDetails = '/reports/details';

  // AI & Hardware
  static const aiAssistant = '/ai';
  static const voiceEntry = '/ai/voice';
  static const receiptScanner = '/ai/ocr';
  static const ocrReview = '/ai/ocr-review';

  // Tools & System
  static const reminders = '/reminders';
  static const documents = '/documents';
  static const backup = '/backup';
  static const settings = '/settings';
}
