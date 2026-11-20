import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/transaction_controller.dart';

class TransactionDetailsView extends StatefulWidget {
  const TransactionDetailsView({super.key});

  @override
  State<TransactionDetailsView> createState() => _TransactionDetailsViewState();
}

class _TransactionDetailsViewState extends State<TransactionDetailsView> {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final TransactionController _txController = Get.find<TransactionController>();

  Transaction? _transaction;
  ShoppingRecord? _shoppingRecord;
  List<ShoppingItem> _shoppingItems = [];
  Account? _account;
  Category? _category;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  Future<void> _loadTransactionDetails() async {
    final args = Get.arguments;
    if (args is Transaction) {
      _transaction = args;
    } else if (args is String) {
      final tx = await _dbService.coreDao.getTransactionById(args);
      _transaction = tx;
    }

    if (_transaction != null) {
      final tx = _transaction!;
      if (tx.accountId != null) {
        _account = await _dbService.coreDao.getAccountById(tx.accountId!);
      }
      if (tx.categoryId != null) {
        _category = await _dbService.coreDao.getCategoryById(tx.categoryId!);
      }

      if (tx.sourceType == 'shopping' && tx.sourceId != null) {
        final records = await _dbService.householdDao
            .getShoppingRecordsInRange(0, 9999999999999);
        _shoppingRecord = records.firstWhereOrNull((r) => r.id == tx.sourceId);
        _shoppingItems =
            await _dbService.householdDao.getItemsForRecord(tx.sourceId!);
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('লেনদেনের বিস্তারিত')),
        body: const Center(child: AppLoadingIndicator()),
      );
    }

