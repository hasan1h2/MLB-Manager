import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../database/app_database.dart';
import 'database_service.dart';
import 'storage_service.dart';

class ActiveBusinessService extends GetxService {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final StorageService _storageService = Get.find<StorageService>();

  static const String _storageKey = 'active_business_id';

  final Rx<BusinessesData?> activeBusiness = Rx<BusinessesData?>(null);
  final RxList<BusinessesData> allBusinesses = <BusinessesData>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<List<BusinessesData>>? _businessSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadBusinesses();
    _subscribeBusinesses();
  }

  Future<ActiveBusinessService> init() async {
    await _loadBusinesses();
    _subscribeBusinesses();
    return this;
  }

  Future<void> _loadBusinesses() async {
    try {
      final list = await _dbService.businessDao.getAllBusinesses();
      allBusinesses.value = list;

      final savedId = _storageService.getString(_storageKey);
      if (savedId != null && list.any((b) => b.id == savedId)) {
        activeBusiness.value = list.firstWhere((b) => b.id == savedId);
      } else if (list.isNotEmpty) {
        activeBusiness.value = list.first;
        await _storageService.setString(_storageKey, list.first.id);
      } else {
        activeBusiness.value = null;
      }
    } catch (e) {
      debugPrint('ActiveBusinessService error loading businesses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _subscribeBusinesses() {
    _businessSubscription?.cancel();
    _businessSubscription = _dbService.businessDao.watchBusinesses().listen((list) {
      allBusinesses.value = list;
      if (list.isEmpty) {
        activeBusiness.value = null;
        return;
      }

      final current = activeBusiness.value;
      if (current != null) {
        final updated = list.firstWhereOrNull((b) => b.id == current.id);
        if (updated != null) {
          activeBusiness.value = updated;
          return;
        }
      }

      // If active business was deleted or not set, restore or fallback
      final savedId = _storageService.getString(_storageKey);
      if (savedId != null && list.any((b) => b.id == savedId)) {
        activeBusiness.value = list.firstWhere((b) => b.id == savedId);
      } else {
        activeBusiness.value = list.first;
        _storageService.setString(_storageKey, list.first.id);
      }
    });
  }

  String? get activeBusinessId => activeBusiness.value?.id;

  Future<void> switchBusiness(BusinessesData business) async {
    activeBusiness.value = business;
    await _storageService.setString(_storageKey, business.id);
  }

  Future<void> switchBusinessById(String businessId) async {
    final b = allBusinesses.firstWhereOrNull((b) => b.id == businessId);
    if (b != null) {
      await switchBusiness(b);
    }
  }

  @override
  void onClose() {
    _businessSubscription?.cancel();
    super.onClose();
  }
}
