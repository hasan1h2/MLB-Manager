import 'package:get/get.dart';
import '../../../business/presentation/controllers/business_controller.dart';
import '../../../reports/presentation/controllers/report_controller.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/main_nav_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavController>(() => MainNavController(), fenix: true);
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<TransactionController>(() => TransactionController(), fenix: true);
    Get.lazyPut<BusinessController>(() => BusinessController(), fenix: true);
    Get.lazyPut<ReportController>(() => ReportController(), fenix: true);
  }
}
