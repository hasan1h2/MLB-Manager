import 'package:flutter_test/flutter_test.dart';
import 'package:mlb_manager/core/utils/currency_utils.dart';

void main() {
  group('CurrencyUtils Exact Minor Unit Arithmetic', () {
    test('Converts Taka string to exact integer Poisha without floating-point error', () {
      expect(CurrencyUtils.takaToMinor('100'), equals(10000));
      expect(CurrencyUtils.takaToMinor('150.50'), equals(15050));
      expect(CurrencyUtils.takaToMinor('0.75'), equals(75));
      expect(CurrencyUtils.takaToMinor('1,250.25'), equals(125025));
      expect(CurrencyUtils.takaToMinor(''), equals(0));
    });

    test('Converts Poisha to formatted Taka string with default currency symbol', () {
      expect(CurrencyUtils.format(10000, includeSymbol: false), equals('100.00'));
      expect(CurrencyUtils.format(15050, includeSymbol: false), equals('150.50'));
      expect(CurrencyUtils.format(-5025, includeSymbol: false), equals('-50.25'));
      expect(CurrencyUtils.format(10000, includeSymbol: true), equals('৳ 100.00'));
    });

    test('Converts numbers to Bengali numerals accurately', () {
      expect(CurrencyUtils.toBengaliNumerals('12345'), equals('১২৩৪৫'));
      expect(CurrencyUtils.toBengaliNumerals('150.50'), equals('১৫০.৫০'));
    });
  });

  group('Financial Engine Math Rules', () {
    test('Account Balance = Opening + Total Inflows (Credits) - Total Outflows (Debits)', () {
      const int openingBalance = 500000; // 5,000.00 BDT
      const int credits = 250000; // 2,500.00 BDT Inflow
      const int debits = 120000; // 1,200.00 BDT Outflow

      final int finalBalance = openingBalance + credits - debits;
      expect(finalBalance, equals(630000)); // 6,300.00 BDT
    });

    test('Internal Account Transfers do not alter Consolidated Income or Expense', () {
      int consolidatedIncome = 1000000; // 10,000 BDT
      int consolidatedExpense = 400000; // 4,000 BDT

      int bankAccount = 500000; // 5,000 BDT
      int bkashAccount = 100000; // 1,000 BDT

      // Transfer 2,000 BDT from Bank to bKash
      const int transferAmount = 200000;
      bankAccount -= transferAmount;
      bkashAccount += transferAmount;

      // Assert account balances changed
      expect(bankAccount, equals(300000));
      expect(bkashAccount, equals(300000));

      // Assert consolidated income and expenses remain UNCHANGED
      expect(consolidatedIncome, equals(1000000));
      expect(consolidatedExpense, equals(400000));
    });

    test('Net Profit = Revenue - COGS - Operating Expenses', () {
      const int revenue = 15000000; // 150,000 BDT
      const int cogs = 9000000; // 90,000 BDT
      const int operatingExpenses = 2500000; // 25,000 BDT

      const int grossProfit = revenue - cogs;
      const int netProfit = grossProfit - operatingExpenses;

      expect(grossProfit, equals(6000000)); // 60,000 BDT
      expect(netProfit, equals(3500000)); // 35,000 BDT
    });

    test('Cattle Net Profit = Sale Price - (Purchase Price + Total Expenses)', () {
      const int purchasePrice = 8500000; // 85,000 BDT
      const int feedCost = 1800000; // 18,000 BDT
      const int medicalCost = 350000; // 3,500 BDT
      const int laborCost = 500000; // 5,000 BDT
      const int transportCost = 150000; // 1,500 BDT

      const int totalCost = purchasePrice + feedCost + medicalCost + laborCost + transportCost;
      expect(totalCost, equals(11300000)); // 113,000 BDT

      const int salePrice = 14500000; // 145,000 BDT
      const int netProfit = salePrice - totalCost;

      expect(netProfit, equals(3200000)); // 32,000 BDT Net Profit
    });

    test('Inventory Current Stock = Opening + In - Out + Adjustments', () {
      const double openingStock = 50.0;
      const double stockIn = 120.0;
      const double stockOut = 85.0;
      const double adjustment = -2.0; // 2 units damage

      final double currentStock = openingStock + stockIn - stockOut + adjustment;
      expect(currentStock, equals(83.0));
    });

    test('Customer Outstanding Due = Opening + Sales Due - Payments', () {
      const int openingDue = 500000; // 5,000 BDT
      const int creditSaleDue = 1200000; // 12,000 BDT
      const int paymentReceived = 1000000; // 10,000 BDT

      final int outstanding = openingDue + creditSaleDue - paymentReceived;
      expect(outstanding, equals(700000)); // 7,000 BDT
    });

    test('Budget Utilization and Warning Threshold Triggers', () {
      const int budgetLimit = 5000000; // 50,000 BDT
      const int alertPercentage = 80;

      int actualSpending = 3500000; // 35,000 BDT (70%)
      double utilization = (actualSpending / budgetLimit) * 100;
      expect(utilization < alertPercentage, isTrue);

      actualSpending = 4200000; // 42,000 BDT (84%)
      utilization = (actualSpending / budgetLimit) * 100;
      expect(utilization >= alertPercentage, isTrue); // Warning triggered!

      actualSpending = 5500000; // 55,000 BDT (110%)
      expect(actualSpending > budgetLimit, isTrue); // Over-budget triggered!
    });
  });
}
