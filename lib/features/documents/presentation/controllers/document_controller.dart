import 'dart:io';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart' hide Value;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class DocumentController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  final RxList<Attachment> attachments = <Attachment>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    watchAttachments();
  }

  void watchAttachments() {
    _dbService.database.select(_dbService.database.attachments).watch().listen((list) {
      attachments.value = list;
      isLoading.value = false;
    });
  }

  Future<void> pickAndSaveDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final appDir = await getApplicationDocumentsDirectory();
        final docDir = Directory('${appDir.path}/documents');
        if (!docDir.existsSync()) {
          docDir.createSync(recursive: true);
        }

        final fileName = result.files.single.name;
        final savedFile = await file.copy('${docDir.path}/${_uuid.v4()}_$fileName');
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;

        await _dbService.database.into(_dbService.database.attachments).insert(
              AttachmentsCompanion(
                id: Value(_uuid.v4()),
                fileName: Value(fileName),
                filePath: Value(savedFile.path),
                fileSize: Value(result.files.single.size),
                createdAt: Value(now),
              ),
            );

        AppSnackbar.success('ডকুমেন্ট সফলভাবে সংরক্ষিত হয়েছে');
      }
    } catch (e) {
      AppSnackbar.error('ডকুমেন্ট যোগ করতে ব্যর্থ: $e');
    }
  }
}
