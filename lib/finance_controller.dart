
import 'package:flutter/material.dart';

class FinanceTransaction {
  final String title;
  final String category;
  final double amount;
  final String type;
  final DateTime date;

  FinanceTransaction({
    required this.title,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
  });

  bool get isIncome => type == 'Income';
  bool get isExpense => type == 'Expense';
}

class FinanceController extends ChangeNotifier {
  final String workspace;
  final List<FinanceTransaction> _transactions = [];

  FinanceController({required this.workspace}) {
    _loadSampleTransactions();
  }

  List<FinanceTransaction> get transactions =>
      List.unmodifiable(_transactions);

  double get totalIncome {
    return _transactions
        .where((transaction) => transaction.isIncome)
        .fold(0.0, (total, transaction) => total + transaction.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((transaction) => transaction.isExpense)
        .fold(0.0, (total, transaction) => total + transaction.amount);
  }

  double get balance => totalIncome - totalExpenses;

  double get savingsRate {
    if (totalIncome == 0) return 0;
    return (balance / totalIncome) * 100;
  }

  void addTransaction({
    required String title,
    required String category,
    required double amount,
    required String type,
    required DateTime date,
  }) {
    _transactions.insert(
      0,
      FinanceTransaction(
        title: title,
        category: category,
        amount: amount,
        type: type,
        date: date,
      ),
    );

    notifyListeners();
  }

  void deleteTransaction(FinanceTransaction transaction) {
    _transactions.remove(transaction);
    notifyListeners();
  }

  void _loadSampleTransactions() {
    if (workspace == 'Business') {
      _transactions.addAll([
        FinanceTransaction(
          title: 'Product Sales',
          category: 'Sales',
          amount: 150000,
          type: 'Income',
          date: DateTime(2026, 11, 1),
        ),
        FinanceTransaction(
          title: 'Service Revenue',
          category: 'Services',
          amount: 35000,
          type: 'Income',
          date: DateTime(2026, 11, 2),
        ),
        FinanceTransaction(
          title: 'Office Rent',
          category: 'Rent',
          amount: 25000,
          type: 'Expense',
          date: DateTime(2026, 11, 3),
        ),
        FinanceTransaction(
          title: 'Employee Salaries',
          category: 'Salary',
          amount: 40000,
          type: 'Expense',
          date: DateTime(2026, 11, 4),
        ),
        FinanceTransaction(
          title: 'Utility Bills',
          category: 'Utilities',
          amount: 7500,
          type: 'Expense',
          date: DateTime(2026, 11, 5),
        ),
      ]);
    } else {
      _transactions.addAll([
        FinanceTransaction(
          title: 'Monthly Salary',
          category: 'Salary',
          amount: 65000,
          type: 'Income',
          date: DateTime(2026, 11, 1),
        ),
        FinanceTransaction(
          title: 'House Rent',
          category: 'Housing',
          amount: 12000,
          type: 'Expense',
          date: DateTime(2026, 11, 2),
        ),
        FinanceTransaction(
          title: 'Groceries',
          category: 'Food',
          amount: 4500,
          type: 'Expense',
          date: DateTime(2026, 11, 3),
        ),
        FinanceTransaction(
          title: 'Freelance Project',
          category: 'Other Income',
          amount: 8000,
          type: 'Income',
          date: DateTime(2026, 11, 4),
        ),
      ]);
    }
  }
}