    if (_transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('লেনদেনের বিস্তারিত')),
        body: Center(
          child: Text(
            'লেনদেনের তথ্য পাওয়া যায়নি',
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ),
      );
    }

    final tx = _transaction!;
    final isIncome = tx.transactionType == 'income';
    final isTransfer = tx.transactionType == 'transfer';

    Color themeColor = AppColors.expenseRed;
    IconData typeIcon = AppIcons.expense;
    String typeLabel = 'খরচ';

    if (isIncome) {
      themeColor = AppColors.incomeGreen;
      typeIcon = AppIcons.income;
      typeLabel = 'আয়';
    } else if (isTransfer) {
      themeColor = AppColors.secondaryElectric;
      typeIcon = AppIcons.transfer;
      typeLabel = 'স্থানান্তর';
    }

    // Determine purchase time: check transaction first, then linked shopping record
    final purchaseTime = tx.purchaseTime ?? _shoppingRecord?.purchaseTime;

    return Scaffold(
      appBar: AppBar(
        title: const Text('লেনদেনের বিস্তারিত'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.delete, color: Colors.white),
            tooltip: 'মুছুন',
            onPressed: () {
              AppConfirmDialog.show(
                title: 'delete'.tr,
                message: 'delete_transaction_confirm'.tr,
                isDestructive: true,
                onConfirm: () async {
                  await _txController.deleteTransaction(tx.id);
                  Get.back();
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Amount Card
            _buildTopAmountCard(tx, themeColor, typeIcon, typeLabel, isDark),
            const SizedBox(height: AppSizes.p16),

            // Metadata & Account Card
            _buildMetadataCard(tx, purchaseTime, isDark),
            const SizedBox(height: AppSizes.p16),

            // Itemized Shopping Breakdown or Direct Total Badge
            if (tx.sourceType == 'shopping') ...[
              _buildShoppingBreakdownCard(isDark),
              const SizedBox(height: AppSizes.p16),
            ],

            // Delete Action Button
            AppButton(
              text: 'লেনদেন মুছুন (Delete Transaction)',
              icon: AppIcons.delete,
              backgroundColor: AppColors.expenseRed,
              onPressed: () {
                AppConfirmDialog.show(
                  title: 'delete'.tr,
                  message: 'delete_transaction_confirm'.tr,
                  isDestructive: true,
                  onConfirm: () async {
                    await _txController.deleteTransaction(tx.id);
                    Get.back();
                  },
                );
              },
            ),
            const SizedBox(height: AppSizes.p24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAmountCard(
    Transaction tx,
    Color themeColor,
    IconData typeIcon,
    String typeLabel,
    bool isDark,
  ) {
    final isIncome = tx.transactionType == 'income';
    final isTransfer = tx.transactionType == 'transfer';
    final sign = isIncome ? '+' : (isTransfer ? '' : '-');

    return Card(
      elevation: 0,
      color: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
        side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Type badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.rFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(typeIcon, color: themeColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        typeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Scope badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.surfaceDark : AppColors.dividerLight,
                    borderRadius: BorderRadius.circular(AppSizes.rFull),
                    border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight),
                  ),
                  child: Text(
                    tx.scopeType.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),
            Text(
              '$sign${CurrencyUtils.format(tx.amountMinor)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: themeColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSizes.p6),
            Text(
              tx.description?.isNotEmpty == true
                  ? tx.description!
                  : tx.transactionNumber,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p4),
            Text(
              'লেনদেন নম্বর: ${tx.transactionNumber}',
              style: TextStyle(
                fontSize: 12,
                color:
                    isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataCard(Transaction tx, String? purchaseTime, bool isDark) {
    final isBn = Get.locale?.languageCode == 'bn';
    final categoryName = _category != null
        ? (isBn ? _category!.nameBn : _category!.nameEn)
        : 'বাজার খরচ';

    return Card(
      elevation: 0,
      color: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
        side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            _buildDetailRow(
              icon: AppIcons.calendar,
              iconColor: AppColors.secondaryElectric,
              label: 'তারিখ (Date)',
              value: AppDateUtils.standardDateFormat.format(
                  DateTime.fromMillisecondsSinceEpoch(tx.transactionDate)),
              isDark: isDark,
            ),
            if (purchaseTime != null && purchaseTime.trim().isNotEmpty) ...[
              const Divider(height: 20),
              _buildDetailRow(
                icon: Icons.access_time_rounded,
                iconColor: AppColors.infoBlue,
                label: 'সময় (Time)',
                value: purchaseTime,
                isDark: isDark,
              ),
            ],
            const Divider(height: 20),
            _buildDetailRow(
              icon: AppIcons.accounts,
              iconColor: AppColors.incomeGreen,
              label: 'অ্যাকাউন্ট / মাধ্যম',
              value: _account?.name ?? 'নগদ ক্যাশ (Cash)',
              isDark: isDark,
            ),
            const Divider(height: 20),
            _buildDetailRow(
              icon: Icons.category_outlined,
              iconColor: AppColors.warningAmber,
              label: 'ক্যাটাগরি',
              value: categoryName,
              isDark: isDark,
            ),
            const Divider(height: 20),
            _buildDetailRow(
              icon: Icons.check_circle_outline_rounded,
              iconColor: tx.paymentStatus == 'paid'
                  ? AppColors.incomeGreen
                  : AppColors.warningAmber,
              label: 'পেমেন্ট স্ট্যাটাস',
              value: tx.paymentStatus == 'paid'
                  ? 'পরিশোধিত (Paid)'
                  : 'বকেয়া / আংশিক',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: AppSizes.p10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShoppingBreakdownCard(bool isDark) {
    final isDirectTotal =
        _shoppingRecord?.entryMode == 'direct_total' || _shoppingItems.isEmpty;

    return Card(
      elevation: 0,
      color: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
        side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(AppIcons.shopping,
                        color: AppColors.secondaryElectric, size: 20),
                    const SizedBox(width: AppSizes.p8),
                    Text(
                      'বাজারের বিবরণ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDirectTotal
                        ? AppColors.infoBlue.withValues(alpha: 0.15)
                        : AppColors.incomeGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.rFull),
                  ),
                  child: Text(
                    isDirectTotal
                        ? 'শুধু মোট টাকা'
                        : '${_shoppingItems.length} টি পণ্য',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDirectTotal
                          ? AppColors.infoBlue
                          : AppColors.incomeGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            if (isDirectTotal) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.p12),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.surfaceDark : AppColors.dividerLight,
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.infoBlue, size: 20),
                    const SizedBox(width: AppSizes.p10),
                    Expanded(
                      child: Text(
                        'এই লেনদেনটি শুধু মোট টাকা হিসেবে এন্ট্রি করা হয়েছিল (কোনো পৃথক পণ্যের তালিকা নেই)।',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Itemized list of purchased products
              Text(
                'ক্রয়কৃত পণ্যের তালিকা:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.p8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _shoppingItems.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final item = _shoppingItems[index];
                  final hasUnitPrice = item.unitPriceMinor > 0;
                  final hasQty = item.quantity > 0;
                  final hasUnit = item.unit.isNotEmpty;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Index badge
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: (isDark
                            ? AppColors.surfaceDark
                            : Colors.grey.shade200),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.p10),

                      // Optional Item Image
                      if (item.imagePath != null &&
                          item.imagePath!.isNotEmpty) ...[
                        AppImage(
                          imagePath: item.imagePath,
                          width: 36,
                          height: 36,
                          borderRadius: AppSizes.r8,
                        ),
                        const SizedBox(width: AppSizes.p8),
                      ],

                      // Product Name & details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (hasQty)
                                  Text(
                                    'পরিমাণ: ${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 2)} ${hasUnit ? _formatUnit(item.unit) : ""}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                if (hasUnitPrice)
                                  Text(
                                    'দর: ${CurrencyUtils.format(item.unitPriceMinor)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                              ],
                            ),
                            if (item.note != null && item.note!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'নোট: ${item.note!}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Line Total
                      Text(
                        CurrencyUtils.format(item.totalMinor),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const Divider(height: 24),
              // Bill Summary breakdown
              if (_shoppingRecord != null) ...[
                _buildBillSummaryRow(
                    'সাবটোটাল',
                    CurrencyUtils.format(_shoppingRecord!.subtotalMinor),
                    isDark),
                if (_shoppingRecord!.discountMinor > 0) ...[
                  const SizedBox(height: 6),
                  _buildBillSummaryRow(
                      'ছাড় (Discount)',
                      '- ${CurrencyUtils.format(_shoppingRecord!.discountMinor)}',
                      isDark,
                      isDiscount: true),
                ],
                const SizedBox(height: 6),
                _buildBillSummaryRow('সর্বমোট বিল',
                    CurrencyUtils.format(_shoppingRecord!.totalMinor), isDark,
                    isBold: true),
                const SizedBox(height: 6),
                _buildBillSummaryRow('পরিশোধিত',
                    CurrencyUtils.format(_shoppingRecord!.paidMinor), isDark),
                if (_shoppingRecord!.dueMinor > 0) ...[
                  const SizedBox(height: 6),
                  _buildBillSummaryRow('বকেয়া (Due)',
                      CurrencyUtils.format(_shoppingRecord!.dueMinor), isDark,
                      isDue: true),
                ],
              ],
            ],
            if (_shoppingRecord?.notes != null &&
                _shoppingRecord!.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.p12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.p10),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.surfaceDark : AppColors.dividerLight,
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
                child: Text(
                  'নোট: ${_shoppingRecord!.notes}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBillSummaryRow(String label, String value, bool isDark,
      {bool isBold = false, bool isDiscount = false, bool isDue = false}) {
    Color valColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    if (isDiscount) valColor = AppColors.incomeGreen;
    if (isDue) valColor = AppColors.warningAmberDark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valColor,
          ),
        ),
      ],
    );
  }

  String _formatUnit(String unit) {
    switch (unit) {
      case 'kg':
        return 'কেজি';
      case 'liter':
        return 'লিটার';
      case 'piece':
        return 'পিস';
      case 'packet':
        return 'প্যাকেট';
      case 'g':
        return 'গ্রাম';
      case 'ml':
        return 'মিলি';
      case 'dozen':
        return 'ডজন';
      case 'box':
        return 'বক্স';
      case 'bottle':
        return 'বোতল';
      case 'carton':
        return 'কার্টন';
      default:
        return unit;
    }
  }
}
