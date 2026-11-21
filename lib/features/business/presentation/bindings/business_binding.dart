import 'package:get/get.dart';
import '../controllers/business_controller.dart';
import '../controllers/business_purchase_controller.dart';
import '../controllers/business_sale_controller.dart';
import '../controllers/cashbook_controller.dart';
import '../controllers/product_import_controller.dart';

class BusinessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessController>(() => BusinessController());
    Get.lazyPut<BusinessSaleController>(() => BusinessSaleController());
    Get.lazyPut<BusinessPurchaseController>(() => BusinessPurchaseController());
    Get.lazyPut<CashbookController>(() => CashbookController());
    Get.lazyPut<ProductImportController>(() => ProductImportController());
  }
}
