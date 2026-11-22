import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/unit_conversion_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../utils/receipt_printer.dart';

class BusinessTransactionDetailsView extends StatefulWidget {
  const BusinessTransactionDetailsView({super.key});

  @override
  State<BusinessTransactionDetailsView> createState() =>
      _BusinessTransactionDetailsViewState();
}

class _BusinessTransactionDetailsViewState
    extends State<BusinessTransactionDetailsView> {
  final DatabaseService _dbService = Get.find<DatabaseService>();

  bool _isLoading = true;
  String _type = 'sale'; // 'sale' or 'purchase'
  String _id = '';

  BusinessesData? _business;
  SalesRecord? _sale;
  List<SalesItem> _saleItems = [];
  Customer? _customer;

  PurchaseRecord? _purchase;
  List<PurchaseItem> _purchaseItems = [];
  Supplier? _supplier;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _type = args?['type'] ?? 'sale';
    _id = args?['id'] ?? '';
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    try {
      if (_type == 'sale') {
        final sales = await _dbService.database.select(_dbService.database.salesRecords).get();
        _sale = sales.firstWhereOrNull((s) => s.id == _id);
        if (_sale != null) {
          _business = await _dbService.businessDao.getBusinessById(_sale!.businessId);
          _saleItems = await _dbService.businessDao.getSaleItems(_sale!.id);
          if (_sale!.customerId != null) {
            _customer = await _dbService.businessDao.getCustomerById(_sale!.customerId!);
          }
        }
      } else {
        final purchases = await _dbService.database.select(_dbService.database.purchaseRecords).get();
        _purchase = purchases.firstWhereOrNull((p) => p.id == _id);
        if (_purchase != null) {
          _business = await _dbService.businessDao.getBusinessById(_purchase!.businessId);
          _purchaseItems = await _dbService.businessDao.getPurchaseItems(_purchase!.id);
          if (_purchase!.supplierId != null) {
            _supplier = await _dbService.businessDao.getSupplierById(_purchase!.supplierId!);
          }
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _type == 'sale' ? 'বিক্রয় রসিদ ও বিবরণ' : 'ক্রয় মেমো ও বিবরণ',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const AppLoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: AppSizes.p16),
                  _buildInvoiceMetaCard(cardBg, borderColor, isDark),
                  const SizedBox(height: AppSizes.p16),
                  _buildItemsSection(cardBg, borderColor, isDark),
                  const SizedBox(height: AppSizes.p16),
                  _buildFinancialSummary(cardBg, borderColor, isDark),
                  const SizedBox(height: AppSizes.p24),
                  if (_type == 'sale' && _sale != null && _business != null)
                    _buildPrintActionButtons(),
                  const SizedBox(height: AppSizes.p32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSizes.r12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _business?.name ?? 'ব্যবসার নাম',
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          if (_business?.location != null) ...[
            const SizedBox(height: 2),
            Text(
              _business!.location!,
              style: const TextStyle(
                  color: AppColors.secondaryElectricLight, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceMetaCard(Color cardBg, Color borderColor, bool isDark) {
    final isSale = _type == 'sale';
    final invNo = isSale ? _sale?.invoiceNumber : _purchase?.invoiceNumber;
    final dateMillis = isSale ? _sale?.saleDate : _purchase?.purchaseDate;
    final timeStr = isSale ? _sale?.saleTime : _purchase?.purchaseTime;
    final partyName = isSale
        ? (_customer?.name ?? 'সাধারণ খরিদ্দার (Walk-in)')
        : (_supplier?.name ?? 'অজ্ঞাত সাপ্লায়ার');

    final dateStr = dateMillis != null
        ? DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(dateMillis))
        : '';

    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSizes.r8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildMetaRow('ইনভয়েস নম্বর:', '#${invNo ?? _id.substring(0, 6)}'),
          _buildMetaRow('তারিখ ও সময়:', '$dateStr  ${timeStr ?? ''}'),
          _buildMetaRow(
              isSale ? 'গ্রাহক (Customer):' : 'সাপ্লায়ার (Supplier):', partyName),
          if (isSale && _sale != null)
            _buildMetaRow('বিক্রয়ের ধরণ:', _sale!.saleType.toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildItemsSection(Color cardBg, Color borderColor, bool isDark) {
    final isSale = _type == 'sale';
    final count = isSale ? _saleItems.length : _purchaseItems.length;

    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSizes.r8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'পণ্যের বিবরণ ($count টি আইটেম)',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const Divider(),
          if (isSale)
            ..._saleItems.map((item) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.productName ?? 'পণ্য',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                        Text(
                          CurrencyUtils.format(item.totalMinor),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.quantity} ${item.unit ?? ''} × ${CurrencyUtils.format(item.unitPriceMinor)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        if (item.conversionFactor > 1)
                          Text(
                            'বেস স্টক কর্তন: ${item.baseQuantity} টি',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.incomeGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            })
          else
            ..._purchaseItems.map((item) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.productName ?? 'পণ্য',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                        Text(
                          CurrencyUtils.format(item.totalMinor),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ক্রয় পরিমাণ: ${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${UnitConversionUtils.getShortUnitLabel(item.unit ?? '')}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          'দর: ${CurrencyUtils.format(item.unitCostMinor)} / ${UnitConversionUtils.getShortUnitLabel(item.unit ?? '')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    if (item.conversionFactor > 1) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.incomeGreen.withValues(alpha: isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'প্যাকেজ রূপান্তর: ১ ${UnitConversionUtils.getShortUnitLabel(item.unit ?? '')} = ${item.conversionFactor % 1 == 0 ? item.conversionFactor.toInt() : item.conversionFactor} বেস একক',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.incomeGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'ইনভেন্টরি বৃদ্ধি: +${item.baseQuantity % 1 == 0 ? item.baseQuantity.toInt() : item.baseQuantity}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.incomeGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (item.retailPriceMinor > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'নির্ধারিত খুচরা বিক্রয়: ${CurrencyUtils.format(item.retailPriceMinor)}${item.wholesalePriceMinor > 0 ? ' | পাইকারি: ${CurrencyUtils.format(item.wholesalePriceMinor)}' : ''}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(Color cardBg, Color borderColor, bool isDark) {
    final isSale = _type == 'sale';
    final subtotal = isSale ? _sale?.subtotalMinor ?? 0 : _purchase?.subtotalMinor ?? 0;
    final discount = isSale ? _sale?.discountMinor ?? 0 : _purchase?.discountMinor ?? 0;
    final total = isSale ? _sale?.totalMinor ?? 0 : _purchase?.totalMinor ?? 0;
    final paid = isSale ? _sale?.paidMinor ?? 0 : _purchase?.paidMinor ?? 0;
    final due = isSale ? _sale?.dueMinor ?? 0 : _purchase?.dueMinor ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSizes.r8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildMetaRow('সাবটোটাল:', CurrencyUtils.format(subtotal)),
          if (discount > 0)
            _buildMetaRow('ছাড় (Discount):', '- ${CurrencyUtils.format(discount)}'),
          const Divider(),
          _buildMetaRow('মোট বিল (Total):', CurrencyUtils.format(total)),
          _buildMetaRow('পরিশোধিত (Paid):', CurrencyUtils.format(paid)),
          if (due > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('বকেয়া টাকা (Due):',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.expenseRed)),
                  Text(CurrencyUtils.format(due),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.expenseRed)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrintActionButtons() {
    return Column(
      children: [
        AppButton(
          text: '৮০ মিমি থার্মাল রসিদ প্রিন্ট (POS 80mm)',
          icon: Icons.print_outlined,
          onPressed: () {
            ReceiptPrinter.printSaleReceipt(
              business: _business!,
              sale: _sale!,
              items: _saleItems,
              customerName: _customer?.name,
              format: ReceiptFormat.thermal80,
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.receipt_long),
                label: const Text('৫৮ মিমি থার্মাল'),
                onPressed: () {
                  ReceiptPrinter.printSaleReceipt(
                    business: _business!,
                    sale: _sale!,
                    items: _saleItems,
                    customerName: _customer?.name,
                    format: ReceiptFormat.thermal58,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('A4 ইনভয়েস PDF'),
                onPressed: () {
                  ReceiptPrinter.printSaleReceipt(
                    business: _business!,
                    sale: _sale!,
                    items: _saleItems,
                    customerName: _customer?.name,
                    format: ReceiptFormat.a4,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
