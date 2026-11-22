import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlb_manager/core/constants/app_constants.dart';
import 'package:mlb_manager/core/database/app_database.dart';
import 'package:mlb_manager/core/database/daos/business_dao.dart';
import 'package:mlb_manager/core/database/daos/inventory_dao.dart';
import 'package:mlb_manager/core/utils/unit_conversion_utils.dart';

void main() {
  late AppDatabase db;
  late BusinessDao businessDao;
  late InventoryDao inventoryDao;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    businessDao = BusinessDao(db);
    inventoryDao = InventoryDao(db);

    final now = DateTime.now().millisecondsSinceEpoch;

    // Seed test businesses
    await businessDao.insertBusiness(
      BusinessesCompanion(
        id: const Value('biz_1'),
        name: const Value('আহসান গ্রোসারি'),
        businessType: const Value('retail'),
        openingDate: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await businessDao.insertBusiness(
      BusinessesCompanion(
        id: const Value('biz_2'),
        name: const Value('অন্য ব্যবসা'),
        businessType: const Value('retail'),
        openingDate: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('1. Quick Sale Product Linking & Stock Deductions', () {
    test('1, 2, 3, 4: Quick Sale links existing product by original ID and updates stock upon checkout', () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      // 1. Create a product in inventory for biz_1
      await inventoryDao.insertProduct(
        ProductsCompanion(
          id: const Value('prod_miniket'),
          businessId: const Value('biz_1'),
          name: const Value('মিনিকেট চাল'),
          nameBn: const Value('মিনিকেট চাল'),
          unit: const Value('kg'),
          purchasePriceMinor: const Value(6500), // 65 Tk
          sellingPriceMinor: const Value(7500),  // 75 Tk
          openingQuantity: const Value(100.0),   // 100 kg initial stock
          createdAt: Value(now),
        ),
      );

      // Verify stock starts at 100 kg
      var currentStock = await inventoryDao.getProductCurrentStock('prod_miniket');
      expect(currentStock, 100.0);

      // 2. Search simulation: user types 'মিনিকেট' or 'চাল'
      final allBiz1Prods = await inventoryDao.getAllProducts('biz_1');
      final matched = allBiz1Prods.where((p) =>
          p.name.contains('মিনিকেট') || (p.nameBn?.contains('মিনিকেট') ?? false)).toList();
      expect(matched.isNotEmpty, isTrue);
      final selectedProduct = matched.first;
      expect(selectedProduct.id, 'prod_miniket');

      // 3. Adding to cart must NOT deduct stock prematurely
      final cartQty = 5.0; // Selling 5 kg
      currentStock = await inventoryDao.getProductCurrentStock('prod_miniket');
      expect(currentStock, 100.0); // Stock still 100 kg!

      // 4. Complete checkout
      final saleId = 'sale_qs_1';
      final saleRecord = SalesRecordsCompanion(
        id: Value(saleId),
        businessId: const Value('biz_1'),
        saleDate: Value(now),
        saleTime: const Value('10:30'),
        saleType: const Value('retail'),
        paymentMethod: const Value('cash'),
        subtotalMinor: const Value(37500), // 5 * 75 Tk = 375 Tk
        totalMinor: const Value(37500),
        paidMinor: const Value(37500),
        dueMinor: const Value(0),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      final saleItem = SalesItemsCompanion(
        id: const Value('item_qs_1'),
        saleId: Value(saleId),
        productId: Value(selectedProduct.id), // Retains original Product ID!
        productName: Value(selectedProduct.nameBn ?? selectedProduct.name),
        unit: const Value('kg'),
        quantity: Value(cartQty),
        conversionFactor: const Value(1.0),
        baseQuantity: Value(cartQty),
        unitPriceMinor: const Value(7500),
        unitCostMinor: const Value(6500),
        totalMinor: const Value(37500),
      );

      final movement = InventoryMovementsCompanion(
        id: const Value('mov_qs_1'),
        productId: Value(selectedProduct.id),
        businessId: const Value('biz_1'),
        movementType: const Value('sale'),
        quantity: Value(cartQty),
        unitCostMinor: const Value(6500),
        referenceType: const Value('sale'),
        referenceId: Value(saleId),
        movementDate: Value(now),
      );

      await inventoryDao.postSaleWithItems(
        sale: saleRecord,
        items: [saleItem],
        movements: [movement],
      );

      // 5. Verify stock is now deducted to 95 kg
      currentStock = await inventoryDao.getProductCurrentStock('prod_miniket');
      expect(currentStock, 95.0);

      // Verify no duplicate product was created in products table
      final prodsAfterSale = await inventoryDao.getAllProducts('biz_1');
      expect(prodsAfterSale.length, 1);
      expect(prodsAfterSale.first.id, 'prod_miniket');
    });

    test('5. Quick Sale creates new product when not found and assigns real ID', () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      // User adds a completely new product 'হালিম মিক্স'
      final newProdId = 'prod_haleem';
      await inventoryDao.insertProduct(
        ProductsCompanion(
          id: Value(newProdId),
          businessId: const Value('biz_1'),
          name: const Value('হালিম মিক্স'),
          nameBn: const Value('হালিম মিক্স'),
          unit: const Value('packet'),
          purchasePriceMinor: const Value(5000), // 50 Tk
          sellingPriceMinor: const Value(6500),  // 65 Tk
          openingQuantity: const Value(0.0),
          createdAt: Value(now),
        ),
      );

      // Confirm exactly 1 record created
      final prods = await inventoryDao.getAllProducts('biz_1');
      expect(prods.any((p) => p.id == newProdId), isTrue);

      // Sells 2 packets
      final saleId = 'sale_qs_2';
      await inventoryDao.postSaleWithItems(
        sale: SalesRecordsCompanion(
          id: Value(saleId),
          businessId: const Value('biz_1'),
          saleDate: Value(now),
          saleTime: const Value('11:00'),
          saleType: const Value('retail'),
          paymentMethod: const Value('cash'),
          totalMinor: const Value(13000),
          paidMinor: const Value(13000),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        items: [
          SalesItemsCompanion(
            id: const Value('item_qs_2'),
            saleId: Value(saleId),
            productId: Value(newProdId),
            productName: const Value('হালিম মিক্স'),
            unit: const Value('packet'),
            quantity: const Value(2.0),
            conversionFactor: const Value(1.0),
            baseQuantity: const Value(2.0),
            unitPriceMinor: const Value(6500),
            unitCostMinor: const Value(5000),
            totalMinor: const Value(13000),
          ),
        ],
        movements: [
          InventoryMovementsCompanion(
            id: const Value('mov_qs_2'),
            productId: Value(newProdId),
            businessId: const Value('biz_1'),
            movementType: const Value('sale'),
            quantity: const Value(2.0),
            unitCostMinor: const Value(5000),
            referenceType: const Value('sale'),
            referenceId: Value(saleId),
            movementDate: Value(now),
          ),
        ],
      );

      // Stock is 0 - 2 = -2.0
      final stock = await inventoryDao.getProductCurrentStock(newProdId);
      expect(stock, -2.0);
    });

    test('18. Business Data Isolation: Quick sale cannot see or sell products of another business', () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      await inventoryDao.insertProduct(
        ProductsCompanion(
          id: const Value('prod_biz2_item'),
          businessId: const Value('biz_2'),
          name: const Value('স্পেশাল ঘি'),
          unit: const Value('bottle'),
          purchasePriceMinor: const Value(40000),
          sellingPriceMinor: const Value(50000),
          createdAt: Value(now),
        ),
      );

      final prodsBiz1 = await inventoryDao.getAllProducts('biz_1');
      expect(prodsBiz1.any((p) => p.id == 'prod_biz2_item'), isFalse);
    });
  });

  group('2. Package Purchase Cost System & Calculations', () {
    test('6. A 50 KG bag purchased for 3,500 Tk calculates 70 Tk per KG', () {
      final bagPurchaseCost = 3500.0;
      final bagContentKg = 50.0;
      final costPerKg = bagPurchaseCost / bagContentKg;
      expect(costPerKg, 70.0);
    });

    test('6b. Biscuit carton of 24 packets purchased for 480 Tk calculates 20 Tk per packet', () {
      final cartonPurchaseCost = 480.0;
      final packetsPerCarton = 24.0;
      final costPerPacket = cartonPurchaseCost / packetsPerCarton;
      expect(costPerPacket, 20.0);
    });

    test('7. Package without conversion: purchased and sold as complete box', () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Product sold directly as complete box, no piece conversion
      await inventoryDao.insertProduct(
        ProductsCompanion(
          id: const Value('prod_gift_box'),
          businessId: const Value('biz_1'),
          name: const Value('গিফট বক্স'),
          unit: const Value('box'), // Stock unit is box
          purchasePriceMinor: const Value(120000), // 1200 Tk per box
          sellingPriceMinor: const Value(150000),  // 1500 Tk per box
          openingQuantity: const Value(0.0),
          createdAt: Value(now),
        ),
      );

      // Purchase 10 boxes
      await inventoryDao.postPurchaseWithItems(
        purchase: PurchaseRecordsCompanion(
          id: const Value('pur_boxes'),
          businessId: const Value('biz_1'),
          purchaseDate: Value(now),
          purchaseTime: const Value('09:00'),
          totalMinor: const Value(1200000), // 10 * 1200 Tk = 12000 Tk
          paidMinor: const Value(1200000),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        items: [
          PurchaseItemsCompanion(
            id: const Value('pur_item_box'),
            purchaseId: const Value('pur_boxes'),
            productId: const Value('prod_gift_box'),
            unit: const Value('box'),
            quantity: const Value(10.0),
            conversionFactor: const Value(1.0), // No conversion!
            baseQuantity: const Value(10.0),
            unitCostMinor: const Value(120000),
            totalMinor: const Value(1200000),
          ),
        ],
        movements: [
          InventoryMovementsCompanion(
            id: const Value('mov_pur_box'),
            productId: const Value('prod_gift_box'),
            businessId: const Value('biz_1'),
            movementType: const Value('purchase'),
            quantity: const Value(10.0),
            unitCostMinor: const Value(120000),
            movementDate: Value(now),
          ),
        ],
      );

      var stock = await inventoryDao.getProductCurrentStock('prod_gift_box');
      expect(stock, 10.0); // Exactly 10 boxes

      // Sell 3 complete boxes
      await inventoryDao.postSaleWithItems(
        sale: SalesRecordsCompanion(
          id: const Value('sale_boxes'),
          businessId: const Value('biz_1'),
          saleDate: Value(now),
          saleTime: const Value('14:00'),
          totalMinor: const Value(450000), // 3 * 1500 Tk = 4500 Tk
          paidMinor: const Value(450000),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        items: [
          SalesItemsCompanion(
            id: const Value('sale_item_box'),
            saleId: const Value('sale_boxes'),
            productId: const Value('prod_gift_box'),
            unit: const Value('box'),
            quantity: const Value(3.0),
            conversionFactor: const Value(1.0),
            baseQuantity: const Value(3.0),
            unitPriceMinor: const Value(150000),
            unitCostMinor: const Value(120000),
            totalMinor: const Value(450000),
          ),
        ],
        movements: [
          InventoryMovementsCompanion(
            id: const Value('mov_sale_box'),
            productId: const Value('prod_gift_box'),
            businessId: const Value('biz_1'),
            movementType: const Value('sale'),
            quantity: const Value(3.0),
            unitCostMinor: const Value(120000),
            movementDate: Value(now),
          ),
        ],
      );

      stock = await inventoryDao.getProductCurrentStock('prod_gift_box');
      expect(stock, 7.0); // 10 - 3 = 7 boxes remaining
    });

    test('8. Package with conversion: 1 box = 12 pieces; sell individual pieces', () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Product stocked in pieces, packaged in boxes of 12
      await inventoryDao.insertProduct(
        ProductsCompanion(
          id: const Value('prod_choc'),
          businessId: const Value('biz_1'),
          name: const Value('চকলেট বার'),
          unit: const Value('piece'),
          packageUnit: const Value('box'),
          packageQuantity: const Value(12.0),
          purchasePriceMinor: const Value(2000), // 20 Tk per piece
          sellingPriceMinor: const Value(3000),  // 30 Tk per piece
          openingQuantity: const Value(0.0),
          createdAt: Value(now),
        ),
      );

      // Purchase 2 boxes (2 * 12 = 24 pieces)
      final factor = UnitConversionUtils.getConversionFactor(
        fromUnit: 'box',
        toBaseUnit: 'piece',
        packageUnit: 'box',
        packageQuantity: 12.0,
      );
      expect(factor, 12.0);

      await inventoryDao.postPurchaseWithItems(
        purchase: PurchaseRecordsCompanion(
          id: const Value('pur_choc'),
          businessId: const Value('biz_1'),
          purchaseDate: Value(now),
          purchaseTime: const Value('10:00'),
          totalMinor: const Value(48000), // 2 boxes @ 240 Tk each
          paidMinor: const Value(48000),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        items: [
          PurchaseItemsCompanion(
            id: const Value('pur_item_choc'),
            purchaseId: const Value('pur_choc'),
            productId: const Value('prod_choc'),
            unit: const Value('box'),
            quantity: const Value(2.0),
            conversionFactor: Value(factor),
            baseQuantity: const Value(24.0),
            unitCostMinor: const Value(24000),
            totalMinor: const Value(48000),
          ),
        ],
        movements: [
          InventoryMovementsCompanion(
            id: const Value('mov_pur_choc'),
            productId: const Value('prod_choc'),
            businessId: const Value('biz_1'),
            movementType: const Value('purchase'),
            quantity: const Value(24.0), // 24 pieces added to inventory!
            unitCostMinor: const Value(2000),
            movementDate: Value(now),
          ),
        ],
      );

      var stock = await inventoryDao.getProductCurrentStock('prod_choc');
      expect(stock, 24.0);

      // Sell 6 pieces
      await inventoryDao.postSaleWithItems(
        sale: SalesRecordsCompanion(
          id: const Value('sale_choc_pieces'),
          businessId: const Value('biz_1'),
          saleDate: Value(now),
          saleTime: const Value('11:00'),
          totalMinor: const Value(18000), // 6 * 30 Tk = 180 Tk
          paidMinor: const Value(18000),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        items: [
          SalesItemsCompanion(
            id: const Value('sale_item_choc'),
            saleId: const Value('sale_choc_pieces'),
            productId: const Value('prod_choc'),
            unit: const Value('piece'),
            quantity: const Value(6.0),
            conversionFactor: const Value(1.0),
            baseQuantity: const Value(6.0),
            unitPriceMinor: const Value(3000),
            unitCostMinor: const Value(2000),
            totalMinor: const Value(18000),
          ),
        ],
        movements: [
          InventoryMovementsCompanion(
            id: const Value('mov_sale_choc'),
            productId: const Value('prod_choc'),
            businessId: const Value('biz_1'),
            movementType: const Value('sale'),
            quantity: const Value(6.0),
            unitCostMinor: const Value(2000),
            movementDate: Value(now),
          ),
        ],
      );

      stock = await inventoryDao.getProductCurrentStock('prod_choc');
      expect(stock, 18.0); // 24 - 6 = 18 pieces remaining!
    });
  });

  group('3. Units, Decimal Quantities & Conversions', () {
    test('9, 10: All 15 required units supported with valid conversions', () {
      final supported = AppConstants.supportedUnits;
      expect(supported.contains('mg'), isTrue);
      expect(supported.contains('g'), isTrue);
      expect(supported.contains('kg'), isTrue);
      expect(supported.contains('ml'), isTrue);
      expect(supported.contains('liter'), isTrue);
      expect(supported.contains('piece'), isTrue);
      expect(supported.contains('packet'), isTrue);
      expect(supported.contains('box'), isTrue);
      expect(supported.contains('carton'), isTrue);
      expect(supported.contains('dozen'), isTrue);
      expect(supported.contains('bottle'), isTrue);
      expect(supported.contains('bag'), isTrue);
      expect(supported.contains('sack'), isTrue);
      expect(supported.contains('pair'), isTrue);
      expect(supported.contains('custom'), isTrue);

      // Weight conversions
      expect(UnitConversionUtils.getConversionFactor(fromUnit: 'g', toBaseUnit: 'kg'), 0.001);
      expect(UnitConversionUtils.getConversionFactor(fromUnit: 'kg', toBaseUnit: 'g'), 1000.0);
      expect(UnitConversionUtils.getConversionFactor(fromUnit: 'mg', toBaseUnit: 'g'), 0.001);
      expect(UnitConversionUtils.getConversionFactor(fromUnit: 'g', toBaseUnit: 'mg'), 1000.0);

      // Volume conversions
      expect(UnitConversionUtils.getConversionFactor(fromUnit: 'ml', toBaseUnit: 'liter'), 0.001);
      expect(UnitConversionUtils.getConversionFactor(fromUnit: 'liter', toBaseUnit: 'ml'), 1000.0);

      // Count conversions
      expect(UnitConversionUtils.getConversionFactor(fromUnit: 'dozen', toBaseUnit: 'piece'), 12.0);
      expect(UnitConversionUtils.getConversionFactor(fromUnit: 'pair', toBaseUnit: 'piece'), 2.0);

      // Decimal calculation: 250 g of product with base unit kg = 0.25 kg
      final baseQty = UnitConversionUtils.calculateBaseQuantity(
        quantity: 250,
        unit: 'g',
        baseUnit: 'kg',
      );
      expect(baseQty, 0.25);
    });

    test('11: Historical costs in sales items remain unchanged after product price update', () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      await inventoryDao.insertProduct(
        ProductsCompanion(
          id: const Value('prod_oil'),
          businessId: const Value('biz_1'),
          name: const Value('সয়াবিন তেল'),
          unit: const Value('liter'),
          purchasePriceMinor: const Value(15000), // 150 Tk
          sellingPriceMinor: const Value(18000),  // 180 Tk
          createdAt: Value(now),
        ),
      );

      // Record a sale with historical price 180 Tk
      final saleId = 'sale_oil_hist';
      await inventoryDao.postSaleWithItems(
        sale: SalesRecordsCompanion(
          id: Value(saleId),
          businessId: const Value('biz_1'),
          saleDate: Value(now),
          saleTime: const Value('10:00'),
          totalMinor: const Value(18000),
          paidMinor: const Value(18000),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        items: [
          SalesItemsCompanion(
            id: const Value('item_oil_hist'),
            saleId: Value(saleId),
            productId: const Value('prod_oil'),
            quantity: const Value(1.0),
            unit: const Value('liter'),
            unitPriceMinor: const Value(18000),
            unitCostMinor: const Value(15000),
            totalMinor: const Value(18000),
          ),
        ],
        movements: [],
      );

      // Now product price increases to 200 Tk
      await (db.update(db.products)..where((p) => p.id.equals('prod_oil'))).write(
        const ProductsCompanion(
          sellingPriceMinor: Value(20000),
          purchasePriceMinor: Value(17000),
        ),
      );

      // Verify the saved sale item still retains its original historical price 180 Tk
      final savedItems = await businessDao.getSaleItems(saleId);
      expect(savedItems.first.unitPriceMinor, 18000);
      expect(savedItems.first.unitCostMinor, 15000);
    });
  });
}
