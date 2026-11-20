import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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

    test(
        'Adding products to cart displays correctly with name, unit, qty, price, and subtotal',
        () {
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

    test(
        'Increment and decrement quantity dynamically recalculates subtotal and cart total',
        () {
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

    test(
        'Removing an item from cart updates the cart list and total bill correctly',
        () {
      controller.addToCart(
          name: 'ডিম',
          quantity: 12.0,
          unit: 'piece',
          unitPriceMinor: 1200); // 144 Taka = 14400 Poisha
      controller.addToCart(
          name: 'দুধ',
          quantity: 1.0,
          unit: 'liter',
          unitPriceMinor: 9000); // 90 Taka = 9000 Poisha

      expect(controller.cartItems.length, equals(2));
      expect(controller.subtotalMinor, equals(23400));

      // Remove eggs (index 0)
      controller.removeCartItem(0);
      expect(controller.cartItems.length, equals(1));
      expect(controller.cartItems.first.productName, equals('দুধ'));
      expect(controller.subtotalMinor, equals(9000));
      expect(controller.totalBillMinor, equals(9000));
    });

    test(
        'Discount and paid amount calculation updates net payable and remaining due',
        () {
      controller.addToCart(
          name: 'মাংস',
          quantity: 1.0,
          unit: 'kg',
          unitPriceMinor: 75000); // 750 Taka

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

    test('Allows saving item without per-unit price using direct line total',
        () {
      // User buys 1 bunch of vegetables for 60 Taka without entering per-unit rate
      controller.addToCart(
        name: 'মিক্স সবজি',
        quantity: 1.0,
        unit: 'none',
        unitPriceMinor: 0,
        lineTotalMinor: 6000,
        note: 'বাজারের তাজা সবজি',
      );

      expect(controller.cartItems.length, equals(1));
      final item = controller.cartItems.first;
      expect(item.productName, equals('মিক্স সবজি'));
      expect(item.unitPriceMinor.value, equals(0)); // Unit price is 0/optional
      expect(item.lineTotalMinor.value, equals(6000)); // Line total is 60 Taka
      expect(item.subtotalMinor, equals(6000));
      expect(item.note.value, equals('বাজারের তাজা সবজি'));
      expect(controller.subtotalMinor, equals(6000));
      expect(controller.totalBillMinor, equals(6000));
    });

    test(
        'Direct Total Mode calculates total bill from directAmountController without items',
        () {
      controller.entryMode.value = 'direct_total';
      controller.directAmountController.text = '250'; // 250 Taka = 25000 Poisha

      expect(controller.subtotalMinor, equals(25000));
      expect(controller.totalBillMinor, equals(25000));
      expect(controller.cartPaidMinor, equals(25000));
      expect(controller.cartDueMinor, equals(0));
    });

    test('Purchase time formatting handles optional time properly', () {
      expect(controller.formatShoppingTime(null), isNull);
      // 10:30 AM
      expect(
          controller.formatShoppingTime(const TimeOfDay(hour: 10, minute: 30)),
          equals('10:30 AM'));
      // 16:45 -> 4:45 PM
      expect(
          controller.formatShoppingTime(const TimeOfDay(hour: 16, minute: 45)),
          equals('4:45 PM'));
    });

    test('ProductSummaryItem computes average price correctly', () {
      final summary = ProductSummaryItem(
        productName: 'চাল',
        unit: 'kg',
        totalQuantity: 10.0,
        totalAmountMinor: 70000, // 700 Taka
        purchaseCount: 3,
      );

      expect(summary.productName, equals('চাল'));
      expect(summary.totalQuantity, equals(10.0));
      expect(summary.totalAmountMinor, equals(70000));
      expect(summary.avgPriceMinor, equals(7000)); // 70 Taka/kg
    });

    test('Filtered shopping records matches search queries accurately', () {
      controller.searchQuery.value = 'তেল';
      expect(controller.searchQuery.value, equals('তেল'));
      controller.searchQuery.value = '';
      expect(controller.searchQuery.value, isEmpty);
    });
  });
}
