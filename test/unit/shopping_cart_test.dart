import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mlb_manager/core/database/app_database.dart';
import 'package:mlb_manager/core/security/pin_service.dart';
import 'package:mlb_manager/core/services/database_service.dart';
import 'package:mlb_manager/core/services/storage_service.dart';
import 'package:mlb_manager/features/household/presentation/controllers/household_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DatabaseService dbService;
  late HouseholdController controller;

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService().init();
    Get.put<StorageService>(storageService, permanent: true);

    final pinService = PinService();
    Get.put<PinService>(pinService, permanent: true);

    db = AppDatabase.forTesting(NativeDatabase.memory());
    dbService = await DatabaseService().init(customDb: db);
    Get.put<DatabaseService>(dbService, permanent: true);

    controller = HouseholdController();
  });

  tearDown(() async {
    await db.close();
    Get.reset();
  });

  group('Shopping Cart Reactive Logic & Math Rules', () {
    test('Cart starts empty with zero subtotal and total', () {
      expect(controller.cartItems.isEmpty, isTrue);
      expect(controller.subtotalMinor, equals(0));
      expect(controller.totalBillMinor, equals(0));
    });

    test('Adding products to cart displays correctly with name, unit, qty, price, and subtotal', () {
      // 2 kg rice at 70 Taka/kg = 140 Taka (14,000 Poisha)
      controller.addToCart(
        name: 'বাসমতি চাল',
        quantity: 2.0,
        unit: 'kg',
        unitPriceMinor: 7000,
      );

      expect(controller.cartItems.length, equals(1));
      final item1 = controller.cartItems.first;
      expect(item1.productName, equals('বাসমতি চাল'));
      expect(item1.quantity.value, equals(2.0));
      expect(item1.unit, equals('kg'));
      expect(item1.unitPriceMinor.value, equals(7000));
      expect(item1.subtotalMinor, equals(14000));
      expect(controller.subtotalMinor, equals(14000));
      expect(controller.totalBillMinor, equals(14000));

      // Add second item: 1 liter soybean oil at 180 Taka = 18,000 Poisha
      controller.addToCart(
        name: 'সয়াবিন তেল',
        quantity: 1.0,
        unit: 'liter',
        unitPriceMinor: 18000,
      );

      expect(controller.cartItems.length, equals(2));
      expect(controller.cartItems[1].subtotalMinor, equals(18000));
      // Total = 14,000 + 18,000 = 32,000 Poisha (320 Taka)
      expect(controller.subtotalMinor, equals(32000));
      expect(controller.totalBillMinor, equals(32000));
    });

    test('Increment and decrement quantity dynamically recalculates subtotal and cart total', () {
      controller.addToCart(
        name: 'আলু',
        quantity: 1.0,
        unit: 'kg',
        unitPriceMinor: 5000, // 50 Taka
      );

      expect(controller.subtotalMinor, equals(5000));

      // Increment by 1 -> 2 kg = 100 Taka
      controller.incrementQuantity(0);
      expect(controller.cartItems[0].quantity.value, equals(2.0));
      expect(controller.cartItems[0].subtotalMinor, equals(10000));
      expect(controller.subtotalMinor, equals(10000));

      // Increment again -> 3 kg = 150 Taka
      controller.incrementQuantity(0);
      expect(controller.cartItems[0].quantity.value, equals(3.0));
      expect(controller.cartItems[0].subtotalMinor, equals(15000));
      expect(controller.subtotalMinor, equals(15000));

      // Decrement by 1 -> 2 kg = 100 Taka
      controller.decrementQuantity(0);
      expect(controller.cartItems[0].quantity.value, equals(2.0));
      expect(controller.cartItems[0].subtotalMinor, equals(10000));
      expect(controller.subtotalMinor, equals(10000));
    });

    test('Removing an item from cart updates the cart list and total bill correctly', () {
      controller.addToCart(name: 'ডিম', quantity: 12.0, unit: 'piece', unitPriceMinor: 1200); // 144 Taka = 14400 Poisha
      controller.addToCart(name: 'দুধ', quantity: 1.0, unit: 'liter', unitPriceMinor: 9000);   // 90 Taka = 9000 Poisha

      expect(controller.cartItems.length, equals(2));
      expect(controller.subtotalMinor, equals(23400));

      // Remove eggs (index 0)
      controller.removeCartItem(0);
      expect(controller.cartItems.length, equals(1));
      expect(controller.cartItems.first.productName, equals('দুধ'));
      expect(controller.subtotalMinor, equals(9000));
      expect(controller.totalBillMinor, equals(9000));
    });

    test('Discount and paid amount calculation updates net payable and remaining due', () {
      controller.addToCart(name: 'মাংস', quantity: 1.0, unit: 'kg', unitPriceMinor: 75000); // 750 Taka

      expect(controller.subtotalMinor, equals(75000));

      // Apply 50 Taka discount (5000 Poisha)
      controller.discountController.text = '50';
      expect(controller.discountMinor, equals(5000));
      expect(controller.totalBillMinor, equals(70000)); // 700 Taka net

      // Paid 500 Taka (50000 Poisha)
      controller.paidController.text = '500';
      expect(controller.cartPaidMinor, equals(50000));
      expect(controller.cartDueMinor, equals(20000)); // 200 Taka due
    });
  });
}
