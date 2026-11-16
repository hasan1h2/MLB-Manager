import 'package:get/get.dart';
import '../controllers/household_controller.dart';

class HouseholdBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HouseholdController>(() => HouseholdController());
  }
}
