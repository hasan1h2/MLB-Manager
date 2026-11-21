import 'package:drift/drift.dart';
import '../app_database.dart';

class BusinessMetricsResult {
  final int totalInvestmentMinor;
  final int totalSalesMinor;
  final int totalSalesCount;
  final int todaySalesMinor;
  final int todaySalesCount;
  final int monthlySalesMinor;
  final int monthlySalesCount;
  final int yearlySalesMinor;
  final int retailSalesMinor;
  final int wholesaleSalesMinor;
  final int quickSalesMinor;
  final int totalPurchasesMinor;
  final int todayPurchasesMinor;
  final int monthlyPurchasesMinor;
  final int cogsMinor;
  final int todayCogsMinor;
  final int monthlyCogsMinor;
  final int operatingExpensesMinor;
  final int todayExpensesMinor;
  final int monthlyExpensesMinor;
  final int grossProfitMinor;
  final int todayGrossProfitMinor;
  final int monthlyGrossProfitMinor;
  final int netProfitMinor;
  final int todayNetProfitMinor;
  final int monthlyNetProfitMinor;
  final int inventoryValueMinor;
  final double totalStockQuantity;
  final int totalProductsCount;
  final int lowStockCount;
  final int outOfStockCount;
  final int customerReceivablesMinor;
  final int totalCustomersCount;
  final int supplierPayablesMinor;
  final int totalSuppliersCount;

  BusinessMetricsResult({
    required this.totalInvestmentMinor,
    required this.totalSalesMinor,
    this.totalSalesCount = 0,
    this.todaySalesMinor = 0,
    this.todaySalesCount = 0,
    this.monthlySalesMinor = 0,
    this.monthlySalesCount = 0,
    this.yearlySalesMinor = 0,
    required this.retailSalesMinor,
    required this.wholesaleSalesMinor,
    required this.quickSalesMinor,
    required this.totalPurchasesMinor,
    this.todayPurchasesMinor = 0,
    this.monthlyPurchasesMinor = 0,
    required this.cogsMinor,
    this.todayCogsMinor = 0,
    this.monthlyCogsMinor = 0,
    required this.operatingExpensesMinor,
    this.todayExpensesMinor = 0,
    this.monthlyExpensesMinor = 0,
    required this.grossProfitMinor,
    this.todayGrossProfitMinor = 0,
    this.monthlyGrossProfitMinor = 0,
    required this.netProfitMinor,
    this.todayNetProfitMinor = 0,
    this.monthlyNetProfitMinor = 0,
    required this.inventoryValueMinor,
    this.totalStockQuantity = 0.0,
    this.totalProductsCount = 0,
    this.lowStockCount = 0,
    this.outOfStockCount = 0,
    required this.customerReceivablesMinor,
    this.totalCustomersCount = 0,
    required this.supplierPayablesMinor,
    this.totalSuppliersCount = 0,
  });

  factory BusinessMetricsResult.zero({int initialCapital = 0}) {
    return BusinessMetricsResult(
      totalInvestmentMinor: initialCapital,
      totalSalesMinor: 0,
      totalSalesCount: 0,
      todaySalesMinor: 0,
      todaySalesCount: 0,
      monthlySalesMinor: 0,
      monthlySalesCount: 0,
      yearlySalesMinor: 0,
      retailSalesMinor: 0,
      wholesaleSalesMinor: 0,
      quickSalesMinor: 0,
      totalPurchasesMinor: 0,
      todayPurchasesMinor: 0,
      monthlyPurchasesMinor: 0,
      cogsMinor: 0,
      todayCogsMinor: 0,
      monthlyCogsMinor: 0,
      operatingExpensesMinor: 0,
      todayExpensesMinor: 0,
      monthlyExpensesMinor: 0,
      grossProfitMinor: 0,
      todayGrossProfitMinor: 0,
      monthlyGrossProfitMinor: 0,
      netProfitMinor: 0,
      todayNetProfitMinor: 0,
      monthlyNetProfitMinor: 0,
      inventoryValueMinor: 0,
      totalStockQuantity: 0.0,
      totalProductsCount: 0,
      lowStockCount: 0,
      outOfStockCount: 0,
      customerReceivablesMinor: 0,
      totalCustomersCount: 0,
      supplierPayablesMinor: 0,
      totalSuppliersCount: 0,
    );
  }
}

class BusinessDao {
  final AppDatabase db;
  BusinessDao(this.db);

