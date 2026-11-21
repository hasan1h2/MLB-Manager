import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/active_business_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/currency_utils.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class ImportProductCandidate {
  final TextEditingController nameController;
  final TextEditingController unitController;
  final TextEditingController purchasePriceController;
  final TextEditingController sellingPriceController;
  final TextEditingController wholesalePriceController;
  final TextEditingController stockController;
  final RxBool isSelected;

  ImportProductCandidate({
    required String name,
    String unit = 'piece',
    double purchasePrice = 0,
    double sellingPrice = 0,
    double wholesalePrice = 0,
    double stock = 0,
    bool isSelected = true,
  })  : nameController = TextEditingController(text: name),
        unitController = TextEditingController(text: unit),
        purchasePriceController =
            TextEditingController(text: purchasePrice > 0 ? purchasePrice.toString() : '0'),
        sellingPriceController =
            TextEditingController(text: sellingPrice > 0 ? sellingPrice.toString() : '0'),
        wholesalePriceController =
            TextEditingController(text: wholesalePrice > 0 ? wholesalePrice.toString() : '0'),
        stockController =
            TextEditingController(text: stock > 0 ? stock.toString() : '0'),
        isSelected = isSelected.obs;

  void dispose() {
    nameController.dispose();
    unitController.dispose();
    purchasePriceController.dispose();
    sellingPriceController.dispose();
    wholesalePriceController.dispose();
    stockController.dispose();
  }
}

