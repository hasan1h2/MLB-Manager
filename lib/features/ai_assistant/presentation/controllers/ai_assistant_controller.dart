import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart' hide Value;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class ParsedAiItem {
  String name;
  double quantity;
  String unit;
  int unitPriceMinor;
  int get totalMinor => (quantity * unitPriceMinor).round();

  ParsedAiItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPriceMinor,
  });
}

class AiAssistantController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  // Voice State
  final stt.SpeechToText _speech = stt.SpeechToText();
  final RxBool isListening = false.obs;
  final RxString recognizedVoiceText = ''.obs;
  final RxBool isSpeechAvailable = false.obs;

  // OCR State
  final ImagePicker _picker = ImagePicker();
  final RxString ocrRawText = ''.obs;
  final RxBool isProcessingOcr = false.obs;

  // Review List
  final RxList<ParsedAiItem> extractedItems = <ParsedAiItem>[].obs;
  final RxString extractedStoreName = 'দোকান'.obs;

  // Statistical Prediction
  final RxInt forecastedMonthlyExpenseMinor = 0.obs;
  final RxString forecastConfidence = 'মাঝারি (Medium)'.obs;

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
    calculateLocalForecast();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (val) => isListening.value = false,
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            isListening.value = false;
          }
        },
      );
      isSpeechAvailable.value = available;
    } catch (_) {
      isSpeechAvailable.value = false;
    }
  }

  // --- Voice Recording ---
  Future<void> toggleVoiceListening() async {
    if (isListening.value) {
      await _speech.stop();
      isListening.value = false;
      parseNaturalLanguage(recognizedVoiceText.value);
    } else {
      recognizedVoiceText.value = '';
      final hasInit = await _speech.initialize();
      if (hasInit) {
        isListening.value = true;
        _speech.listen(
          localeId: 'bn_BD',
          onResult: (result) {
            recognizedVoiceText.value = result.recognizedWords;
            if (result.finalResult) {
              isListening.value = false;
              parseNaturalLanguage(result.recognizedWords);
            }
          },
        );
      } else {
        AppSnackbar.info('মাইক্রোফোন চালু করা যায়নি। ম্যানুয়ালি টেক্সট লিখুন।');
      }
    }
  }

  /// Natural language parser for Bengali/English e.g.:
  /// "আজ বাজার থেকে ২ কেজি চাল ১৪০ টাকা এবং ১ লিটার তেল ১৮০ টাকা কিনেছি।"
  void parseNaturalLanguage(String text) {
    if (text.trim().isEmpty) return;

    final items = <ParsedAiItem>[];
    // Example regex patterns to capture "<qty> <unit> <name> <price> টাকা"
    // e.g. "২ কেজি চাল ১৪০ টাকা"
    final regex = RegExp(
      r'(\d+|[০-৯]+)\s*(কেজি|লিটার|গ্রাম|পিস|kg|liter|gm|piece)?\s*([^\d০-৯\s]+)\s*(\d+|[০-৯]+)\s*(টাকা|tk|bdt)?',
      caseSensitive: false,
    );

    final matches = regex.allMatches(text);
    for (var match in matches) {
      final qtyStr = _convertBengaliToEnglishDigits(match.group(1) ?? '1');
      final unit = match.group(2) ?? 'কেজি';
      final name = match.group(3) ?? 'পণ্য';
      final priceStr = _convertBengaliToEnglishDigits(match.group(4) ?? '0');

      final qty = double.tryParse(qtyStr) ?? 1.0;
      final priceMinor = CurrencyUtils.takaToMinor(priceStr);

      items.add(ParsedAiItem(
        name: name,
        quantity: qty,
        unit: unit,
        unitPriceMinor: (qty > 0 ? (priceMinor / qty).round() : priceMinor),
      ));
    }

    if (items.isEmpty) {
      // Fallback single item parsing if strict pattern didn't match
      items.add(ParsedAiItem(
        name: text.length > 20 ? text.substring(0, 20) : text,
        quantity: 1,
        unit: 'পিস',
        unitPriceMinor: 10000,
      ));
    }

    extractedItems.value = items;
    Get.toNamed(AppRoutes.ocrReview);
  }

  // --- OCR Receipt Scanner ---
  Future<void> pickAndScanReceipt({bool fromCamera = true}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (image == null) return;

      isProcessingOcr.value = true;
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognized = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      ocrRawText.value = recognized.text;
      parseOcrText(recognized.text);
    } catch (e) {
      AppSnackbar.error('OCR স্ক্যান করতে সমস্যা হয়েছে: $e');
    } finally {
      isProcessingOcr.value = false;
    }
  }

  void parseOcrText(String text) {
    final lines = text.split('\n');
    final items = <ParsedAiItem>[];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Match numbers at end of line as price
      final match = RegExp(r'^(.*?)\s+([0-9]+(\.[0-9]{1,2})?)$').firstMatch(trimmed);
      if (match != null) {
        final name = match.group(1) ?? 'Item';
        final priceStr = match.group(2) ?? '0';
        final priceMinor = CurrencyUtils.takaToMinor(priceStr);
        if (priceMinor > 0) {
          items.add(ParsedAiItem(
            name: name,
            quantity: 1.0,
            unit: 'piece',
            unitPriceMinor: priceMinor,
          ));
        }
      }
    }

    if (items.isEmpty) {
      items.add(ParsedAiItem(
        name: 'রসিদ খরচ',
        quantity: 1.0,
        unit: 'পিস',
        unitPriceMinor: 50000,
      ));
    }

    extractedItems.value = items;
    Get.toNamed(AppRoutes.ocrReview);
  }

  // --- Confirm & Save Extracted Items ---
  Future<void> confirmAndSaveExtractedBill() async {
    if (extractedItems.isEmpty) return;

    final accounts = await _dbService.coreDao.getAllAccounts();
    final defaultAccId = accounts.isNotEmpty ? accounts.first.id : null;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final recordId = _uuid.v4();

    int totalMinor = 0;
    final itemsCompanion = <ShoppingItemsCompanion>[];

    for (var item in extractedItems) {
      totalMinor += item.totalMinor;
      itemsCompanion.add(
        ShoppingItemsCompanion(
          id: drift.Value(_uuid.v4()),
          shoppingRecordId: drift.Value(recordId),
          productName: drift.Value(item.name),
          quantity: drift.Value(item.quantity),
          unit: drift.Value(item.unit),
          unitPriceMinor: drift.Value(item.unitPriceMinor),
          totalMinor: drift.Value(item.totalMinor),
        ),
      );
    }

    final record = ShoppingRecordsCompanion(
      id: drift.Value(recordId),
      shoppingDate: drift.Value(now),
      storeName: drift.Value(extractedStoreName.value),
      subtotalMinor: drift.Value(totalMinor),
      discountMinor: const drift.Value(0),
      totalMinor: drift.Value(totalMinor),
      paidMinor: drift.Value(totalMinor),
      dueMinor: const drift.Value(0),
      createdAt: drift.Value(now),
    );

    TransactionsCompanion? tx;
    List<TransactionEntriesCompanion>? entries;

    if (defaultAccId != null) {
      final txId = _uuid.v4();
      tx = TransactionsCompanion(
        id: drift.Value(txId),
        transactionNumber: drift.Value('AI-${now.toString().substring(5)}'),
        transactionType: const drift.Value('expense'),
        scopeType: const drift.Value('family'),
        accountId: drift.Value(defaultAccId),
        amountMinor: drift.Value(totalMinor),
        transactionDate: drift.Value(now),
        description: drift.Value('AI এন্ট্রি: ${extractedStoreName.value}'),
        sourceType: const drift.Value('voice'),
        sourceId: drift.Value(recordId),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      );

      entries = [
        TransactionEntriesCompanion(
          id: drift.Value(_uuid.v4()),
          transactionId: drift.Value(txId),
          accountId: drift.Value(defaultAccId),
          debitMinor: drift.Value(totalMinor),
          creditMinor: const drift.Value(0),
          createdAt: drift.Value(now),
        ),
        TransactionEntriesCompanion(
          id: drift.Value(_uuid.v4()),
          transactionId: drift.Value(txId),
          accountId: drift.Value(defaultAccId),
          debitMinor: const drift.Value(0),
          creditMinor: drift.Value(totalMinor),
          createdAt: drift.Value(now),
        ),
      ];
    }

    await _dbService.householdDao.postShoppingRecordWithItems(
      record: record,
      items: itemsCompanion,
      expenseTransaction: tx,
      journalEntries: entries,
    );

    // Save AI extraction log
    await _dbService.database.into(_dbService.database.aiExtractions).insert(
          AiExtractionsCompanion(
            id: drift.Value(_uuid.v4()),
            extractionType: const drift.Value('voice_ocr'),
            extractedText: drift.Value(recognizedVoiceText.value.isNotEmpty ? recognizedVoiceText.value : ocrRawText.value),
            extractedDataJson: drift.Value(jsonEncode(extractedItems.map((e) => {'name': e.name, 'total': e.totalMinor}).toList())),
            status: const drift.Value('confirmed'),
            createdAt: drift.Value(now),
          ),
        );

    AppSnackbar.success('যাচাইকৃত লেনদেন সফলভাবে সংরক্ষণ করা হয়েছে');
    Get.offAllNamed(AppRoutes.mainNav);
  }

  // --- Statistical Moving-Average Expense Forecasting ---
  Future<void> calculateLocalForecast() async {
    final now = DateTime.now();
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1).toUtc().millisecondsSinceEpoch;
    final endOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59).toUtc().millisecondsSinceEpoch;

    final txs = await _dbService.coreDao.getTransactionsInRange(startOfLastMonth, endOfLastMonth);
    int lastMonthExpense = 0;
    for (var t in txs) {
      if (t.transactionType == 'expense') {
        lastMonthExpense += t.amountMinor;
      }
    }

    // If historical data exists, apply 5% trend smoothing
    if (lastMonthExpense > 0) {
      forecastedMonthlyExpenseMinor.value = (lastMonthExpense * 1.05).round();
      forecastConfidence.value = 'উচ্চ (High: ১ মাসের নির্ভরযোগ্য হিস্টোরি)';
    } else {
      forecastedMonthlyExpenseMinor.value = 2500000; // 25,000 BDT default baseline
      forecastConfidence.value = 'প্রাথমিক প্রাক্কলন (বাজেট ডেটা সীমিত)';
    }
  }

  String _convertBengaliToEnglishDigits(String input) {
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    String res = input;
    for (int i = 0; i < bengali.length; i++) {
      res = res.replaceAll(bengali[i], english[i]);
    }
    return res;
  }
}
