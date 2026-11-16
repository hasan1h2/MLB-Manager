import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/database_service.dart';
import 'package:mlb_manager/shared/widgets/app_snackbar.dart';

class FamilyController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final _uuid = const Uuid();

  final RxList<FamilyMember> members = <FamilyMember>[].obs;
  final RxBool isLoading = true.obs;

  // Form fields
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final relationshipController = TextEditingController();
  final RxString selectedRole = 'member'.obs; // owner, admin, member, viewer

  @override
  void onInit() {
    super.onInit();
    watchMembers();
  }

  void watchMembers() {
    _dbService.coreDao.watchFamilyMembers().listen((list) {
      members.value = list;
      isLoading.value = false;
    });
  }

  Future<bool> saveMember() async {
    if (nameController.text.trim().isEmpty) {
      AppSnackbar.error('নাম লিখুন');
      return false;
    }

    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await _dbService.coreDao.insertFamilyMember(
        FamilyMembersCompanion(
          id: Value(_uuid.v4()),
          name: Value(nameController.text.trim()),
          phone: Value(phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null),
          relationship: Value(relationshipController.text.trim().isNotEmpty ? relationshipController.text.trim() : null),
          role: Value(selectedRole.value),
          isActive: const Value(1),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      AppSnackbar.success('সদস্য সফলভাবে যোগ করা হয়েছে');
      nameController.clear();
      phoneController.clear();
      relationshipController.clear();
      return true;
    } catch (e) {
      AppSnackbar.error('Error: $e');
      return false;
    }
  }

  Future<void> deactivateMember(FamilyMember member) async {
    final updated = member.copyWith(isActive: 0, updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch);
    await _dbService.coreDao.updateFamilyMember(updated);
    AppSnackbar.info('সদস্য নিষ্ক্রিয় করা হয়েছে');
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    relationshipController.dispose();
    super.onClose();
  }
}
