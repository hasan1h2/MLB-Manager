import 'package:drift/drift.dart';
import '../app_database.dart';

class BusinessMetricsResult {
  final int totalInvestmentMinor;
  final int totalSalesMinor;
  final int retailSalesMinor;
  final int wholesaleSalesMinor;
  final int quickSalesMinor;
  final int totalPurchasesMinor;
  final int cogsMinor;
  final int operatingExpensesMinor;
  final int grossProfitMinor;
  final int netProfitMinor;
  final int inventoryValueMinor;
  final int customerReceivablesMinor;
  final int supplierPayablesMinor;

  BusinessMetricsResult({
    required this.totalInvestmentMinor,
    required this.totalSalesMinor,
    required this.retailSalesMinor,
    required this.wholesaleSalesMinor,
    required this.quickSalesMinor,
    required this.totalPurchasesMinor,
    required this.cogsMinor,
    required this.operatingExpensesMinor,
    required this.grossProfitMinor,
    required this.netProfitMinor,
    required this.inventoryValueMinor,
    required this.customerReceivablesMinor,
    required this.supplierPayablesMinor,
  });
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
    final initialCapital = business?.initialCapitalMinor ?? 0;

    // Filtered sales
    final salesList = await getSales(businessId,
        startDate: startDate, endDate: endDate);

    int totalSales = 0;
    int retailSales = 0;
    int wholesaleSales = 0;
    int quickSales = 0;
    int cogs = 0;

    for (var sale in salesList) {
      totalSales += sale.totalMinor;
      if (sale.saleType == 'wholesale') {
        wholesaleSales += sale.totalMinor;
      } else if (sale.saleType == 'quick_sale') {
        quickSales += sale.totalMinor;
      } else {
        retailSales += sale.totalMinor;
      }

      // Compute COGS from items
      final items = await getSaleItems(sale.id);
      for (var item in items) {
        cogs += (item.quantity * item.unitCostMinor).round();
      }
    }

    // Purchases
    final purchasesList = await getPurchases(businessId,
        startDate: startDate, endDate: endDate);
    int totalPurchases = 0;
    for (var p in purchasesList) {
      totalPurchases += p.totalMinor;
    }

    // Operating expenses (excluding purchase records to prevent double counting)
    var expQuery = db.select(db.transactions)
      ..where((tbl) =>
          tbl.businessId.equals(businessId) &
          tbl.transactionType.equals('expense') &
          tbl.deletedAt.isNull() &
          (tbl.sourceType.isNull() | tbl.sourceType.equals('manual')));
    if (startDate != null) {
      expQuery =
          expQuery..where((tbl) => tbl.transactionDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      expQuery =
          expQuery..where((tbl) => tbl.transactionDate.isSmallerOrEqualValue(endDate));
    }
    final expenses = await expQuery.get();
    int operatingExpenses = 0;
    for (var e in expenses) {
      operatingExpenses += e.amountMinor;
    }

    // Gross Profit & Net Profit strictly following financial standards
    final int grossProfit = totalSales - cogs;
    final int netProfit = grossProfit - operatingExpenses;

    // Receivables
    int receivables = 0;
    final customers = await getAllCustomers(businessId);
    for (var c in customers) {
      receivables += await getCustomerOutstandingDue(c.id);
    }

    // Payables
    int payables = 0;
    final suppliers = await getAllSuppliers(businessId);
    for (var s in suppliers) {
      payables += await getSupplierOutstandingPayable(s.id);
    }

    // Inventory Value
    int invValue = 0;
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
            m.movementType == 'damage' ||
            m.movementType == 'wastage') {
          netMovements -= m.quantity;
        } else if (m.movementType == 'adjustment') {
          netMovements += m.quantity;
        }
      }
      final stock = p.openingQuantity + netMovements;
      if (stock > 0) {
        invValue += (stock * p.purchasePriceMinor).round();
      }
    }

    return BusinessMetricsResult(
      totalInvestmentMinor: initialCapital,
      totalSalesMinor: totalSales,
      retailSalesMinor: retailSales,
      wholesaleSalesMinor: wholesaleSales,
      quickSalesMinor: quickSales,
      totalPurchasesMinor: totalPurchases,
      cogsMinor: cogs,
      operatingExpensesMinor: operatingExpenses,
      grossProfitMinor: grossProfit,
      netProfitMinor: netProfit,
      inventoryValueMinor: invValue,
      customerReceivablesMinor: receivables,
      supplierPayablesMinor: payables,
    );
  }
}
