import 'package:drift/drift.dart';
import '../app_database.dart';

class AssetDao {
  final AppDatabase db;
  AssetDao(this.db);

  // --- Assets ---
  Stream<List<Asset>> watchAssets() {
    return (db.select(db.assets)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.purchaseDate)]))
        .watch();
  }

  Future<List<Asset>> getAllAssets() {
    return (db.select(db.assets)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.purchaseDate)]))
        .get();
  }

  Future<int> insertAsset(AssetsCompanion asset) {
    return db.into(db.assets).insert(asset);
  }

  // --- Savings Goals ---
  Stream<List<SavingsGoal>> watchSavingsGoals() {
    return (db.select(db.savingsGoals)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.targetDate)]))
        .watch();
  }

  Future<List<SavingsGoal>> getAllSavingsGoals() {
    return (db.select(db.savingsGoals)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.targetDate)]))
        .get();
  }

  Future<int> insertSavingsGoal(SavingsGoalsCompanion goal) {
    return db.into(db.savingsGoals).insert(goal);
  }

  Future<void> updateSavingsGoalAmount(
      String goalId, int newAmountMinor) async {
    await (db.update(db.savingsGoals)..where((tbl) => tbl.id.equals(goalId)))
        .write(
            SavingsGoalsCompanion(currentAmountMinor: Value(newAmountMinor)));
  }

  // --- Investments ---
  Stream<List<Investment>> watchInvestments() {
    return (db.select(db.investments)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.investmentDate)]))
        .watch();
  }

  Future<List<Investment>> getAllInvestments() {
    return (db.select(db.investments)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.investmentDate)]))
        .get();
  }

  Future<int> insertInvestment(InvestmentsCompanion investment) {
    return db.into(db.investments).insert(investment);
  }
}
