import 'package:drift/drift.dart';
import '../app_database.dart';

class LoanDao {
  final AppDatabase db;
  LoanDao(this.db);

  Stream<List<LoanAccount>> watchLoans({String? loanType, String? status}) {
    var query = db.select(db.loanAccounts);
    if (loanType != null) {
      query = query..where((tbl) => tbl.loanType.equals(loanType));
    }
    if (status != null) {
      query = query..where((tbl) => tbl.status.equals(status));
    }
    return (query..orderBy([(tbl) => OrderingTerm.desc(tbl.startDate)])).watch();
  }

  Future<List<LoanAccount>> getLoans({String? loanType, String? status}) {
    var query = db.select(db.loanAccounts);
    if (loanType != null) {
      query = query..where((tbl) => tbl.loanType.equals(loanType));
    }
    if (status != null) {
      query = query..where((tbl) => tbl.status.equals(status));
    }
    return (query..orderBy([(tbl) => OrderingTerm.desc(tbl.startDate)])).get();
  }

  Future<LoanAccount?> getLoanById(String id) {
    return (db.select(db.loanAccounts)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertLoan(LoanAccountsCompanion loan) {
    return db.into(db.loanAccounts).insert(loan);
  }

  Future<bool> updateLoan(LoanAccount loan) {
    return db.update(db.loanAccounts).replace(loan);
  }

  // --- Loan Payments ---
  Stream<List<LoanPayment>> watchLoanPayments(String loanId) {
    return (db.select(db.loanPayments)
          ..where((tbl) => tbl.loanId.equals(loanId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.paymentDate)]))
        .watch();
  }

  Future<List<LoanPayment>> getLoanPayments(String loanId) {
    return (db.select(db.loanPayments)
          ..where((tbl) => tbl.loanId.equals(loanId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.paymentDate)]))
        .get();
  }

  /// Calculates remaining loan balance:
  /// Remaining Principal = Principal - Total Principal Paid
  Future<int> getLoanRemainingPrincipal(String loanId) async {
    final loan = await getLoanById(loanId);
    if (loan == null) return 0;

    final payments = await (db.selectOnly(db.loanPayments)
          ..addColumns([db.loanPayments.principalPaidMinor.sum()])
          ..where(db.loanPayments.loanId.equals(loanId)))
        .getSingle();
    final int totalPaid = payments.read(db.loanPayments.principalPaidMinor.sum()) ?? 0;

    final remaining = loan.principalMinor - totalPaid;
    return remaining < 0 ? 0 : remaining;
  }

  Future<void> recordLoanPayment({
    required LoanPaymentsCompanion payment,
    TransactionsCompanion? linkedTransaction,
    List<TransactionEntriesCompanion>? journalEntries,
  }) async {
    await db.transaction(() async {
      await db.into(db.loanPayments).insert(payment);
      if (linkedTransaction != null && journalEntries != null) {
        await db.into(db.transactions).insert(linkedTransaction);
        for (var entry in journalEntries) {
          await db.into(db.transactionEntries).insert(entry);
        }
      }

      // Check if loan is now fully settled
      final remaining = await getLoanRemainingPrincipal(payment.loanId.value);
      if (remaining <= 0) {
        await (db.update(db.loanAccounts)..where((tbl) => tbl.id.equals(payment.loanId.value)))
            .write(const LoanAccountsCompanion(status: Value('settled')));
      }
    });
  }
}
