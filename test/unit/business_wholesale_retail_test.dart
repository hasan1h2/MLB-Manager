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

  test('Wholesale quantity tier pricing calculates correctly', () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Create a business
    await businessDao.insertBusiness(
      BusinessesCompanion(
        id: const Value('biz-1'),
        name: const Value('Test Hybrid Store'),
        businessType: const Value('hybrid'),
        openingDate: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    // 2. Insert a product with retail = 100 Tk, wholesale = 90 Tk
    await inventoryDao.insertProduct(
      ProductsCompanion(
        id: const Value('prod-1'),
        businessId: const Value('biz-1'),
        name: const Value('Miniket Rice'),
        unit: const Value('kg'),
        purchasePriceMinor: const Value(7000), // 70 Tk
        sellingPriceMinor: const Value(10000), // 100 Tk retail
        wholesalePriceMinor: const Value(9000), // 90 Tk default wholesale
        createdAt: Value(now),
      ),
    );

    // 3. Add price tiers:
    // Tier 1: 10 to 49 kg -> 85 Tk (8500 minor)
    // Tier 2: 50+ kg -> 80 Tk (8000 minor)
    await inventoryDao.setProductPriceTiers(
      'prod-1',
      [
        ProductPriceTiersCompanion(
          id: const Value('tier-1'),
          productId: const Value('prod-1'),
          minQuantity: const Value(10.0),
          maxQuantity: const Value(49.99),
          priceMinor: const Value(8500),
          createdAt: Value(now),
        ),
        ProductPriceTiersCompanion(
          id: const Value('tier-2'),
          productId: const Value('prod-1'),
          minQuantity: const Value(50.0),
          priceMinor: const Value(8000),
          createdAt: Value(now),
        ),
      ],
    );

    // 4. Verify Pricing:
    // A) Retail 5 kg -> default selling price (100 Tk)
    final priceRetail5 =
        await inventoryDao.getProductPriceForQuantity('prod-1', 5.0, isWholesale: false);
    expect(priceRetail5, 10000);

    // B) Wholesale 5 kg -> default wholesale price (90 Tk) because < 10 kg
    final priceWhole5 =
        await inventoryDao.getProductPriceForQuantity('prod-1', 5.0, isWholesale: true);
    expect(priceWhole5, 9000);

    // C) 20 kg (matches Tier 1) -> 85 Tk
    final priceTier1 =
        await inventoryDao.getProductPriceForQuantity('prod-1', 20.0, isWholesale: true);
    expect(priceTier1, 8500);

    // D) 60 kg (matches Tier 2) -> 80 Tk
    final priceTier2 =
        await inventoryDao.getProductPriceForQuantity('prod-1', 60.0, isWholesale: true);
    expect(priceTier2, 8000);
  });

  test('Strict Financial Rule: Gross Profit = Net Sales - COGS, Net Profit = Gross Profit - Expenses',
      () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Setup Business
    await businessDao.insertBusiness(
      BusinessesCompanion(
        id: const Value('biz-audit'),
        name: const Value('Audited Grocery'),
        businessType: const Value('retail'),
        openingDate: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    // 2. Insert Product: Cost = 50 Tk (5000), Retail = 80 Tk (8000)
    await inventoryDao.insertProduct(
      ProductsCompanion(
        id: const Value('prod-cogs'),
        businessId: const Value('biz-audit'),
        name: const Value('Soybean Oil 1L'),
        unit: const Value('liter'),
        purchasePriceMinor: const Value(5000),
        sellingPriceMinor: const Value(8000),
        createdAt: Value(now),
      ),
    );

    // 3. Purchase 100 units at 50 Tk = 5,000 Tk (500,000 minor)
    await inventoryDao.postPurchaseWithItems(
      purchase: PurchaseRecordsCompanion(
        id: const Value('pur-1'),
        businessId: const Value('biz-audit'),
        purchaseDate: Value(now),
        subtotalMinor: const Value(500000),
        totalMinor: const Value(500000),
        paidMinor: const Value(500000),
      ),
      items: [
        const PurchaseItemsCompanion(
          id: Value('pi-1'),
          purchaseId: Value('pur-1'),
          productId: Value('prod-cogs'),
          quantity: Value(100.0),
          unitCostMinor: Value(5000),
          totalMinor: Value(500000),
        ),
      ],
      movements: [
        InventoryMovementsCompanion(
          id: const Value('mov-1'),
          productId: const Value('prod-cogs'),
          businessId: const Value('biz-audit'),
          movementType: const Value('purchase'),
          quantity: const Value(100.0),
          movementDate: Value(now),
        ),
      ],
    );

    // 4. Sell 40 units at 80 Tk = 3,200 Tk (320,000 minor)
    // COGS for 40 units = 40 * 50 = 2,000 Tk (200,000 minor)
    await inventoryDao.postSaleWithItems(
      sale: SalesRecordsCompanion(
        id: const Value('sale-1'),
        businessId: const Value('biz-audit'),
        saleDate: Value(now),
        subtotalMinor: const Value(320000),
        totalMinor: const Value(320000),
        paidMinor: const Value(320000),
        saleType: const Value('retail'),
      ),
      items: [
        const SalesItemsCompanion(
          id: Value('si-1'),
          saleId: Value('sale-1'),
          productId: Value('prod-cogs'),
          quantity: Value(40.0),
          unitPriceMinor: Value(8000),
          unitCostMinor: Value(5000), // COGS per unit
          totalMinor: Value(320000),
        ),
      ],
      movements: [
        InventoryMovementsCompanion(
          id: const Value('mov-2'),
          productId: const Value('prod-cogs'),
          businessId: const Value('biz-audit'),
          movementType: const Value('sale'),
          quantity: const Value(40.0),
          movementDate: Value(now),
        ),
      ],
    );

    // 5. Add an operating expense of 300 Tk (30,000 minor)
    await db.into(db.transactions).insert(
          TransactionsCompanion(
            id: const Value('tx-exp-1'),
            transactionNumber: const Value('TX-101'),
            transactionType: const Value('expense'),
            scopeType: const Value('business'),
            businessId: const Value('biz-audit'),
            amountMinor: const Value(30000),
            transactionDate: Value(now),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    // 6. Calculate business metrics
    final metrics = await businessDao.calculateMetrics('biz-audit');

    // Total Sales = 3,200 Tk (320,000 minor)
    expect(metrics.totalSalesMinor, 320000);

    // Total Purchases = 5,000 Tk (500,000 minor)
    expect(metrics.totalPurchasesMinor, 500000);

    // COGS = 40 * 50 = 2,000 Tk (200,000 minor)
    expect(metrics.cogsMinor, 200000);

    // Gross Profit = Net Sales (3,200 Tk) - COGS (2,000 Tk) = 1,200 Tk (120,000 minor)
    // CRITICAL: Gross profit MUST NOT be Sales - Purchases (-1,800 Tk), but +1,200 Tk!
    expect(metrics.grossProfitMinor, 120000);

    // Operating Expenses = 300 Tk (30,000 minor)
    expect(metrics.operatingExpensesMinor, 30000);

    // Net Profit = Gross Profit (1,200 Tk) - Expenses (300 Tk) = 900 Tk (90,000 minor)
    expect(metrics.netProfitMinor, 90000);

    // Remaining Stock = 100 - 40 = 60 units. Inventory Value = 60 * 50 = 3,000 Tk (300,000 minor)
    expect(metrics.inventoryValueMinor, 300000);
  });

  test('Daily Cash Session accurately tracks opening, closing and difference', () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await businessDao.insertBusiness(
      BusinessesCompanion(
        id: const Value('biz-cash'),
        name: const Value('Cash Testing Shop'),
        businessType: const Value('retail'),
        openingDate: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    // 1. Open session with 1,000 Tk (100,000 minor)
    await businessDao.openCashSession(
      CashSessionsCompanion(
        id: const Value('cs-1'),
        businessId: const Value('biz-cash'),
        sessionDate: Value(now),
        openingCashMinor: const Value(100000),
        expectedClosingMinor: const Value(100000),
        status: const Value('open'),
        openedAt: Value(now),
      ),
    );

    // 2. Fetch open session
    final openSession = await businessDao.getOpenCashSession('biz-cash');
    expect(openSession, isNotNull);
    expect(openSession!.openingCashMinor, 100000);
    expect(openSession.status, 'open');

    // 3. Close session with actual counted cash = 1,500 Tk (150,000 minor), diff = +500 Tk (+50,000 minor)
    final closed = await businessDao.closeCashSession(
      sessionId: 'cs-1',
      actualClosingMinor: 150000,
      differenceMinor: 50000,
      notes: 'Surplus from loose change',
      closedAt: now + 3600000,
    );
    expect(closed, isTrue);

    // 4. Verify session is closed
    final active = await businessDao.getOpenCashSession('biz-cash');
    expect(active, isNull);
  });
}
