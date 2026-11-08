
import 'package:flutter/material.dart';

import 'finance_controller.dart';
import 'transactions_screen.dart';
import 'budget_screen.dart';
import 'financial_insights_screen.dart';
import 'smooth_page_route.dart';
import 'workspace_sidebar.dart';

const Color cashNavy = Color(0xFF14213D);
const Color cashBlue = Color(0xFF2563EB);
const Color cashBackground = Color(0xFFF5F7FB);
const Color cashMuted = Color(0xFF64748B);
const Color cashBorder = Color(0xFFE8EDF4);
const Color cashGreen = Color(0xFF059669);
const Color cashRed = Color(0xFFDC2626);

class CashFlowScreen extends StatefulWidget {
  final String workspace;
  final FinanceController controller;

  const CashFlowScreen({
    super.key,
    required this.workspace,
    required this.controller,
  });

  @override
  State<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends State<CashFlowScreen> {
  bool get isBusiness => widget.workspace == 'Business';

  String formatAmount(double amount) {
    final value = amount.round();
    final number = value.toString();

    if (number.length <= 3) {
      return '₹$number';
    }

    final lastThree = number.substring(number.length - 3);
    final remaining = number.substring(0, number.length - 3);
    final groups = <String>[];

    for (int i = remaining.length; i > 0; i -= 2) {
      final start = i - 2 < 0 ? 0 : i - 2;
      groups.insert(0, remaining.substring(start, i));
    }

    return '₹${groups.join(',')},$lastThree';
  }

  List<FinanceTransaction> get currentMonthTransactions {
    final now = DateTime.now();

    return widget.controller.transactions.where((transaction) {
      return transaction.date.year == now.year &&
          transaction.date.month == now.month;
    }).toList();
  }

  double get monthlyIncome {
    return currentMonthTransactions
        .where((transaction) => transaction.isIncome)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get monthlyExpenses {
    return currentMonthTransactions
        .where((transaction) => transaction.isExpense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get monthlyNetCashFlow => monthlyIncome - monthlyExpenses;

  List<Map<String, dynamic>> get monthlyData {
    final now = DateTime.now();
    final result = <Map<String, dynamic>>[];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);

      double income = 0;
      double expenses = 0;

      for (final transaction in widget.controller.transactions) {
        if (transaction.date.year == month.year &&
            transaction.date.month == month.month) {
          if (transaction.isIncome) {
            income += transaction.amount;
          } else if (transaction.isExpense) {
            expenses += transaction.amount;
          }
        }
      }

      result.add({
        'month': _monthName(month.month),
        'income': income,
        'expenses': expenses,
      });
    }

    return result;
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return months[month - 1];
  }

  void _openSection(Widget screen, String routeName) {
    final navigator = Navigator.of(context);

    navigator.popUntil(ModalRoute.withName('/dashboard'));

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
        _openSection(
          TransactionsScreen(
            workspace: widget.workspace,
            controller: widget.controller,
          ),
          '/transactions',
        );
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
      backgroundColor: cashBackground,
      body: SafeArea(
        child: Row(
          children: [
            WorkspaceSidebar(
              selectedItem: 'Cash Flow',
              workspace: widget.workspace,
              onNavigate: _navigate,
              onHome: _goHome,
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.controller,
                builder: (context, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 750;

                      return SingleChildScrollView(
                        padding: EdgeInsets.all(compact ? 18 : 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(compact),
                            const SizedBox(height: 25),
                            _buildSummaryCards(),
                            const SizedBox(height: 24),
                            _buildCashFlowChart(compact),
                            const SizedBox(height: 24),
                            _buildMonthlyBreakdown(compact),
                            const SizedBox(height: 18),
                            _buildFooterNote(),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.swap_horiz_rounded,
                    color: cashBlue,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.workspace} Workspace',
                    style: const TextStyle(
                      color: cashBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (!compact)
              Text(
                'FINANCIAL MANAGEMENT',
                style: TextStyle(
                  color: cashMuted.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Cash Flow',
          style: TextStyle(
            color: cashNavy,
            fontSize: compact ? 25 : 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Understand how money moves in and out of your account.',
          style: TextStyle(
            color: cashMuted,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final cards = [
      _summaryCard(
        title: 'Monthly Income',
        amount: monthlyIncome,
        subtitle: 'Money received this month',
        color: cashGreen,
        background: const Color(0xFFE8F8F1),
        icon: Icons.trending_up_rounded,
      ),
      _summaryCard(
        title: 'Monthly Expenses',
        amount: monthlyExpenses,
        subtitle: 'Money spent this month',
        color: cashRed,
        background: const Color(0xFFFFEEEE),
        icon: Icons.trending_down_rounded,
      ),
      _summaryCard(
        title: 'Net Cash Flow',
        amount: monthlyNetCashFlow,
        subtitle: monthlyNetCashFlow >= 0
            ? 'Positive cash flow'
            : 'Negative cash flow',
        color: monthlyNetCashFlow >= 0 ? cashBlue : cashRed,
        background: monthlyNetCashFlow >= 0
            ? const Color(0xFFEAF1FF)
            : const Color(0xFFFFEEEE),
        icon: Icons.account_balance_wallet_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 650 ? 1 : 3;
        final cardWidth =
            (constraints.maxWidth - ((columns - 1) * 14)) / columns;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: cards
              .map(
                (card) => SizedBox(
              width: cardWidth,
              child: card,
            ),
          )
              .toList(),
        );
      },
    );
  }

  Widget _summaryCard({
    required String title,
    required double amount,
    required String subtitle,
    required Color color,
    required Color background,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: cashBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const Spacer(),
              Icon(
                Icons.more_horiz,
                color: cashMuted.withValues(alpha: 0.6),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            title,
            style: const TextStyle(
              color: cashMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatAmount(amount),
              style: const TextStyle(
                color: cashNavy,
                fontSize: 25,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            style: const TextStyle(
              color: cashMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowChart(bool compact) {
    final data = monthlyData;

    double maxValue = 0;

    for (final item in data) {
      final income = item['income'] as double;
      final expenses = item['expenses'] as double;

      if (income > maxValue) maxValue = income;
      if (expenses > maxValue) maxValue = expenses;
    }

    if (maxValue == 0) maxValue = 1;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 18 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cashBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Cash Flow',
                      style: TextStyle(
                        color: cashNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Income compared with expenses over six months.',
                      style: TextStyle(
                        color: cashMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!compact)
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: cashBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: cashBlue,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _legendItem('Income', cashGreen),
              _legendItem('Expenses', cashRed),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 205,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                final income = item['income'] as double;
                final expenses = item['expenses'] as double;

                final incomeHeight = (income / maxValue) * 145;
                final expenseHeight = (expenses / maxValue) * 145;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _bar(incomeHeight, cashGreen),
                            const SizedBox(width: 5),
                            _bar(expenseHeight, cashRed),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['month'] as String,
                        style: const TextStyle(
                          color: cashMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double height, Color color) {
    return Container(
      width: 13,
      height: height.clamp(0.0, 145.0).toDouble(),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(5),
        ),
      ),
    );
  }

  Widget _legendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: cashMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyBreakdown(bool compact) {
    final data = monthlyData;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 18 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cashBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Breakdown',
            style: TextStyle(
              color: cashNavy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'A month-by-month view of your financial activity.',
            style: TextStyle(
              color: cashMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          ...data.map((item) {
            final income = item['income'] as double;
            final expenses = item['expenses'] as double;
            final net = income - expenses;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: cashBorder),
                ),
              ),
              child: compact
                  ? _buildCompactMonthRow(
                item['month'] as String,
                income,
                expenses,
                net,
              )
                  : _buildWideMonthRow(
                item['month'] as String,
                income,
                expenses,
                net,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWideMonthRow(
      String month,
      double income,
      double expenses,
      double net,
      ) {
    return Row(
      children: [
        SizedBox(
          width: 55,
          child: Text(
            month,
            style: const TextStyle(
              color: cashNavy,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _breakdownValue(
                  'Income',
                  formatAmount(income),
                  cashGreen,
                ),
              ),
              Expanded(
                child: _breakdownValue(
                  'Expenses',
                  formatAmount(expenses),
                  cashRed,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 115,
          child: _breakdownValue(
            'Net cash flow',
            formatAmount(net),
            net >= 0 ? cashBlue : cashRed,
            alignEnd: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactMonthRow(
      String month,
      double income,
      double expenses,
      double net,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              month,
              style: const TextStyle(
                color: cashNavy,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              'Net: ${formatAmount(net)}',
              style: TextStyle(
                color: net >= 0 ? cashBlue : cashRed,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              child: _breakdownValue(
                'Income',
                formatAmount(income),
                cashGreen,
              ),
            ),
            Expanded(
              child: _breakdownValue(
                'Expenses',
                formatAmount(expenses),
                cashRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _breakdownValue(
      String label,
      String amount,
      Color color, {
        bool alignEnd = false,
      }) {
    return Column(
      crossAxisAlignment:
      alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: cashMuted,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment:
          alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: cashBlue,
            size: 19,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Cash flow figures are calculated from your recorded transactions. Monthly totals include only transactions dated within the relevant calendar month.',
              style: TextStyle(
                color: cashNavy,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
