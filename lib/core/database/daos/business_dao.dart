import 'package:drift/drift.dart';
import '../app_database.dart';

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

  /// Customer Outstanding Due = Opening + Credit Sales Due - Payments Received
  Future<int> getCustomerOutstandingDue(String customerId) async {
    final customer = await getCustomerById(customerId);
    if (customer == null) return 0;

    // Total sales due to this customer
    final salesDue = await (db.selectOnly(db.salesRecords)
          ..addColumns([db.salesRecords.dueMinor.sum()])
          ..where(db.salesRecords.customerId.equals(customerId)))
        .getSingle();
    final int totalSalesDue =
        salesDue.read(db.salesRecords.dueMinor.sum()) ?? 0;

    // Direct party payments
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
}
