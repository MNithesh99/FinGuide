
import 'package:flutter/material.dart';

import 'finance_controller.dart';
import 'budget_screen.dart';
import 'cash_flow_screen.dart';
import 'financial_insights_screen.dart';
import 'smooth_page_route.dart';
import 'workspace_sidebar.dart';

const Color txNavy = Color(0xFF14243A);
const Color txBlue = Color(0xFF3978F6);
const Color txBackground = Color(0xFFF5F7FB);
const Color txMuted = Color(0xFF718096);
const Color txBorder = Color(0xFFE8ECF2);
const Color txGreen = Color(0xFF16A36A);
const Color txRed = Color(0xFFE35D6A);

class TransactionsScreen extends StatefulWidget {
  final String workspace;
  final FinanceController controller;

  const TransactionsScreen({
    super.key,
    required this.workspace,
    required this.controller,
  });

  @override
  State<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';

  bool get isBusiness => widget.workspace == 'Business';

  List<FinanceTransaction> get filteredTransactions {
    return widget.controller.transactions.where((transaction) {
      final matchesFilter = selectedFilter == 'All' ||
          transaction.type == selectedFilter;

      final query = searchQuery.toLowerCase();

      final matchesSearch =
          transaction.title.toLowerCase().contains(query) ||
              transaction.category.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  void _openSection(Widget screen, String routeName) {
    final navigator = Navigator.of(context);

    navigator.popUntil(
      ModalRoute.withName('/dashboard'),
    );

    navigator.push(
      SmoothPageRoute(
        settings: RouteSettings(name: routeName),
        page: screen,
      ),
    );
  }

  void _navigate(String destination) {
    switch (destination) {
      case 'Dashboard':
        Navigator.of(context).popUntil(
          ModalRoute.withName('/dashboard'),
        );
        break;

      case 'Transactions':
        break;

      case 'Budget Planner':
        _openSection(
          BudgetScreen(
            workspace: widget.workspace,
            controller: widget.controller,
          ),
          '/budget',
        );
        break;

      case 'Cash Flow':
        _openSection(
          CashFlowScreen(
            workspace: widget.workspace,
            controller: widget.controller,
          ),
          '/cash-flow',
        );
        break;

      case 'Financial Insights':
        _openSection(
          FinancialInsightsScreen(
            workspace: widget.workspace,
            controller: widget.controller,
          ),
          '/financial-insights',
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$destination is coming soon.'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  void _goHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: txBackground,
      body: SafeArea(
        child: Row(
          children: [
            WorkspaceSidebar(
              selectedItem: 'Transactions',
              workspace: widget.workspace,
              onNavigate: _navigate,
              onHome: _goHome,
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.controller,
                builder: (context, child) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 25),
                        _buildSummary(),
                        const SizedBox(height: 25),
                        _buildTransactionPanel(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBusiness
                    ? 'Business Workspace'
                    : 'Personal Workspace',
                style: const TextStyle(
                  color: txMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Transactions',
                style: TextStyle(
                  color: txNavy,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isBusiness
                    ? 'Monitor your business income and expenses.'
                    : 'Keep track of your personal income and expenses.',
                style: const TextStyle(
                  color: txMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _showAddTransactionDialog,
          icon: const Icon(Icons.add, size: 19),
          label: const Text('Add Transaction'),
          style: ElevatedButton.styleFrom(
            backgroundColor: txNavy,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 850 ? 3 : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: columns == 3 ? 2.4 : 3.2,
          children: [
            _summaryCard(
              'Total Income',
              widget.controller.totalIncome,
              txGreen,
              Icons.trending_up,
            ),
            _summaryCard(
              'Total Expenses',
              widget.controller.totalExpenses,
              txRed,
              Icons.trending_down,
            ),
            _summaryCard(
              'Net Balance',
              widget.controller.balance,
              txBlue,
              Icons.account_balance_wallet_outlined,
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard(
      String title,
      double amount,
      Color color,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: txBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: txMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Text(
            formatAmount(amount),
            style: const TextStyle(
              color: txNavy,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: txBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Transactions',
            style: TextStyle(
              color: txNavy,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildFilters(),
          const SizedBox(height: 18),
          _buildTransactionList(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;

        return Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: txBackground,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 13),
            Row(
              mainAxisAlignment: compact
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                _filterButton('All'),
                const SizedBox(width: 8),
                _filterButton('Income'),
                const SizedBox(width: 8),
                _filterButton('Expense'),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _filterButton(String filter) {
    final selected = selectedFilter == filter;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? txNavy : Colors.white,
        foregroundColor: selected ? Colors.white : txMuted,
        side: BorderSide(
          color: selected ? txNavy : txBorder,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 11,
        ),
      ),
      child: Text(filter),
    );
  }

  Future<void> _confirmDeleteTransaction(
      FinanceTransaction transaction,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Transaction?'),
          content: Text(
            'Are you sure you want to delete "${transaction.title}"? '
                'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: txRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      widget.controller.deleteTransaction(transaction);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildTransactionList() {
    final items = filteredTransactions;

    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Text(
            'No transactions found.',
            style: TextStyle(color: txMuted),
          ),
        ),
      );
    }

    return Column(
      children: items.map((transaction) {
        final isIncome = transaction.isIncome;
        final color = isIncome ? txGreen : txRed;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: txBorder),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isIncome
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        color: txNavy,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${transaction.category} • '
                          '${_formatDate(transaction.date)}',
                      style: const TextStyle(
                        color: txMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}${formatAmount(transaction.amount)}',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Delete transaction',
                onPressed: () {
                  _confirmDeleteTransaction(transaction);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: txRed,
                  size: 21,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _showAddTransactionDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    String type = 'Expense';
    String category = 'Other';
    DateTime date = DateTime.now();

    final categories = isBusiness
        ? ['Sales', 'Services', 'Rent', 'Salary', 'Utilities', 'Other']
        : ['Salary', 'Food', 'Housing', 'Transport', 'Shopping', 'Other'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Transaction'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Transaction name',
                          hintText: 'e.g. Monthly salary',
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: amountController,
                        keyboardType:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Amount (INR)',
                          prefixText: '₹ ',
                        ),
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: type,
                        decoration: const InputDecoration(
                          labelText: 'Transaction type',
                        ),
                        items: ['Income', 'Expense']
                            .map(
                              (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              type = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: categories
                            .map(
                              (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              category = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setDialogState(() {
                              date = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: Text(_formatDate(date)),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );

                    if (title.isEmpty ||
                        amount == null ||
                        !amount.isFinite ||
                        amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Enter a name and a valid positive amount.',
                          ),
                        ),
                      );
                      return;
                    }

                    widget.controller.addTransaction(
                      title: title,
                      category: category,
                      amount: amount,
                      type: type,
                      date: date,
                    );

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save Transaction'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      titleController.dispose();
      amountController.dispose();
    });
  }
}
