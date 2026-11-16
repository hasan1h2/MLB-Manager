import 'package:drift/drift.dart';
import '../app_database.dart';

class CattleDao {
  final AppDatabase db;
  CattleDao(this.db);

  Stream<List<CattleData>> watchCattleList(String businessId, {String? status}) {
    var query = db.select(db.cattle)..where((tbl) => tbl.businessId.equals(businessId));
    if (status != null) {
      query = query..where((tbl) => tbl.status.equals(status));
    }
    return (query..orderBy([(tbl) => OrderingTerm.desc(tbl.purchaseDate)])).watch();
  }

  Future<List<CattleData>> getCattleList(String businessId, {String? status}) {
    var query = db.select(db.cattle)..where((tbl) => tbl.businessId.equals(businessId));
    if (status != null) {
      query = query..where((tbl) => tbl.status.equals(status));
    }
    return (query..orderBy([(tbl) => OrderingTerm.desc(tbl.purchaseDate)])).get();
  }

  Future<CattleData?> getCattleById(String id) {
    return (db.select(db.cattle)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertCattle(CattleCompanion cattle) {
    return db.into(db.cattle).insert(cattle);
  }

  Future<bool> updateCattle(CattleData cattle) {
    return db.update(db.cattle).replace(cattle);
  }

  // --- Cattle Expenses ---
  Stream<List<CattleExpense>> watchCattleExpenses(String cattleId) {
    return (db.select(db.cattleExpenses)
          ..where((tbl) => tbl.cattleId.equals(cattleId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.expenseDate)]))
        .watch();
  }

  Future<List<CattleExpense>> getCattleExpenses(String cattleId) {
    return (db.select(db.cattleExpenses)
          ..where((tbl) => tbl.cattleId.equals(cattleId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.expenseDate)]))
        .get();
  }

  Future<int> insertCattleExpense(CattleExpensesCompanion expense) {
    return db.into(db.cattleExpenses).insert(expense);
  }

  // --- Cattle Sales ---
  Future<CattleSale?> getCattleSale(String cattleId) {
    return (db.select(db.cattleSales)..where((tbl) => tbl.cattleId.equals(cattleId))).getSingleOrNull();
  }

  Future<void> recordCattleSale({
    required CattleSalesCompanion sale,
  }) async {
    await db.transaction(() async {
      await db.into(db.cattleSales).insert(sale);
      await (db.update(db.cattle)..where((tbl) => tbl.id.equals(sale.cattleId.value)))
          .write(const CattleCompanion(status: Value('sold')));
    });
  }

  /// Calculates individual cattle profitability:
  /// Total Cost = Purchase Price + Sum(Feed + Medical + Vet + Labor + Other)
  /// Net Profit = Sale Price - Total Cost
  Future<CattleProfitCalculation> calculateCattleProfit(String cattleId) async {
    final cattle = await getCattleById(cattleId);
    if (cattle == null) {
      return CattleProfitCalculation(
        purchasePriceMinor: 0,
        totalExpensesMinor: 0,
        totalCostMinor: 0,
        salePriceMinor: 0,
        netProfitMinor: 0,
        isSold: false,
      );
    }

    final expenses = await getCattleExpenses(cattleId);
    int totalExpensesMinor = 0;
    for (var exp in expenses) {
      totalExpensesMinor += exp.amountMinor;
    }

    final int totalCostMinor = cattle.purchasePriceMinor + totalExpensesMinor;

    final sale = await getCattleSale(cattleId);
    final int salePriceMinor = sale?.salePriceMinor ?? 0;
    final bool isSold = sale != null;
    final int netProfitMinor = isSold ? (salePriceMinor - totalCostMinor) : 0;

    return CattleProfitCalculation(
      purchasePriceMinor: cattle.purchasePriceMinor,
      totalExpensesMinor: totalExpensesMinor,
      totalCostMinor: totalCostMinor,
      salePriceMinor: salePriceMinor,
      netProfitMinor: netProfitMinor,
      isSold: isSold,
    );
  }
}

class CattleProfitCalculation {
  final int purchasePriceMinor;
  final int totalExpensesMinor;
  final int totalCostMinor;
  final int salePriceMinor;
  final int netProfitMinor;
  final bool isSold;

  CattleProfitCalculation({
    required this.purchasePriceMinor,
    required this.totalExpensesMinor,
    required this.totalCostMinor,
    required this.salePriceMinor,
    required this.netProfitMinor,
    required this.isSold,
  });
}
