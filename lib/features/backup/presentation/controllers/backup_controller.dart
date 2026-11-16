import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/database_service.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class BackupController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final RxBool isOperating = false.obs;
  final RxString lastBackupPath = ''.obs;

  Future<void> createJsonBackup() async {
    try {
      isOperating.value = true;
      final db = _dbService.database;

      final accounts = await db.select(db.accounts).get();
      final categories = await db.select(db.categories).get();
      final members = await db.select(db.familyMembers).get();
      final businesses = await db.select(db.businesses).get();
      final transactions = await db.select(db.transactions).get();
      final shopping = await db.select(db.shoppingRecords).get();

      final backupData = {
        'version': AppConstants.appVersion,
        'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
        'accounts': accounts.map((a) => a.toJson()).toList(),
        'categories': categories.map((c) => c.toJson()).toList(),
        'members': members.map((m) => m.toJson()).toList(),
        'businesses': businesses.map((b) => b.toJson()).toList(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'shopping': shopping.map((s) => s.toJson()).toList(),
      };

      final jsonStr = jsonEncode(backupData);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/mlb_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonStr);

      lastBackupPath.value = file.path;
      AppSnackbar.success('ব্যাকআপ সফলভাবে সম্পন্ন হয়েছে: ${file.path}');
    } catch (e) {
      AppSnackbar.error('ব্যাকআপ তৈরি করতে ত্রুটি: $e');
    } finally {
      isOperating.value = false;
    }
  }

  Future<void> restoreBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        isOperating.value = true;
        final file = File(result.files.single.path!);
        final jsonStr = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(jsonStr);

        // Validation
        if (!data.containsKey('version') || !data.containsKey('transactions')) {
          AppSnackbar.error('অবৈধ ব্যাকআপ ফাইল ফরম্যাট!');
          return;
        }

        // Successfully validated
        AppSnackbar.success('ব্যাকআপ ফাইল সফলভাবে যাচাই করা হয়েছে');
      }
    } catch (e) {
      AppSnackbar.error('রিস্টোর করতে সমস্যা হয়েছে: $e');
    } finally {
      isOperating.value = false;
    }
  }
}
