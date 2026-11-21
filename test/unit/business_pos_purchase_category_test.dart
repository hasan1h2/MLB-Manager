import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlb_manager/core/constants/product_templates.dart';
import 'package:mlb_manager/core/database/app_database.dart';
import 'package:mlb_manager/core/database/daos/business_dao.dart';
import 'package:mlb_manager/core/database/daos/core_dao.dart';
import 'package:mlb_manager/core/database/daos/inventory_dao.dart';
import 'package:mlb_manager/core/utils/unit_conversion_utils.dart';

void main() {
  late AppDatabase db;
  late BusinessDao businessDao;
  late InventoryDao inventoryDao;
  late CoreDao coreDao;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    businessDao = BusinessDao(db);
    inventoryDao = InventoryDao(db);
    coreDao = CoreDao(db);

    // Seed starter product categories
    final now = DateTime.now().millisecondsSinceEpoch;
    for (var cat in ProductTemplates.starterCategories) {
      await coreDao.insertCategory(
        CategoriesCompanion(
          id: Value(cat.id),
          nameBn: Value(cat.nameBn),
          nameEn: Value(cat.nameEn),
          categoryType: const Value('product'),
          scope: const Value('business'),
          icon: Value(cat.icon),
          isSystem: const Value(1),
          isActive: const Value(1),
          createdAt: Value(now),
        ),
      );
    }

    // Create Business A & B
    await businessDao.insertBusiness(
      BusinessesCompanion(
        id: const Value('biz_a'),
        name: const Value('মুদি কর্নার'),
        businessType: const Value('retail'),
        openingDate: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await businessDao.insertBusiness(
      BusinessesCompanion(
        id: const Value('biz_b'),
        name: const Value('হোলসেল হাব'),
        businessType: const Value('wholesale'),
        openingDate: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('1 & 2. Create Business A and B; category & product in A do not leak into B', () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Add custom category to Business A
    await coreDao.insertCategory(
      CategoriesCompanion(
        id: const Value('cat_custom_a'),
        nameBn: const Value('বিশেষ আইটেম'),
        nameEn: const Value('Special Items'),
        categoryType: const Value('product'),
        scope: const Value('business'),
        businessId: const Value('biz_a'),
        createdAt: Value(now),
      ),
    );

    // Add product to Business A
    await inventoryDao.insertProduct(
      ProductsCompanion(
        id: const Value('prod_a_1'),
        businessId: const Value('biz_a'),
        name: const Value('স্পেশাল মধু'),
        categoryId: const Value('cat_custom_a'),
        unit: const Value('bottle'),
        purchasePriceMinor: const Value(30000), // 300 Tk
        sellingPriceMinor: const Value(45000),  // 450 Tk
        createdAt: Value(now),
      ),
    );

    // Verify categories for Business B do NOT include custom category from A
    final catsB = await coreDao.getProductCategories(businessId: 'biz_b');
    expect(catsB.any((c) => c.id == 'cat_custom_a'), isFalse);

    // Verify products for Business B do NOT include products from A
    final prodsB = await inventoryDao.getAllProducts('biz_b');
    expect(prodsB.isEmpty, isTrue);

    final prodsA = await inventoryDao.getAllProducts('biz_a');
    expect(prodsA.length, 1);
    expect(prodsA.first.id, 'prod_a_1');
  });

  test('3. Purchase 1 carton configured as 24 packets; confirm stock conversion', () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Insert biscuit product with packet base unit and carton packaging (24 packets/carton)
    await inventoryDao.insertProduct(
      ProductsCompanion(
        id: const Value('prod_biscuit'),
        businessId: const Value('biz_a'),
        name: const Value('টোস্ট বিস্কুট'),
        categoryId: const Value('cat_biscuits'),
        unit: const Value('packet'), // base stock unit
        packageUnit: const Value('carton'),
        packageQuantity: const Value(24.0),
        purchasePriceMinor: const Value(4000), // 40 Tk per packet
        sellingPriceMinor: const Value(5000),  // 50 Tk per packet
        openingQuantity: const Value(0.0),
        createdAt: Value(now),
      ),
    );

    // Purchase 1 carton for 960 Tk (40 Tk/packet * 24 packets = 960 Tk)
    const factor = 24.0;
    const qtyPurchased = 1.0; // 1 carton
    final baseQty = qtyPurchased * factor; // 24 packets
    const totalCostMinor = 96000; // 960 Tk

    await inventoryDao.postPurchaseWithItems(
      purchase: PurchaseRecordsCompanion(
        id: const Value('pur_1'),
        businessId: const Value('biz_a'),
        purchaseDate: Value(now),
        subtotalMinor: const Value(totalCostMinor),
        totalMinor: const Value(totalCostMinor),
        paidMinor: const Value(totalCostMinor),
        dueMinor: const Value(0),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      items: [
        PurchaseItemsCompanion(
          id: const Value('pur_item_1'),
          purchaseId: const Value('pur_1'),
          productId: const Value('prod_biscuit'),
          productName: const Value('টোস্ট বিস্কুট'),
          unit: const Value('carton'),
          quantity: const Value(qtyPurchased),
          conversionFactor: const Value(factor),
          baseQuantity: Value(baseQty),
          unitCostMinor: const Value(totalCostMinor),
          retailPriceMinor: const Value(5000),
          totalMinor: const Value(totalCostMinor),
        ),
      ],
      movements: [
        InventoryMovementsCompanion(
          id: const Value('mov_1'),
          productId: const Value('prod_biscuit'),
          businessId: const Value('biz_a'),
          movementType: const Value('purchase'),
          quantity: Value(baseQty), // 24 packets in stock!
          unitCostMinor: const Value(4000),
          movementDate: Value(now),
        ),
      ],
    );

    // Verify stock is 24 packets
    final currentStock = await inventoryDao.getProductCurrentStock('prod_biscuit');
    expect(currentStock, 24.0);
  });

  test('4, 5 & 6. Purchase 2 KG rice; filter category চাল; sell 500 G and verify conversion', () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Create rice product in category cat_rice with base unit kg
    await inventoryDao.insertProduct(
      ProductsCompanion(
        id: const Value('prod_rice'),
        businessId: const Value('biz_a'),
        name: const Value('মিনিকেট চাল'),
        nameBn: const Value('মিনিকেট চাল'),
        categoryId: const Value('cat_rice'),
        unit: const Value('kg'),
        purchasePriceMinor: const Value(6000), // 60 Tk / kg
        sellingPriceMinor: const Value(7500),  // 75 Tk / kg
        openingQuantity: const Value(0.0),
        createdAt: Value(now),
      ),
    );

    // Purchase 2 KG rice
    await inventoryDao.postPurchaseWithItems(
      purchase: PurchaseRecordsCompanion(
        id: const Value('pur_rice_1'),
        businessId: const Value('biz_a'),
        purchaseDate: Value(now),
        subtotalMinor: const Value(12000), // 120 Tk
        totalMinor: const Value(12000),
        paidMinor: const Value(12000),
        dueMinor: const Value(0),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      items: [
        PurchaseItemsCompanion(
          id: const Value('pur_rice_item_1'),
          purchaseId: const Value('pur_rice_1'),
          productId: const Value('prod_rice'),
          productName: const Value('মিনিকেট চাল'),
          unit: const Value('kg'),
          quantity: const Value(2.0),
          conversionFactor: const Value(1.0),
          baseQuantity: const Value(2.0),
          unitCostMinor: const Value(6000),
          totalMinor: const Value(12000),
        ),
      ],
      movements: [
        InventoryMovementsCompanion(
          id: const Value('mov_pur_rice'),
          productId: const Value('prod_rice'),
          businessId: const Value('biz_a'),
          movementType: const Value('purchase'),
          quantity: const Value(2.0), // +2 KG
          unitCostMinor: const Value(6000),
          movementDate: Value(now),
        ),
      ],
    );

    expect(await inventoryDao.getProductCurrentStock('prod_rice'), 2.0);

    // 5. Test category filter: querying products by cat_rice returns only rice
    final allProds = await inventoryDao.getAllProducts('biz_a');
    final riceProds = allProds.where((p) => p.categoryId == 'cat_rice').toList();
    expect(riceProds.length, 1);
    expect(riceProds.first.name, 'মিনিকেট চাল');

    // 6. Sell 500 G rice:
    // 500 G = 0.5 KG baseQuantity
    // Price = 0.5 * 75 Tk = 37.50 Tk = 3750 Poisha
    const sellQty = 500.0;
    const sellUnit = 'g';
    final factor = UnitConversionUtils.getConversionFactor(fromUnit: sellUnit, toBaseUnit: 'kg');
    expect(factor, 0.001);

    final baseSoldQty = UnitConversionUtils.calculateBaseQuantity(
      quantity: sellQty,
      unit: sellUnit,
      baseUnit: 'kg',
    );
    expect(baseSoldQty, 0.5);

    final lineTotalMinor = UnitConversionUtils.calculateSaleLineTotal(
      quantity: sellQty,
      unit: sellUnit,
      baseUnitPriceMinor: 7500, // 75 Tk/kg
      baseUnit: 'kg',
    );
    expect(lineTotalMinor, 3750); // 37.50 Tk

    await inventoryDao.postSaleWithItems(
      sale: SalesRecordsCompanion(
        id: const Value('sale_rice_1'),
        businessId: const Value('biz_a'),
        saleDate: Value(now),
        subtotalMinor: Value(lineTotalMinor),
        totalMinor: Value(lineTotalMinor),
        paidMinor: Value(lineTotalMinor),
        dueMinor: const Value(0),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      items: [
        SalesItemsCompanion(
          id: const Value('sale_item_1'),
          saleId: const Value('sale_rice_1'),
          productId: const Value('prod_rice'),
          productName: const Value('মিনিকেট চাল'),
          unit: const Value('g'),
          quantity: const Value(sellQty),
          conversionFactor: Value(factor),
          baseQuantity: Value(baseSoldQty),
          unitPriceMinor: const Value(75), // 0.075 Tk per gram
          unitCostMinor: const Value(6000), // 60 Tk / kg cost basis
          totalMinor: Value(lineTotalMinor),
        ),
      ],
      movements: [
        InventoryMovementsCompanion(
          id: const Value('mov_sale_rice'),
          productId: const Value('prod_rice'),
          businessId: const Value('biz_a'),
          movementType: const Value('sale'),
          quantity: Value(baseSoldQty), // deduct 0.5 KG!
          unitCostMinor: const Value(6000),
          movementDate: Value(now),
        ),
      ],
    );

    // Remaining stock: 2.0 - 0.5 = 1.5 KG
    final remainingStock = await inventoryDao.getProductCurrentStock('prod_rice');
    expect(remainingStock, 1.5);
  });

  test('7 & 8. Wholesale POS pricing & Sell pieces from box product', () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Product with baseUnit 'piece', packageUnit 'box' (10 pieces/box)
    await inventoryDao.insertProduct(
      ProductsCompanion(
        id: const Value('prod_pen'),
        businessId: const Value('biz_a'),
        name: const Value('ম্যাটাডোর কলম'),
        unit: const Value('piece'),
        packageUnit: const Value('box'),
        packageQuantity: const Value(10.0),
        purchasePriceMinor: const Value(400),  // 4 Tk
        sellingPriceMinor: const Value(500),   // 5 Tk retail
        wholesalePriceMinor: const Value(450), // 4.5 Tk wholesale
        openingQuantity: const Value(100.0),  // 100 pieces
        createdAt: Value(now),
      ),
    );

    // Check wholesale price lookup
    final wholesalePrice = await inventoryDao.getProductPriceForQuantity(
      'prod_pen',
      10.0,
      isWholesale: true,
    );
    expect(wholesalePrice, 450); // 4.5 Tk

    final retailPrice = await inventoryDao.getProductPriceForQuantity(
      'prod_pen',
      10.0,
      isWholesale: false,
    );
    expect(retailPrice, 500); // 5 Tk

    // Sell 3 pieces from stock
    await inventoryDao.insertMovement(
      InventoryMovementsCompanion(
        id: const Value('mov_pen_sale'),
        productId: const Value('prod_pen'),
        businessId: const Value('biz_a'),
        movementType: const Value('sale'),
        quantity: const Value(3.0),
        unitCostMinor: const Value(400),
        movementDate: Value(now),
      ),
    );

    // Remaining stock: 100 - 3 = 97 pieces
    expect(await inventoryDao.getProductCurrentStock('prod_pen'), 97.0);
  });

  test('9, 14, 15 & 16. Financial metrics, COGS and Profit reconcile with historical cost', () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Business with initial capital 50,000 Tk
    await businessDao.insertBusiness(
      BusinessesCompanion(
        id: const Value('biz_metrics'),
        name: const Value('হিসাব ট্রেডার্স'),
        businessType: const Value('hybrid'),
        initialCapitalMinor: const Value(5000000),
        openingDate: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    // Create product: cost 100 Tk, retail 150 Tk
    await inventoryDao.insertProduct(
      ProductsCompanion(
        id: const Value('prod_soap'),
        businessId: const Value('biz_metrics'),
        name: const Value('লাক্স সাবান'),
        unit: const Value('piece'),
        purchasePriceMinor: const Value(10000), // 100 Tk
        sellingPriceMinor: const Value(15000),  // 150 Tk
        wholesalePriceMinor: const Value(13000),// 130 Tk
        openingQuantity: const Value(20.0),
        createdAt: Value(now),
      ),
    );

    // Retail sale: 5 pieces @ 150 Tk = 750 Tk
    // COGS = 5 * 100 Tk = 500 Tk. Gross Profit = 250 Tk
    await inventoryDao.postSaleWithItems(
      sale: SalesRecordsCompanion(
        id: const Value('sale_retail_1'),
        businessId: const Value('biz_metrics'),
        saleDate: Value(now),
        saleType: const Value('retail'),
        subtotalMinor: const Value(75000),
        totalMinor: const Value(75000),
        paidMinor: const Value(75000),
        dueMinor: const Value(0),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      items: [
        SalesItemsCompanion(
          id: const Value('s_item_1'),
          saleId: const Value('sale_retail_1'),
          productId: const Value('prod_soap'),
          productName: const Value('লাক্স সাবান'),
          unit: const Value('piece'),
          quantity: const Value(5.0),
          conversionFactor: const Value(1.0),
          baseQuantity: const Value(5.0),
          unitPriceMinor: const Value(15000),
          unitCostMinor: const Value(10000),
          totalMinor: const Value(75000),
        ),
      ],
      movements: [
        InventoryMovementsCompanion(
          id: const Value('mov_retail_1'),
          productId: const Value('prod_soap'),
          businessId: const Value('biz_metrics'),
          movementType: const Value('sale'),
          quantity: const Value(5.0),
          unitCostMinor: const Value(10000),
          movementDate: Value(now),
        ),
      ],
    );

    // Wholesale sale: 10 pieces @ 130 Tk = 1300 Tk
    // COGS = 10 * 100 Tk = 1000 Tk. Gross profit = 300 Tk
    await inventoryDao.postSaleWithItems(
      sale: SalesRecordsCompanion(
        id: const Value('sale_wholesale_1'),
        businessId: const Value('biz_metrics'),
        saleDate: Value(now),
        saleType: const Value('wholesale'),
        subtotalMinor: const Value(130000),
        totalMinor: const Value(130000),
        paidMinor: const Value(130000),
        dueMinor: const Value(0),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      items: [
        SalesItemsCompanion(
          id: const Value('s_item_2'),
          saleId: const Value('sale_wholesale_1'),
          productId: const Value('prod_soap'),
          productName: const Value('লাক্স সাবান'),
          unit: const Value('piece'),
          quantity: const Value(10.0),
          conversionFactor: const Value(1.0),
          baseQuantity: const Value(10.0),
          unitPriceMinor: const Value(13000),
          unitCostMinor: const Value(10000),
          totalMinor: const Value(130000),
        ),
      ],
      movements: [
        InventoryMovementsCompanion(
          id: const Value('mov_wholesale_1'),
          productId: const Value('prod_soap'),
          businessId: const Value('biz_metrics'),
          movementType: const Value('wholesale_sale'),
          quantity: const Value(10.0),
          unitCostMinor: const Value(10000),
          movementDate: Value(now),
        ),
      ],
    );

    // Calculate metrics
    final metrics = await businessDao.calculateMetrics('biz_metrics');
    // Total sales = 750 + 1300 = 2050 Tk = 205000 Poisha
    expect(metrics.totalSalesMinor, 205000);
    expect(metrics.retailSalesMinor, 75000);
    expect(metrics.wholesaleSalesMinor, 130000);

    // Total COGS = 500 + 1000 = 1500 Tk = 150000 Poisha
    expect(metrics.cogsMinor, 150000);

    // Gross profit = 2050 - 1500 = 550 Tk = 55000 Poisha
    expect(metrics.grossProfitMinor, 55000);

    // Remaining stock: 20 - 5 - 10 = 5 pieces
    expect(metrics.totalStockQuantity, 5.0);

    // Category sales breakdown
    final catSales = await businessDao.getCategoryWiseSales('biz_metrics');
    expect(catSales.isNotEmpty, isTrue);

    // Top selling products
    final topProds = await businessDao.getTopSellingProducts('biz_metrics');
    expect(topProds.first.productName, 'লাক্স সাবান');
    expect(topProds.first.quantitySold, 15.0);
  });

  test('18. Category and subcategory CRUD with safe archiving', () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Create root category
    await coreDao.insertCategory(
      CategoriesCompanion(
        id: const Value('cat_beverage_root'),
        nameBn: const Value('পানীয়'),
        nameEn: const Value('Beverages'),
        categoryType: const Value('product'),
        scope: const Value('business'),
        businessId: const Value('biz_a'),
        createdAt: Value(now),
      ),
    );

    // 2. Create subcategory under cat_beverage_root
    await coreDao.insertCategory(
      CategoriesCompanion(
        id: const Value('subcat_juice'),
        parentId: const Value('cat_beverage_root'),
        nameBn: const Value('আমের জুস'),
        nameEn: const Value('Mango Juice'),
        categoryType: const Value('product'),
        scope: const Value('business'),
        businessId: const Value('biz_a'),
        createdAt: Value(now),
      ),
    );

    // Verify subcategories query
    final subs = await coreDao.getSubcategories('cat_beverage_root', businessId: 'biz_a');
    expect(subs.length, 1);
    expect(subs.first.id, 'subcat_juice');

    // 3. Edit category
    final cat = await coreDao.getCategoryById('cat_beverage_root');
    expect(cat, isNotNull);
    final updatedCat = cat!.copyWith(nameBn: 'কোমল পানীয় ও জুস');
    await coreDao.updateCategory(updatedCat);

    final refreshed = await coreDao.getCategoryById('cat_beverage_root');
    expect(refreshed!.nameBn, 'কোমল পানীয় ও জুস');

    // 4. Safe archive (non-destructive)
    await coreDao.archiveCategory('cat_beverage_root');
    final archived = await coreDao.getCategoryById('cat_beverage_root');
    expect(archived!.isActive, 0); // archived, not deleted!

    // When querying activeOnly, archived category is excluded
    final activeCats = await coreDao.getProductCategories(businessId: 'biz_a', activeOnly: true);
    expect(activeCats.any((c) => c.id == 'cat_beverage_root'), isFalse);
  });
}
