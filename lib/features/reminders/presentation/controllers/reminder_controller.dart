import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class ReminderController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  final RxList<Reminder> reminders = <Reminder>[].obs;
  final RxBool isLoading = true.obs;

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final RxString selectedType = 'bill_payment'.obs;
  final Rx<DateTime> scheduledDate = DateTime.now().add(const Duration(days: 3)).obs;

  @override
  void onInit() {
    super.onInit();
    watchReminders();
  }

  void watchReminders() {
    _dbService.budgetDao.watchReminders(pendingOnly: false).listen((list) {
      reminders.value = list;
      isLoading.value = false;
    });
  }

  Future<bool> saveReminder() async {
    if (titleController.text.trim().isEmpty) return false;
    final scheduledMs = scheduledDate.value.toUtc().millisecondsSinceEpoch;

    await _dbService.budgetDao.insertReminder(
      RemindersCompanion(
        id: Value(_uuid.v4()),
        title: Value(titleController.text.trim()),
        description: Value(descController.text.trim()),
        reminderType: Value(selectedType.value),
        scheduledAt: Value(scheduledMs),
        isCompleted: const Value(0),
        notificationEnabled: const Value(1),
      ),
    );

    titleController.clear();
    descController.clear();
    AppSnackbar.success('রিমাইন্ডার সফলভাবে সংরক্ষিত হয়েছে');
    return true;
  }

  Future<void> markCompleted(String id) async {
    await _dbService.budgetDao.markReminderCompleted(id);
  }

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    super.onClose();
  }
}