class ProductImportController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final ActiveBusinessService _activeBizService = Get.find<ActiveBusinessService>();
  final _uuid = const Uuid();
  final ImagePicker _picker = ImagePicker();

  Rx<BusinessesData?> get currentBusiness => _activeBizService.activeBusiness;
  final RxList<ImportProductCandidate> candidates = <ImportProductCandidate>[].obs;
  final RxBool isProcessing = false.obs;

  // --- Pick & Import from Excel (.xlsx) ---
  Future<void> importFromExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    if (result == null || result.files.single.path == null) return;

    try {
      isProcessing.value = true;
      final file = File(result.files.single.path!);
      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      final list = <ImportProductCandidate>[];
      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        for (int i = 1; i < sheet.maxRows; i++) {
          final row = sheet.rows[i];
          if (row.isEmpty) continue;

          final name = row.isNotEmpty ? row[0]?.value?.toString().trim() ?? '' : '';
          if (name.isEmpty) continue;

          final unit = row.length > 1 ? row[1]?.value?.toString().trim() ?? 'piece' : 'piece';
          final buy = row.length > 2 ? double.tryParse(row[2]?.value?.toString() ?? '0') ?? 0.0 : 0.0;
          final sell = row.length > 3 ? double.tryParse(row[3]?.value?.toString() ?? '0') ?? 0.0 : 0.0;
          final whole = row.length > 4 ? double.tryParse(row[4]?.value?.toString() ?? '0') ?? 0.0 : 0.0;
          final stock = row.length > 5 ? double.tryParse(row[5]?.value?.toString() ?? '0') ?? 0.0 : 0.0;

          list.add(ImportProductCandidate(
            name: name,
            unit: unit.isNotEmpty ? unit : 'piece',
            purchasePrice: buy,
            sellingPrice: sell,
            wholesalePrice: whole,
            stock: stock,
          ));
        }
      }

      candidates.value = list;
      AppSnackbar.success('${list.length} টি পণ্য প্রিভিউতে আনা হয়েছে');
    } catch (e) {
      AppSnackbar.error('এক্সেল রিড ত্রুটি: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  // --- Pick & Import from CSV ---
  Future<void> importFromCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.single.path == null) return;

    try {
      isProcessing.value = true;
      final file = File(result.files.single.path!);
      final input = file.openRead();
      final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();

      final list = <ImportProductCandidate>[];
      int startIdx = 0;
      if (fields.isNotEmpty && double.tryParse(fields[0].length > 2 ? fields[0][2].toString() : '') == null) {
        startIdx = 1;
      }

      for (int i = startIdx; i < fields.length; i++) {
        final row = fields[i];
        if (row.isEmpty) continue;

        final name = row[0].toString().trim();
        if (name.isEmpty) continue;

        final unit = row.length > 1 ? row[1].toString().trim() : 'piece';
        final buy = row.length > 2 ? double.tryParse(row[2].toString()) ?? 0.0 : 0.0;
        final sell = row.length > 3 ? double.tryParse(row[3].toString()) ?? 0.0 : 0.0;
        final whole = row.length > 4 ? double.tryParse(row[4].toString()) ?? 0.0 : 0.0;
        final stock = row.length > 5 ? double.tryParse(row[5].toString()) ?? 0.0 : 0.0;

        list.add(ImportProductCandidate(
          name: name,
          unit: unit.isNotEmpty ? unit : 'piece',
          purchasePrice: buy,
          sellingPrice: sell,
          wholesalePrice: whole,
          stock: stock,
        ));
      }

      candidates.value = list;
      AppSnackbar.success('${list.length} টি পণ্য সিএসভি থেকে আনা হয়েছে');
    } catch (e) {
      AppSnackbar.error('CSV রিড ত্রুটি: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  // --- Pick & Import from Camera / Gallery via OCR ---
  Future<void> importFromImage({bool fromCamera = false}) async {
    final picked = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (picked == null) return;

    try {
      isProcessing.value = true;
      final inputImage = InputImage.fromFilePath(picked.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final list = <ImportProductCandidate>[];
      for (var block in recognizedText.blocks) {
        for (var line in block.lines) {
          final text = line.text.trim();
          if (text.length < 2) continue;

          final parts = text.split(RegExp(r'\s+'));
          String prodName = text;
          double price = 0.0;

          if (parts.length > 1) {
            final lastPart = parts.last.replaceAll(RegExp(r'[^0-9.]'), '');
            final parsedNum = double.tryParse(lastPart);
            if (parsedNum != null) {
              price = parsedNum;
              prodName = parts.sublist(0, parts.length - 1).join(' ');
            }
          }

          if (prodName.isNotEmpty) {
            list.add(ImportProductCandidate(
              name: prodName,
              sellingPrice: price,
              purchasePrice: price > 0 ? (price * 0.8).roundToDouble() : 0.0,
            ));
          }
        }
      }

      candidates.value = list;
      AppSnackbar.success('${list.length} টি সম্ভাব্য পণ্য ওসিআর দ্বারা শনাক্ত হয়েছে');
    } catch (e) {
      AppSnackbar.error('OCR স্ক্যান ত্রুটি: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  void addManualCandidate() {
    candidates.add(ImportProductCandidate(name: 'নতুন পণ্য'));
  }

  void removeCandidate(ImportProductCandidate item) {
    item.dispose();
    candidates.remove(item);
  }

  Future<bool> saveImportedProducts() async {
    final biz = _activeBizService.activeBusiness.value;
    if (biz == null) {
      AppSnackbar.error('কোন সক্রিয় ব্যবসা নির্বাচন করা নেই');
      return false;
    }

    final selected = candidates.where((c) => c.isSelected.value && c.nameController.text.trim().isNotEmpty).toList();
    if (selected.isEmpty) {
      AppSnackbar.error('সংরক্ষণের জন্য কোন পণ্য নির্বাচন করা হয়নি');
      return false;
    }

    try {
      isProcessing.value = true;
      final bizId = biz.id;
      final now = DateTime.now().millisecondsSinceEpoch;
      final productsList = <ProductsCompanion>[];

      for (var item in selected) {
        final buyMinor = CurrencyUtils.takaToMinor(item.purchasePriceController.text);
        final sellMinor = CurrencyUtils.takaToMinor(item.sellingPriceController.text);
        final wholeMinor = CurrencyUtils.takaToMinor(item.wholesalePriceController.text);
        final stock = double.tryParse(item.stockController.text) ?? 0.0;

        productsList.add(
          ProductsCompanion(
            id: Value(_uuid.v4()),
            businessId: Value(bizId),
            name: Value(item.nameController.text.trim()),
            nameBn: Value(item.nameController.text.trim()),
            unit: Value(item.unitController.text.trim().isNotEmpty ? item.unitController.text.trim() : 'piece'),
            purchasePriceMinor: Value(buyMinor),
            sellingPriceMinor: Value(sellMinor),
            wholesalePriceMinor: Value(wholeMinor),
            openingQuantity: Value(stock),
            minimumStock: const Value(5.0),
            isActive: const Value(1),
            createdAt: Value(now),
          ),
        );
      }

      await _dbService.inventoryDao.batchInsertProducts(productsList);
      AppSnackbar.success('${productsList.length} টি পণ্য সফলভাবে ডেটাবেজে সংরক্ষিত হয়েছে!');

      for (var c in candidates) {
        c.dispose();
      }
      candidates.clear();
      return true;
    } catch (e) {
      AppSnackbar.error('পণ্য সংরক্ষণ ত্রুটি: $e');
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  void onClose() {
    for (var c in candidates) {
      c.dispose();
    }
    super.onClose();
  }
}
