import 'package:get/get.dart';
import '../../features/accounts/presentation/bindings/account_binding.dart';
import '../../features/accounts/presentation/views/account_details_view.dart';
import '../../features/accounts/presentation/views/account_list_view.dart';
import '../../features/accounts/presentation/views/add_account_view.dart';
import '../../features/ai_assistant/presentation/bindings/ai_assistant_binding.dart';
import '../../features/ai_assistant/presentation/views/ai_assistant_view.dart';
import '../../features/ai_assistant/presentation/views/ocr_review_view.dart';
import '../../features/ai_assistant/presentation/views/receipt_scanner_view.dart';
import '../../features/ai_assistant/presentation/views/voice_entry_view.dart';
import '../../features/assets/presentation/bindings/asset_binding.dart';
import '../../features/assets/presentation/views/add_asset_view.dart';
import '../../features/assets/presentation/views/add_investment_view.dart';
import '../../features/assets/presentation/views/add_savings_goal_view.dart';
import '../../features/assets/presentation/views/assets_view.dart';
import '../../features/assets/presentation/views/investments_view.dart';
import '../../features/assets/presentation/views/savings_goals_view.dart';
import '../../features/authentication/presentation/bindings/auth_binding.dart';
import '../../features/authentication/presentation/views/onboarding_view.dart';
import '../../features/authentication/presentation/views/pin_view.dart';
import '../../features/authentication/presentation/views/splash_view.dart';
import '../../features/backup/presentation/bindings/backup_binding.dart';
import '../../features/backup/presentation/views/backup_view.dart';
import '../../features/budgets/presentation/bindings/budget_binding.dart';
import '../../features/budgets/presentation/views/add_budget_view.dart';
import '../../features/budgets/presentation/views/budget_list_view.dart';
import '../../features/business/presentation/bindings/business_binding.dart';
import '../../features/business/presentation/views/add_business_view.dart';
import '../../features/business/presentation/views/business_dashboard_view.dart';
import '../../features/business/presentation/views/business_list_view.dart';
import '../../features/business/presentation/views/business_purchase_view.dart';
import '../../features/business/presentation/views/business_sale_view.dart';
import '../../features/business/presentation/views/business_settings_view.dart';
import '../../features/business/presentation/views/business_transaction_details_view.dart';
import '../../features/business/presentation/views/cashbook_view.dart';
import '../../features/business/presentation/views/product_import_view.dart';
import '../../features/cattle/presentation/bindings/cattle_binding.dart';
import '../../features/cattle/presentation/views/add_cattle_view.dart';
import '../../features/cattle/presentation/views/cattle_details_view.dart';
import '../../features/cattle/presentation/views/cattle_list_view.dart';
import '../../features/customers/presentation/bindings/party_binding.dart';
import '../../features/customers/presentation/views/add_party_view.dart';
import '../../features/customers/presentation/views/customer_list_view.dart';
import '../../features/customers/presentation/views/party_ledger_view.dart';
import '../../features/dashboard/presentation/bindings/dashboard_binding.dart';
import '../../features/dashboard/presentation/views/main_nav_view.dart';
import '../../features/documents/presentation/bindings/document_binding.dart';
import '../../features/documents/presentation/views/documents_view.dart';
import '../../features/family/presentation/bindings/family_binding.dart';
import '../../features/family/presentation/views/add_family_member_view.dart';
import '../../features/family/presentation/views/family_list_view.dart';
import '../../features/family/presentation/views/family_permissions_view.dart';
import '../../features/household/presentation/bindings/household_binding.dart';
import '../../features/household/presentation/views/add_shopping_entry_view.dart';
import '../../features/household/presentation/views/shopping_list_view.dart';
import '../../features/household/presentation/views/shopping_view.dart';
import '../../features/inventory/presentation/bindings/inventory_binding.dart';
import '../../features/inventory/presentation/views/add_product_view.dart';
import '../../features/inventory/presentation/views/inventory_movement_view.dart';
import '../../features/inventory/presentation/views/product_list_view.dart';
import '../../features/loans/presentation/bindings/loan_binding.dart';
import '../../features/loans/presentation/views/add_loan_view.dart';
import '../../features/loans/presentation/views/loan_details_view.dart';
import '../../features/loans/presentation/views/loan_list_view.dart';
import '../../features/reminders/presentation/bindings/reminder_binding.dart';
import '../../features/reminders/presentation/views/reminders_view.dart';
import '../../features/reports/presentation/bindings/report_binding.dart';
import '../../features/reports/presentation/views/reports_view.dart';
import '../../features/settings/presentation/bindings/settings_binding.dart';
import '../../features/settings/presentation/views/settings_view.dart';
import '../../features/suppliers/presentation/views/supplier_list_view.dart';
import '../../features/transactions/presentation/bindings/transaction_binding.dart';
import '../../features/transactions/presentation/views/add_transaction_view.dart';
import '../../features/transactions/presentation/views/categories_view.dart';
import '../../features/transactions/presentation/views/transaction_details_view.dart';
import '../../features/transactions/presentation/views/transaction_list_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.mainNav;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.pinVerify,
      page: () => const PinView(isSettingNewPin: false),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.pinSetup,
      page: () => const PinView(isSettingNewPin: true),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.mainNav,
      page: () => const MainNavView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.transactionList,
      page: () => const TransactionListView(),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.transactionDetails,
      page: () => const TransactionDetailsView(),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.addIncome,
      page: () => const AddTransactionView(initialType: 'income'),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.addExpense,
      page: () => const AddTransactionView(initialType: 'expense'),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.addTransfer,
      page: () => const AddTransactionView(initialType: 'transfer'),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoriesView(),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.familyList,
      page: () => const FamilyListView(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.addFamilyMember,
      page: () => const AddFamilyMemberView(),
      binding: FamilyBinding(),
    ),
    GetPage(
      name: AppRoutes.familyPermissions,
      page: () => const FamilyPermissionsView(),
    ),
    GetPage(
      name: AppRoutes.householdShopping,
      page: () => const ShoppingView(),
      binding: HouseholdBinding(),
    ),
    GetPage(
      name: AppRoutes.shoppingEntry,
      page: () => const AddShoppingEntryView(),
      binding: HouseholdBinding(),
    ),
    GetPage(
      name: AppRoutes.shoppingLists,
      page: () => const ShoppingListView(),
      binding: HouseholdBinding(),
    ),
    GetPage(
      name: AppRoutes.businessList,
      page: () => const BusinessListView(),
      binding: BusinessBinding(),
    ),
    GetPage(
      name: AppRoutes.addBusiness,
      page: () => const AddBusinessView(),
      binding: BusinessBinding(),
    ),
    GetPage(
      name: AppRoutes.businessDashboard,
      page: () => const BusinessDashboardView(),
      binding: BusinessBinding(),
    ),
    GetPage(
      name: AppRoutes.businessSale,
      page: () => const BusinessSaleView(),
      binding: BusinessBinding(),
    ),
    GetPage(
      name: AppRoutes.businessPurchase,
      page: () => const BusinessPurchaseView(),
      binding: BusinessBinding(),
    ),
    GetPage(
      name: AppRoutes.businessSettings,
      page: () => const BusinessSettingsView(),
      binding: BusinessBinding(),
    ),
    GetPage(
      name: AppRoutes.cashbook,
      page: () => const CashbookView(),
      binding: BusinessBinding(),
    ),
    GetPage(
      name: AppRoutes.productImport,
      page: () => const ProductImportView(),
      binding: BusinessBinding(),
    ),
    GetPage(
      name: AppRoutes.businessTransactionDetails,
      page: () => const BusinessTransactionDetailsView(),
      binding: BusinessBinding(),
    ),
    GetPage(
      name: AppRoutes.cattleList,
      page: () => const CattleListView(),
      binding: CattleBinding(),
    ),
    GetPage(
      name: AppRoutes.addCattle,
      page: () => const AddCattleView(),
      binding: CattleBinding(),
    ),
    GetPage(
      name: AppRoutes.cattleDetails,
      page: () => const CattleDetailsView(),
      binding: CattleBinding(),
    ),
    GetPage(
      name: AppRoutes.productList,
      page: () => const ProductListView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: AppRoutes.addProduct,
      page: () => const AddProductView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: AppRoutes.inventoryMovement,
      page: () => const InventoryMovementView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: AppRoutes.customerList,
      page: () => const CustomerListView(),
      binding: PartyBinding(),
    ),
    GetPage(
      name: AppRoutes.addCustomer,
      page: () => const AddPartyView(isCustomer: true),
      binding: PartyBinding(),
    ),
    GetPage(
      name: AppRoutes.customerLedger,
      page: () => const PartyLedgerView(isCustomer: true),
      binding: PartyBinding(),
    ),
    GetPage(
      name: AppRoutes.supplierList,
      page: () => const SupplierListView(),
      binding: PartyBinding(),
    ),
    GetPage(
      name: AppRoutes.addSupplier,
      page: () => const AddPartyView(isCustomer: false),
      binding: PartyBinding(),
    ),
    GetPage(
      name: AppRoutes.supplierLedger,
      page: () => const PartyLedgerView(isCustomer: false),
      binding: PartyBinding(),
    ),
    GetPage(
      name: AppRoutes.loanList,
      page: () => const LoanListView(),
      binding: LoanBinding(),
    ),
    GetPage(
      name: AppRoutes.addLoan,
      page: () => const AddLoanView(),
      binding: LoanBinding(),
    ),
    GetPage(
      name: AppRoutes.loanDetails,
      page: () => const LoanDetailsView(),
      binding: LoanBinding(),
    ),
    GetPage(
      name: AppRoutes.accountList,
      page: () => const AccountListView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: AppRoutes.addAccount,
      page: () => const AddAccountView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: AppRoutes.accountDetails,
      page: () => const AccountDetailsView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: AppRoutes.assetsList,
      page: () => const AssetsView(),
      binding: AssetBinding(),
    ),
    GetPage(
      name: AppRoutes.addAsset,
      page: () => const AddAssetView(),
      binding: AssetBinding(),
    ),
    GetPage(
      name: AppRoutes.savingsGoals,
      page: () => const SavingsGoalsView(),
      binding: AssetBinding(),
    ),
    GetPage(
      name: AppRoutes.addSavingsGoal,
      page: () => const AddSavingsGoalView(),
      binding: AssetBinding(),
    ),
    GetPage(
      name: AppRoutes.investmentsList,
      page: () => const InvestmentsView(),
      binding: AssetBinding(),
    ),
    GetPage(
      name: AppRoutes.addInvestment,
      page: () => const AddInvestmentView(),
      binding: AssetBinding(),
    ),
    GetPage(
      name: AppRoutes.budgetList,
      page: () => const BudgetListView(),
      binding: BudgetBinding(),
    ),
    GetPage(
      name: AppRoutes.addBudget,
      page: () => const AddBudgetView(),
      binding: BudgetBinding(),
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsView(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoutes.aiAssistant,
      page: () => const AiAssistantView(),
      binding: AiAssistantBinding(),
    ),
    GetPage(
      name: AppRoutes.voiceEntry,
      page: () => const VoiceEntryView(),
      binding: AiAssistantBinding(),
    ),
    GetPage(
      name: AppRoutes.receiptScanner,
      page: () => const ReceiptScannerView(),
      binding: AiAssistantBinding(),
    ),
    GetPage(
      name: AppRoutes.ocrReview,
      page: () => const OcrReviewView(),
      binding: AiAssistantBinding(),
    ),
    GetPage(
      name: AppRoutes.reminders,
      page: () => const RemindersView(),
      binding: ReminderBinding(),
    ),
    GetPage(
      name: AppRoutes.documents,
      page: () => const DocumentsView(),
      binding: DocumentBinding(),
    ),
    GetPage(
      name: AppRoutes.backup,
      page: () => const BackupView(),
      binding: BackupBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
