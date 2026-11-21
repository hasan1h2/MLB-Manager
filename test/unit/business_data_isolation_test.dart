import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlb_manager/core/database/app_database.dart';
import 'package:mlb_manager/core/database/daos/business_dao.dart';
import 'package:mlb_manager/core/database/daos/inventory_dao.dart';

void main() {
  late AppDatabase db;
  late BusinessDao businessDao;
  late InventoryDao inventoryDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    businessDao = BusinessDao(db);
    inventoryDao = InventoryDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Business Data Isolation: Products for Business A and B are strictly separated',
      () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Create Business A (Grocery) and Business B (Wholesale)
    await businessDao.insertBusiness(
      BusinessesCompanion(
        id: const Value('biz-a'),
        name: const Value('Habib Grocery Store'),
        businessType: const Value('retail'),
        openingDate: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await businessDao.insertBusiness(
      BusinessesCompanion(
        id: const Value('biz-b'),
        name: const Value('Habib Wholesale Mart'),
        businessType: const Value('wholesale'),
        openingDate: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    // Add 5 products to Business A
    for (int i = 1; i <= 5; i++) {
      await inventoryDao.insertProduct(
        ProductsCompanion(
          id: Value('prod-a-$i'),
          businessId: const Value('biz-a'),
          name: Value('Grocery Item $i'),
          nameBn: Value('মুদি পণ্য $i'),
          unit: const Value('kg'),
          purchasePriceMinor: const Value(5000),
          sellingPriceMinor: const Value(7000),
          createdAt: Value(now),
        ),
      );
    }

    // Add 3 products to Business B
    for (int i = 1; i <= 3; i++) {
      await inventoryDao.insertProduct(
        ProductsCompanion(
          id: Value('prod-b-$i'),
          businessId: const Value('biz-b'),
          name: Value('Wholesale Item $i'),
          nameBn: Value('পাইকারি পণ্য $i'),
          unit: const Value('bag'),
          purchasePriceMinor: const Value(200000),
          sellingPriceMinor: const Value(250000),
          createdAt: Value(now),
        ),
      );
    }

    // Query products for Business A
    final prodsA = await inventoryDao.getAllProducts('biz-a');
    expect(prodsA.length, 5);
    expect(prodsA.every((p) => p.businessId == 'biz-a'), isTrue);

    // Query products for Business B
    final prodsB = await inventoryDao.getAllProducts('biz-b');
    expect(prodsB.length, 3);
    expect(prodsB.every((p) => p.businessId == 'biz-b'), isTrue);

    // Verify no overlap
    final aIds = prodsA.map((p) => p.id).toSet();
    final bIds = prodsB.map((p) => p.id).toSet();
    expect(aIds.intersection(bIds).isEmpty, isTrue);
  });

  test('Business Data Isolation: Cross-business sale is strictly rejected', () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Create Business A and Business B
    await businessDao.insertBusiness(
      BusinessesCompanion(
        id: const Value('biz-a'),
        name: const Value('Store A'),
        businessType: const Value('retail'),
        openingDate: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await businessDao.insertBusiness(
      BusinessesCompanion(
        id: const Value('biz-b'),
        name: const Value('Store B'),
        businessType: const Value('retail'),
        openingDate: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    // Product belonging to Business A
    await inventoryDao.insertProduct(
      ProductsCompanion(
        id: const Value('prod-a-1'),
        businessId: const Value('biz-a'),
        name: const Value('Sugar'),
        unit: const Value('kg'),
        purchasePriceMinor: const Value(12000),
        sellingPriceMinor: const Value(14000),
        createdAt: Value(now),
      ),
    );

    // Attempt to sell prod-a-1 under Business B -> MUST THROW ArgumentError
    final crossBizSale = SalesRecordsCompanion(
      id: const Value('sale-b-1'),
      businessId: const Value('biz-b'), // Business B
      saleDate: Value(now),
      saleTime: const Value('10:00'),
      invoiceNumber: const Value('INV-001'),
      saleType: const Value('retail'),
      paymentMethod: const Value('cash'),
      subtotalMinor: const Value(14000),
      discountMinor: const Value(0),
      totalMinor: const Value(14000),
      paidMinor: const Value(14000),
      dueMinor: const Value(0),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    final crossBizItem = SalesItemsCompanion(
      id: const Value('item-1'),
      saleId: const Value('sale-b-1'),
      productId: const Value('prod-a-1'), // BELONGS TO BUSINESS A!
      productName: const Value('Sugar'),
      unit: const Value('kg'),
      quantity: const Value(1.0),
      unitPriceMinor: const Value(14000),
      unitCostMinor: const Value(12000),
      totalMinor: const Value(14000),
    );

    expect(
      () async => await inventoryDao.postSaleWithItems(
        sale: crossBizSale,
        items: [crossBizItem],
        movements: [],
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('Dashboard Metrics Isolation: Metrics calculated strictly per business',
      () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Create Business A and Business B
    await businessDao.insertBusiness(
      BusinessesCompanion(
        id: const Value('biz-a'),
        name: const Value('Store A'),
        businessType: const Value('retail'),
        openingDate: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await businessDao.insertBusiness(
      BusinessesCompanion(
        id: const Value('biz-b'),
        name: const Value('Store B'),
        businessType: const Value('retail'),
        openingDate: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    // Add product to Business A and post a sale of 5,000 Tk (COGS 3,500 Tk)
    await inventoryDao.insertProduct(
      ProductsCompanion(
        id: const Value('prod-a-1'),
        businessId: const Value('biz-a'),
        name: const Value('Rice'),
        unit: const Value('kg'),
        purchasePriceMinor: const Value(350000),
        sellingPriceMinor: const Value(500000),
        createdAt: Value(now),
      ),
    );

    await inventoryDao.postSaleWithItems(
      sale: SalesRecordsCompanion(
        id: const Value('sale-a-1'),
        businessId: const Value('biz-a'),
        saleDate: Value(now),
        saleTime: const Value('12:00'),
        invoiceNumber: const Value('INV-A1'),
        saleType: const Value('retail'),
        paymentMethod: const Value('cash'),
        subtotalMinor: const Value(500000),
        discountMinor: const Value(0),
        totalMinor: const Value(500000),
        paidMinor: const Value(400000),
        dueMinor: const Value(100000), // Due 1,000 Tk
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      items: [
        const SalesItemsCompanion(
          id: Value('item-a-1'),
          saleId: Value('sale-a-1'),
          productId: Value('prod-a-1'),
          productName: Value('Rice'),
          unit: Value('kg'),
          quantity: Value(1.0),
          unitPriceMinor: Value(500000),
          unitCostMinor: Value(350000),
          totalMinor: Value(500000),
        ),
      ],
      movements: [],
    );

    // Metrics for Business A
    final metricsA = await businessDao.calculateMetrics('biz-a');
    expect(metricsA.totalSalesMinor, 500000); // 5,000 Tk
    expect(metricsA.cogsMinor, 350000); // 3,500 Tk
    expect(metricsA.grossProfitMinor, 150000); // 1,500 Tk
    expect(metricsA.customerReceivablesMinor, 100000); // 1,000 Tk due

    // Metrics for Business B -> MUST BE ALL ZERO!
    final metricsB = await businessDao.calculateMetrics('biz-b');
    expect(metricsB.totalSalesMinor, 0);
    expect(metricsB.cogsMinor, 0);
    expect(metricsB.grossProfitMinor, 0);
    expect(metricsB.netProfitMinor, 0);
    expect(metricsB.customerReceivablesMinor, 0);
    expect(metricsB.supplierPayablesMinor, 0);
    expect(metricsB.inventoryValueMinor, 0);
  });

  test('Empty Business Dashboard: displays zero values cleanly without null or error',
      () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await businessDao.insertBusiness(
      BusinessesCompanion(
        id: const Value('biz-empty'),
        name: const Value('Fresh Empty Shop'),
        businessType: const Value('retail'),
        openingDate: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    final metrics = await businessDao.calculateMetrics('biz-empty');
    expect(metrics.totalSalesMinor, 0);
    expect(metrics.cogsMinor, 0);
    expect(metrics.grossProfitMinor, 0);
    expect(metrics.operatingExpensesMinor, 0);
    expect(metrics.netProfitMinor, 0);
    expect(metrics.inventoryValueMinor, 0);
    expect(metrics.lowStockCount, 0);
    expect(metrics.outOfStockCount, 0);
    expect(metrics.customerReceivablesMinor, 0);
    expect(metrics.supplierPayablesMinor, 0);
  });
}
