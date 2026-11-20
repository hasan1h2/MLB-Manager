import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import 'package:mlb_manager/features/household/presentation/controllers/household_controller.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class _SpendAggregator {
  final String displayName;
  final String unit;
  double totalQuantity = 0.0;
  int totalAmountMinor = 0;
  int purchaseCount = 0;
  String? imagePath;

  _SpendAggregator({
    required this.displayName,
    required this.unit,
    this.imagePath,
  });
}

class ReportSummaryData {
  final int totalIncomeMinor;
  final int totalExpenseMinor;
  final int netProfitMinor;
  final List<Transaction> transactions;

  ReportSummaryData({
    required this.totalIncomeMinor,
    required this.totalExpenseMinor,
    required this.netProfitMinor,
    required this.transactions,
  });
}

class ReportController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();

  final RxString selectedFilter = 'filter_this_month'.obs;
  final Rx<ReportSummaryData?> summaryData = Rx<ReportSummaryData?>(null);
  final RxBool isLoading = true.obs;
  final RxInt selectedReportTab = 0.obs; // 0: Summary, 1: Product Market Spend
  final RxList<ProductSummaryItem> marketProductSpend =
      <ProductSummaryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadReport();
  }

  Future<void> setFilter(String filter) async {
    selectedFilter.value = filter;
    await loadReport();
  }

  Future<void> loadReport() async {
    try {
      isLoading.value = true;
      final range = AppDateUtils.getFilterRange(selectedFilter.value);
      final txs = await _dbService.coreDao
          .getTransactionsInRange(range.startMs, range.endMs);

      int inc = 0;
      int exp = 0;
      for (var t in txs) {
        if (t.transactionType == 'income') {
          inc += t.amountMinor;
        } else if (t.transactionType == 'expense') {
          exp += t.amountMinor;
        }
      }

      summaryData.value = ReportSummaryData(
        totalIncomeMinor: inc,
        totalExpenseMinor: exp,
        netProfitMinor: inc - exp,
        transactions: txs,
      );

      // Aggregate product spend for market expenses in this range
      final spendMap = <String, _SpendAggregator>{};
      for (var t in txs) {
        if (t.sourceId != null) {
          final items =
              await _dbService.householdDao.getItemsForRecord(t.sourceId!);
          for (var item in items) {
            final key =
                '${item.productName.trim().toLowerCase()}__${item.unit}';
            if (!spendMap.containsKey(key)) {
              spendMap[key] = _SpendAggregator(
                displayName: item.productName.trim(),
                unit: item.unit,
                imagePath: item.imagePath,
              );
            }
            final agg = spendMap[key]!;
            agg.totalQuantity += item.quantity;
            agg.totalAmountMinor += item.totalMinor;
            agg.purchaseCount += 1;
            if (agg.imagePath == null && item.imagePath != null) {
              agg.imagePath = item.imagePath;
            }
          }
        }
      }

      final spendList = spendMap.values.map((agg) {
        return ProductSummaryItem(
          productName: agg.displayName,
          unit: agg.unit,
          totalQuantity: agg.totalQuantity,
          totalAmountMinor: agg.totalAmountMinor,
          purchaseCount: agg.purchaseCount,
          imagePath: agg.imagePath,
        );
      }).toList();

      spendList
          .sort((a, b) => b.totalAmountMinor.compareTo(a.totalAmountMinor));
      marketProductSpend.value = spendList;
    } finally {
      isLoading.value = false;
    }
  }

  // --- Export to PDF ---
  Future<void> exportPdf() async {
    final data = summaryData.value;
    if (data == null) return;

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('My Life & Business Manager (MLB Manager)',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    'Financial Statement Report (${selectedFilter.value.tr})',
                    style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 16),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Income:'),
                    pw.Text(CurrencyUtils.format(data.totalIncomeMinor,
                        useBengaliDigits: false)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Expenses:'),
                    pw.Text(CurrencyUtils.format(data.totalExpenseMinor,
                        useBengaliDigits: false)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Net Balance / Profit:'),
                    pw.Text(CurrencyUtils.format(data.netProfitMinor,
                        useBengaliDigits: false)),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Divider(),
                pw.Text('Transactions Count: ${data.transactions.length}'),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  // --- Export to CSV ---
  Future<void> exportCsv() async {
    final data = summaryData.value;
    if (data == null) return;

    final rows = <List<dynamic>>[];
    rows.add(
        ['Date', 'Tx Number', 'Type', 'Scope', 'Amount (BDT)', 'Description']);

    for (var tx in data.transactions) {
      rows.add([
        AppDateUtils.formatTimestamp(tx.transactionDate),
        tx.transactionNumber,
        tx.transactionType,
        tx.scopeType,
        (tx.amountMinor / 100).toStringAsFixed(2),
        tx.description ?? '',
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/mlb_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvString);

    AppSnackbar.success('CSV ফাইল সংরক্ষিত হয়েছে: ${file.path}');
  }

  // --- Export Detailed CSV with Item Breakdown ---
  Future<void> exportDetailedCsv() async {
    final data = summaryData.value;
    if (data == null) return;

    final rows = <List<dynamic>>[];
    rows.add([
      'Date',
      'Time',
      'Tx Number',
      'Type',
      'Scope',
      'Product Name',
      'Quantity',
      'Unit',
      'Unit Price (BDT)',
      'Line Total (BDT)',
      'Transaction Total (BDT)',
      'Description',
    ]);

    for (var tx in data.transactions) {
      final dateStr = AppDateUtils.formatTimestamp(tx.transactionDate);
      final timeStr = tx.purchaseTime ?? '';
      final totalBdt = (tx.amountMinor / 100).toStringAsFixed(2);

      if (tx.sourceId != null) {
        final items =
            await _dbService.householdDao.getItemsForRecord(tx.sourceId!);
        if (items.isNotEmpty) {
          for (var item in items) {
            rows.add([
              dateStr,
              timeStr,
              tx.transactionNumber,
              tx.transactionType,
              tx.scopeType,
              item.productName,
              item.quantity > 0 ? item.quantity.toString() : '-',
              item.unit.isNotEmpty ? item.unit : '-',
              item.unitPriceMinor > 0
                  ? (item.unitPriceMinor / 100).toStringAsFixed(2)
                  : '-',
              (item.totalMinor / 100).toStringAsFixed(2),
              totalBdt,
              tx.description ?? '',
            ]);
          }
          continue;
        }
      }

      rows.add([
        dateStr,
        timeStr,
        tx.transactionNumber,
        tx.transactionType,
        tx.scopeType,
        '-',
        '-',
        '-',
        '-',
        totalBdt,
        totalBdt,
        tx.description ?? '',
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/mlb_detailed_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvString);

    AppSnackbar.success('বিস্তারিত পণ্যসহ CSV সংরক্ষিত হয়েছে: ${file.path}');
  }

  // --- Export to Excel ---
  Future<void> exportExcel() async {
    final data = summaryData.value;
    if (data == null) return;

    final excel = Excel.createExcel();
    final sheet = excel['Transactions'];

    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Tx Number'),
      TextCellValue('Type'),
      TextCellValue('Scope'),
      TextCellValue('Amount (BDT)'),
      TextCellValue('Description'),
    ]);

    for (var tx in data.transactions) {
      sheet.appendRow([
        TextCellValue(AppDateUtils.formatTimestamp(tx.transactionDate)),
        TextCellValue(tx.transactionNumber),
        TextCellValue(tx.transactionType),
        TextCellValue(tx.scopeType),
        TextCellValue((tx.amountMinor / 100).toStringAsFixed(2)),
        TextCellValue(tx.description ?? ''),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/mlb_report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
      AppSnackbar.success('Excel ফাইল সংরক্ষিত হয়েছে: ${file.path}');
    }
  }
}
