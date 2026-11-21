import 'package:get/get.dart';
import '../../core/security/pin_service.dart';
import '../../core/services/active_business_service.dart';
import '../../core/services/database_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme_controller.dart';
import '../../features/business/presentation/controllers/business_controller.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/dashboard/presentation/controllers/main_nav_controller.dart';
import '../../features/reports/presentation/controllers/report_controller.dart';
import '../../features/transactions/presentation/controllers/transaction_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StorageService>()) {
      Get.put<StorageService>(StorageService(), permanent: true);
    }
    if (!Get.isRegistered<PinService>()) {
      Get.put<PinService>(PinService(), permanent: true);
    }
    if (!Get.isRegistered<DatabaseService>()) {
      Get.put<DatabaseService>(DatabaseService(), permanent: true);
    }
    if (!Get.isRegistered<ActiveBusinessService>()) {
      Get.put<ActiveBusinessService>(ActiveBusinessService(), permanent: true);
    }
    if (!Get.isRegistered<AppThemeController>()) {
      Get.put<AppThemeController>(AppThemeController(), permanent: true);
    }

    // Lazy put main tab controllers with fenix: true
    Get.lazyPut<MainNavController>(() => MainNavController(), fenix: true);
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<TransactionController>(() => TransactionController(),
        fenix: true);
    Get.lazyPut<BusinessController>(() => BusinessController(), fenix: true);
    Get.lazyPut<ReportController>(() => ReportController(), fenix: true);
  }
}