  // --- Businesses ---
  Stream<List<BusinessesData>> watchBusinesses() {
    return (db.select(db.businesses)
          ..where((tbl) => tbl.status.equals('active')))
        .watch();
  }

  Future<List<BusinessesData>> getAllBusinesses() {
    return (db.select(db.businesses)
          ..where((tbl) => tbl.status.equals('active')))
        .get();
  }

  Future<BusinessesData?> getBusinessById(String id) {
    return (db.select(db.businesses)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertBusiness(BusinessesCompanion business) {
    return db.into(db.businesses).insert(business);
  }

  Future<bool> updateBusiness(BusinessesData business) {
    return db.update(db.businesses).replace(business);
  }

  Future<void> updateBusinessType(String businessId, String newType) async {
    await (db.update(db.businesses)..where((t) => t.id.equals(businessId)))
        .write(BusinessesCompanion(
      businessType: Value(newType),
      updatedAt: Value(DateTime.now().toUtc().millisecondsSinceEpoch),
    ));
  }

  Future<void> updateBusinessSettings(
    String businessId, {
    String? name,
    String? businessType,
    String? currency,
    String? timeFormat,
    int? allowNegativeStock,
    String? costingMethod,
    String? location,
    String? phone,
    String? description,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (db.update(db.businesses)..where((t) => t.id.equals(businessId)))
        .write(BusinessesCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      businessType:
          businessType != null ? Value(businessType) : const Value.absent(),
      currency: currency != null ? Value(currency) : const Value.absent(),
      timeFormat:
          timeFormat != null ? Value(timeFormat) : const Value.absent(),
      allowNegativeStock: allowNegativeStock != null
          ? Value(allowNegativeStock)
          : const Value.absent(),
      costingMethod:
          costingMethod != null ? Value(costingMethod) : const Value.absent(),
      location: location != null ? Value(location) : const Value.absent(),
      phone: phone != null ? Value(phone) : const Value.absent(),
      description:
          description != null ? Value(description) : const Value.absent(),
      updatedAt: Value(now),
    ));
  }

  // --- Customers ---
  Stream<List<Customer>> watchCustomers(String businessId) {
    return (db.select(db.customers)
          ..where((tbl) => tbl.businessId.equals(businessId)))
        .watch();
  }

  Future<List<Customer>> getAllCustomers(String businessId) {
    return (db.select(db.customers)
          ..where((tbl) => tbl.businessId.equals(businessId)))
        .get();
  }

  Future<Customer?> getCustomerById(String id) {
    return (db.select(db.customers)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertCustomer(CustomersCompanion customer) {
    return db.into(db.customers).insert(customer);
  }

  Future<bool> updateCustomer(Customer customer) {
    return db.update(db.customers).replace(customer);
  }

  /// Customer Outstanding Due = Opening + Credit Sales Due - Payments Received
  Future<int> getCustomerOutstandingDue(String customerId) async {
    final customer = await getCustomerById(customerId);
    if (customer == null) return 0;

    final salesDue = await (db.selectOnly(db.salesRecords)
          ..addColumns([db.salesRecords.dueMinor.sum()])
          ..where(db.salesRecords.customerId.equals(customerId)))
        .getSingle();
    final int totalSalesDue =
        salesDue.read(db.salesRecords.dueMinor.sum()) ?? 0;

    final payments = await (db.selectOnly(db.partyPayments)
          ..addColumns([db.partyPayments.amountMinor.sum()])
          ..where(db.partyPayments.partyId.equals(customerId) &
              db.partyPayments.partyType.equals('customer')))
        .getSingle();
    final int totalPayments =
        payments.read(db.partyPayments.amountMinor.sum()) ?? 0;

    return customer.openingBalanceMinor + totalSalesDue - totalPayments;
  }

  // --- Suppliers ---
  Stream<List<Supplier>> watchSuppliers(String businessId) {
    return (db.select(db.suppliers)
          ..where((tbl) => tbl.businessId.equals(businessId)))
        .watch();
  }

  Future<List<Supplier>> getAllSuppliers(String businessId) {
    return (db.select(db.suppliers)
          ..where((tbl) => tbl.businessId.equals(businessId)))
        .get();
  }

  Future<Supplier?> getSupplierById(String id) {
    return (db.select(db.suppliers)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertSupplier(SuppliersCompanion supplier) {
    return db.into(db.suppliers).insert(supplier);
  }

  Future<bool> updateSupplier(Supplier supplier) {
    return db.update(db.suppliers).replace(supplier);
  }

  /// Supplier Outstanding Payable = Opening + Credit Purchases Due - Payments Made
  Future<int> getSupplierOutstandingPayable(String supplierId) async {
    final supplier = await getSupplierById(supplierId);
    if (supplier == null) return 0;

    final purchasesDue = await (db.selectOnly(db.purchaseRecords)
          ..addColumns([db.purchaseRecords.dueMinor.sum()])
          ..where(db.purchaseRecords.supplierId.equals(supplierId)))
        .getSingle();
    final int totalPurchasesDue =
        purchasesDue.read(db.purchaseRecords.dueMinor.sum()) ?? 0;

    final payments = await (db.selectOnly(db.partyPayments)
          ..addColumns([db.partyPayments.amountMinor.sum()])
          ..where(db.partyPayments.partyId.equals(supplierId) &
              db.partyPayments.partyType.equals('supplier')))
        .getSingle();
    final int totalPayments =
        payments.read(db.partyPayments.amountMinor.sum()) ?? 0;

    return supplier.openingBalanceMinor + totalPurchasesDue - totalPayments;
  }

  // --- Party Payments ---
  Future<int> insertPartyPayment(PartyPaymentsCompanion payment) {
    return db.into(db.partyPayments).insert(payment);
  }

  Stream<List<PartyPayment>> watchPartyPayments(String businessId, {String? partyId}) {
    var query = db.select(db.partyPayments)
      ..where((tbl) => tbl.businessId.equals(businessId));
    if (partyId != null) {
      query = query..where((tbl) => tbl.partyId.equals(partyId));
    }
    return (query..orderBy([(t) => OrderingTerm.desc(t.paymentDate)])).watch();
  }

  // --- Sales Records & Details ---
  Stream<List<SalesRecord>> watchSales(String businessId) {
    return (db.select(db.salesRecords)
          ..where((tbl) => tbl.businessId.equals(businessId))
          ..orderBy([(t) => OrderingTerm.desc(t.saleDate)]))
        .watch();
  }

  Future<List<SalesRecord>> getSales(
    String businessId, {
    int? startDate,
    int? endDate,
    String? saleType,
  }) async {
    var query = db.select(db.salesRecords)
      ..where((tbl) => tbl.businessId.equals(businessId));
    if (startDate != null) {
      query = query..where((tbl) => tbl.saleDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query = query..where((tbl) => tbl.saleDate.isSmallerOrEqualValue(endDate));
    }
    if (saleType != null) {
      query = query..where((tbl) => tbl.saleType.equals(saleType));
    }
    return (query..orderBy([(t) => OrderingTerm.desc(t.saleDate)])).get();
  }

  Future<List<SalesItem>> getSaleItems(String saleId) {
    return (db.select(db.salesItems)
          ..where((tbl) => tbl.saleId.equals(saleId)))
        .get();
  }

  // --- Purchase Records & Details ---
  Stream<List<PurchaseRecord>> watchPurchases(String businessId) {
    return (db.select(db.purchaseRecords)
          ..where((tbl) => tbl.businessId.equals(businessId))
          ..orderBy([(t) => OrderingTerm.desc(t.purchaseDate)]))
        .watch();
  }

  Future<List<PurchaseRecord>> getPurchases(
    String businessId, {
    int? startDate,
    int? endDate,
  }) async {
    var query = db.select(db.purchaseRecords)
      ..where((tbl) => tbl.businessId.equals(businessId));
    if (startDate != null) {
      query =
          query..where((tbl) => tbl.purchaseDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query = query..where((tbl) => tbl.purchaseDate.isSmallerOrEqualValue(endDate));
    }
    return (query..orderBy([(t) => OrderingTerm.desc(t.purchaseDate)])).get();
  }

  Future<List<PurchaseItem>> getPurchaseItems(String purchaseId) {
    return (db.select(db.purchaseItems)
          ..where((tbl) => tbl.purchaseId.equals(purchaseId)))
        .get();
  }

  // --- Cash Sessions ---
  Stream<List<CashSession>> watchCashSessions(String businessId) {
    return (db.select(db.cashSessions)
          ..where((tbl) => tbl.businessId.equals(businessId))
          ..orderBy([(t) => OrderingTerm.desc(t.sessionDate)]))
        .watch();
  }

  Future<CashSession?> getOpenCashSession(String businessId) {
    return (db.select(db.cashSessions)
          ..where((tbl) =>
              tbl.businessId.equals(businessId) & tbl.status.equals('open'))
          ..orderBy([(t) => OrderingTerm.desc(t.sessionDate)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> openCashSession(CashSessionsCompanion session) {
    return db.into(db.cashSessions).insert(session);
  }

  Future<bool> closeCashSession({
    required String sessionId,
    required int actualClosingMinor,
    required int differenceMinor,
    String? notes,
    required int closedAt,
  }) async {
    final updated = await (db.update(db.cashSessions)
          ..where((t) => t.id.equals(sessionId)))
        .write(CashSessionsCompanion(
      actualClosingMinor: Value(actualClosingMinor),
      differenceMinor: Value(differenceMinor),
      status: const Value('closed'),
      notes: notes != null ? Value(notes) : const Value.absent(),
      closedAt: Value(closedAt),
    ));
    return updated > 0;
  }

  // --- Accurate Financial Metrics ---
  /// Gross Profit = Net Sales - COGS (Cost of Goods Sold)
  /// Net Profit = Gross Profit - Operating Expenses
  Future<BusinessMetricsResult> calculateMetrics(
    String businessId, {
    int? startDate,
    int? endDate,
  }) async {
    final business = await getBusinessById(businessId);
    if (business == null) {
      return BusinessMetricsResult.zero();
    }
    final initialCapital = business.initialCapitalMinor;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;
    final monthStart = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999).millisecondsSinceEpoch;
    final yearStart = DateTime(now.year, 1, 1).millisecondsSinceEpoch;

    // All sales for this business
    final allSales = await getSales(businessId);

    int totalSales = 0;
    int totalSalesCount = 0;
    int todaySales = 0;
    int todaySalesCount = 0;
    int monthlySales = 0;
    int monthlySalesCount = 0;
    int yearlySales = 0;
    int retailSales = 0;
    int wholesaleSales = 0;
    int quickSales = 0;

    int totalCogs = 0;
    int todayCogs = 0;
    int monthlyCogs = 0;

    for (var sale in allSales) {
      final sDate = sale.saleDate;
      final isToday = sDate >= todayStart && sDate <= todayEnd;
      final isThisMonth = sDate >= monthStart && sDate <= monthEnd;
      final isThisYear = sDate >= yearStart;

      // Filter check for selected period
      final inFilter = (startDate == null || sDate >= startDate) &&
          (endDate == null || sDate <= endDate);

      if (isToday) {
        todaySales += sale.totalMinor;
        todaySalesCount++;
      }
      if (isThisMonth) {
        monthlySales += sale.totalMinor;
        monthlySalesCount++;
      }
      if (isThisYear) {
        yearlySales += sale.totalMinor;
      }

      // Compute COGS from items
      final items = await getSaleItems(sale.id);
      int saleCogs = 0;
      for (var item in items) {
        final baseQty =
            item.baseQuantity > 0 ? item.baseQuantity : item.quantity;
        saleCogs += (baseQty * item.unitCostMinor).round();
      }

      if (isToday) todayCogs += saleCogs;
      if (isThisMonth) monthlyCogs += saleCogs;

      if (inFilter) {
        totalSales += sale.totalMinor;
        totalSalesCount++;
        totalCogs += saleCogs;

        if (sale.saleType == 'wholesale') {
          wholesaleSales += sale.totalMinor;
        } else if (sale.saleType == 'quick_sale') {
          quickSales += sale.totalMinor;
        } else {
          retailSales += sale.totalMinor;
        }
      }
    }

    // Purchases
    final allPurchases = await getPurchases(businessId);
    int totalPurchases = 0;
    int todayPurchases = 0;
    int monthlyPurchases = 0;

    for (var p in allPurchases) {
      final pDate = p.purchaseDate;
      if (pDate >= todayStart && pDate <= todayEnd) {
        todayPurchases += p.totalMinor;
      }
      if (pDate >= monthStart && pDate <= monthEnd) {
        monthlyPurchases += p.totalMinor;
      }
      if ((startDate == null || pDate >= startDate) &&
          (endDate == null || pDate <= endDate)) {
        totalPurchases += p.totalMinor;
      }
    }

    // Operating expenses (excluding purchase records)
    final allExpenses = await (db.select(db.transactions)
          ..where((tbl) =>
              tbl.businessId.equals(businessId) &
              tbl.transactionType.equals('expense') &
              tbl.deletedAt.isNull() &
              (tbl.sourceType.isNull() | tbl.sourceType.equals('manual'))))
        .get();

    int totalExpenses = 0;
    int todayExpenses = 0;
    int monthlyExpenses = 0;

    for (var e in allExpenses) {
      final eDate = e.transactionDate;
      if (eDate >= todayStart && eDate <= todayEnd) {
        todayExpenses += e.amountMinor;
      }
      if (eDate >= monthStart && eDate <= monthEnd) {
        monthlyExpenses += e.amountMinor;
      }
      if ((startDate == null || eDate >= startDate) &&
          (endDate == null || eDate <= endDate)) {
        totalExpenses += e.amountMinor;
      }
    }

    // Gross Profit & Net Profit strictly following financial standards
    final int grossProfit = totalSales - totalCogs;
    final int todayGrossProfit = todaySales - todayCogs;
    final int monthlyGrossProfit = monthlySales - monthlyCogs;

    final int netProfit = grossProfit - totalExpenses;
    final int todayNetProfit = todayGrossProfit - todayExpenses;
    final int monthlyNetProfit = monthlyGrossProfit - monthlyExpenses;

    // Receivables
    int receivables = 0;
    final customers = await getAllCustomers(businessId);
    for (var c in customers) {
      receivables += await getCustomerOutstandingDue(c.id);
    }
    // Also include any sales dues where customer was unassigned/walk-in
    final unlinkedSalesDue = await (db.selectOnly(db.salesRecords)
          ..addColumns([db.salesRecords.dueMinor.sum()])
          ..where(db.salesRecords.businessId.equals(businessId) &
              db.salesRecords.customerId.isNull()))
        .getSingle();
    receivables += unlinkedSalesDue.read(db.salesRecords.dueMinor.sum()) ?? 0;

    // Payables
    int payables = 0;
    final suppliers = await getAllSuppliers(businessId);
    for (var s in suppliers) {
      payables += await getSupplierOutstandingPayable(s.id);
    }

    // Inventory Value & Counts
    int invValue = 0;
    double totalStock = 0.0;
    int lowStock = 0;
    int outOfStock = 0;

    final prods = await (db.select(db.products)
          ..where((tbl) =>
              tbl.businessId.equals(businessId) & tbl.isActive.equals(1)))
        .get();

    for (var p in prods) {
      final movements = await (db.select(db.inventoryMovements)
            ..where((tbl) => tbl.productId.equals(p.id)))
          .get();
      double netMovements = 0.0;
      for (var m in movements) {
        if (m.movementType == 'in' ||
            m.movementType == 'purchase' ||
            m.movementType == 'return') {
          netMovements += m.quantity;
        } else if (m.movementType == 'out' ||
            m.movementType == 'sale' ||
            m.movementType == 'wholesale_sale' ||
            m.movementType == 'damage' ||
            m.movementType == 'wastage') {
          netMovements -= m.quantity;
        } else if (m.movementType == 'adjustment') {
          netMovements += m.quantity;
        }
      }
      final stock = p.openingQuantity + netMovements;
      totalStock += stock;
      if (stock <= 0) {
        outOfStock++;
      } else if (stock <= p.minimumStock) {
        lowStock++;
      }

      if (stock > 0) {
        invValue += (stock * p.purchasePriceMinor).round();
      }
    }

    return BusinessMetricsResult(
      totalInvestmentMinor: initialCapital,
      totalSalesMinor: totalSales,
      totalSalesCount: totalSalesCount,
      todaySalesMinor: todaySales,
      todaySalesCount: todaySalesCount,
      monthlySalesMinor: monthlySales,
      monthlySalesCount: monthlySalesCount,
      yearlySalesMinor: yearlySales,
      retailSalesMinor: retailSales,
      wholesaleSalesMinor: wholesaleSales,
      quickSalesMinor: quickSales,
      totalPurchasesMinor: totalPurchases,
      todayPurchasesMinor: todayPurchases,
      monthlyPurchasesMinor: monthlyPurchases,
      cogsMinor: totalCogs,
      todayCogsMinor: todayCogs,
      monthlyCogsMinor: monthlyCogs,
      operatingExpensesMinor: totalExpenses,
      todayExpensesMinor: todayExpenses,
      monthlyExpensesMinor: monthlyExpenses,
      grossProfitMinor: grossProfit,
      todayGrossProfitMinor: todayGrossProfit,
      monthlyGrossProfitMinor: monthlyGrossProfit,
      netProfitMinor: netProfit,
      todayNetProfitMinor: todayNetProfit,
      monthlyNetProfitMinor: monthlyNetProfit,
      inventoryValueMinor: invValue,
      totalStockQuantity: totalStock,
      totalProductsCount: prods.length,
      lowStockCount: lowStock,
      outOfStockCount: outOfStock,
      customerReceivablesMinor: receivables,
      totalCustomersCount: customers.length,
      supplierPayablesMinor: payables,
      totalSuppliersCount: suppliers.length,
    );
  }

  /// Calculates category-wise sales breakdown for business within date range
  Future<List<CategorySalesResult>> getCategoryWiseSales(
    String businessId, {
    int? startDate,
    int? endDate,
  }) async {
    final sales = await getSales(businessId, startDate: startDate, endDate: endDate);
    final Map<String, int> categoryTotals = {};
    final Map<String, int> categoryCounts = {};
    final Map<String, String> categoryNames = {};

    for (var sale in sales) {
      final items = await getSaleItems(sale.id);
      for (var item in items) {
        String catId = 'uncategorized';
        String catName = 'সাধারণ / অন্যান্য';

        if (item.productId != null) {
          final prod = await (db.select(db.products)..where((tbl) => tbl.id.equals(item.productId!))).getSingleOrNull();
          if (prod?.categoryId != null) {
            catId = prod!.categoryId!;
            if (!categoryNames.containsKey(catId)) {
              final cat = await (db.select(db.categories)..where((tbl) => tbl.id.equals(catId))).getSingleOrNull();
              categoryNames[catId] = cat?.nameBn ?? cat?.nameEn ?? 'ক্যাটাগরি';
            }
            catName = categoryNames[catId]!;
          }
        }

        categoryTotals[catId] = (categoryTotals[catId] ?? 0) + item.totalMinor;
        categoryCounts[catId] = (categoryCounts[catId] ?? 0) + 1;
        categoryNames[catId] = catName;
      }
    }

    final results = categoryTotals.entries.map((e) {
      return CategorySalesResult(
        categoryId: e.key,
        categoryName: categoryNames[e.key] ?? 'ক্যাটাগরি',
        totalSalesMinor: e.value,
        itemCount: categoryCounts[e.key] ?? 0,
      );
    }).toList();

    results.sort((a, b) => b.totalSalesMinor.compareTo(a.totalSalesMinor));
    return results;
  }

  /// Returns top-selling products for business within date range
  Future<List<TopProductResult>> getTopSellingProducts(
    String businessId, {
    int? startDate,
    int? endDate,
    int limit = 5,
  }) async {
    final sales = await getSales(businessId, startDate: startDate, endDate: endDate);
    final Map<String, double> prodQuantities = {};
    final Map<String, int> prodTotals = {};
    final Map<String, String> prodNames = {};
    final Map<String, String> prodUnits = {};

    for (var sale in sales) {
      final items = await getSaleItems(sale.id);
      for (var item in items) {
        final key = item.productId ?? item.productName ?? 'unknown';
        final name = item.productName ?? 'পণ্য';
        final unit = item.unit ?? 'পিস';
        final qty = item.baseQuantity > 0 ? item.baseQuantity : item.quantity;

        prodQuantities[key] = (prodQuantities[key] ?? 0.0) + qty;
        prodTotals[key] = (prodTotals[key] ?? 0) + item.totalMinor;
        prodNames[key] = name;
        prodUnits[key] = unit;
      }
    }

    final results = prodTotals.entries.map((e) {
      return TopProductResult(
        productId: e.key,
        productName: prodNames[e.key] ?? 'পণ্য',
        quantitySold: prodQuantities[e.key] ?? 0.0,
        unit: prodUnits[e.key] ?? 'পিস',
        totalSalesMinor: e.value,
      );
    }).toList();

    results.sort((a, b) => b.totalSalesMinor.compareTo(a.totalSalesMinor));
    return results.take(limit).toList();
  }
}

class CategorySalesResult {
  final String categoryId;
  final String categoryName;
  final int totalSalesMinor;
  final int itemCount;

  CategorySalesResult({
    required this.categoryId,
    required this.categoryName,
    required this.totalSalesMinor,
    required this.itemCount,
  });
}

class TopProductResult {
  final String productId;
  final String productName;
  final double quantitySold;
  final String unit;
  final int totalSalesMinor;

  TopProductResult({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.unit,
    required this.totalSalesMinor,
  });
}
