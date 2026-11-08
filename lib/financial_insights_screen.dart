

import 'package:flutter/material.dart';

import 'finance_controller.dart';
import 'transactions_screen.dart';
import 'budget_screen.dart';
import 'cash_flow_screen.dart';
import 'smooth_page_route.dart';
import 'workspace_sidebar.dart';

const Color insightsNavy = Color(0xFF14243A);
const Color insightsBlue = Color(0xFF3978F6);
const Color insightsBackground = Color(0xFFF5F7FB);
const Color insightsMuted = Color(0xFF718096);
const Color insightsBorder = Color(0xFFE8ECF2);
const Color insightsGreen = Color(0xFF16A36A);
const Color insightsRed = Color(0xFFE35D6A);

class FinancialInsightsScreen extends StatefulWidget {
  final String workspace;
  final FinanceController controller;

  const FinancialInsightsScreen({
    super.key,
    required this.workspace,
    required this.controller,
  });

  @override
  State<FinancialInsightsScreen> createState() =>
      _FinancialInsightsScreenState();
}

class _FinancialInsightsScreenState
    extends State<FinancialInsightsScreen> {
  bool get isBusiness => widget.workspace == 'Business';

  String formatAmount(double amount) {
    final bool isNegative = amount < 0;
    final int value = amount.abs().round();
    final String number = value.toString();

    if (number.length <= 3) {
      return '${isNegative ? '-₹' : '₹'}$number';
    }

    final String lastThree = number.substring(number.length - 3);
    final String remaining = number.substring(0, number.length - 3);
    final List<String> groups = [];

    for (int i = remaining.length; i > 0; i -= 2) {
      final int start = i - 2 < 0 ? 0 : i - 2;
      groups.insert(0, remaining.substring(start, i));
    }

    return '${isNegative ? '-₹' : '₹'}${groups.join(',')},$lastThree';
  }

  Map<String, double> get categoryExpenses {
    final Map<String, double> result = {};

    for (final transaction in widget.controller.transactions) {
      if (transaction.isExpense) {
        result[transaction.category] =
            (result[transaction.category] ?? 0) + transaction.amount;
      }
    }

    return result;
  }

  String get highestSpendingCategory {
    final expenses = categoryExpenses;

    if (expenses.isEmpty) return 'No expenses yet';

    String highestCategory = expenses.keys.first;
    double highestAmount = expenses[highestCategory]!;

    for (final entry in expenses.entries) {
      if (entry.value > highestAmount) {
        highestCategory = entry.key;
        highestAmount = entry.value;
      }
    }

    return highestCategory;
  }

  double get highestCategoryAmount {
    final expenses = categoryExpenses;

    if (expenses.isEmpty) return 0;

    return expenses[highestSpendingCategory] ?? 0;
  }

  double get savingsRate => widget.controller.savingsRate;

  double get expenseRatio {
    if (widget.controller.totalIncome == 0) return 0;

    return (widget.controller.totalExpenses /
        widget.controller.totalIncome) *
        100;
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
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$destination is coming soon.'),
          ),
        );
    }
  }

  void _goHome() {
    Navigator.of(context).popUntil(
          (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: insightsBackground,
      body: SafeArea(
        child: Row(
          children: [
            WorkspaceSidebar(
              selectedItem: 'Financial Insights',
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
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 1400,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 28),
                            _buildOverviewCards(),
                            const SizedBox(height: 25),
                            _buildSpendingAnalysis(),
                            const SizedBox(height: 25),
                            _buildRecommendations(),
                            const SizedBox(height: 20),
                            _buildFooter(),
                          ],
                        ),
                      ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 650;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF0FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        size: 15,
                        color: insightsBlue,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        isBusiness
                            ? 'BUSINESS WORKSPACE'
                            : 'PERSONAL WORKSPACE',
                        style: const TextStyle(
                          color: insightsBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (!compact)
                  Text(
                    '${widget.controller.transactions.length} recorded transactions',
                    style: const TextStyle(
                      color: insightsMuted,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Financial Insights',
              style: TextStyle(
                color: insightsNavy,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Understand your financial behaviour and identify spending patterns.',
              style: TextStyle(
                color: insightsMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            if (compact) ...[
              const SizedBox(height: 7),
              Text(
                '${widget.controller.transactions.length} recorded transactions',
                style: const TextStyle(
                  color: insightsMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildOverviewCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 560
            ? 2
            : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: columns == 3
              ? 2.15
              : columns == 2
              ? 2.4
              : 3.3,
          children: [
            _overviewCard(
              title: 'Savings Rate',
              value: '${savingsRate.toStringAsFixed(1)}%',
              subtitle: 'Income retained after expenses',
              icon: Icons.savings_outlined,
              color: insightsGreen,
            ),
            _overviewCard(
              title: 'Expense Ratio',
              value: '${expenseRatio.toStringAsFixed(1)}%',
              subtitle: 'Income used for expenses',
              icon: Icons.pie_chart_outline,
              color: insightsRed,
            ),
            _overviewCard(
              title: 'Highest Spending',
              value: highestSpendingCategory,
              subtitle: formatAmount(highestCategoryAmount),
              icon: Icons.trending_up_rounded,
              color: insightsBlue,
            ),
          ],
        );
      },
    );
  }

  Widget _overviewCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: insightsBorder),
        boxShadow: [
          BoxShadow(
            color: insightsNavy.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: insightsMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: insightsNavy,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: insightsMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingAnalysis() {
    final expenses = categoryExpenses;
    final double total = widget.controller.totalExpenses;

    final sortedEntries = expenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: insightsBorder),
        boxShadow: [
          BoxShadow(
            color: insightsNavy.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.donut_large_rounded,
                  color: insightsBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending by Category',
                      style: TextStyle(
                        color: insightsNavy,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'See where your recorded expenses are going.',
                      style: TextStyle(
                        color: insightsMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          if (sortedEntries.isEmpty)
            _buildEmptyState()
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total recorded expenses',
                  style: TextStyle(
                    color: insightsMuted,
                    fontSize: 12,
                  ),
                ),
                Text(
                  formatAmount(total),
                  style: const TextStyle(
                    color: insightsNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            ...sortedEntries.asMap().entries.map((indexedEntry) {
              final int index = indexedEntry.key;
              final entry = indexedEntry.value;
              final double percentage =
              total > 0 ? entry.value / total : 0;

              final List<Color> colors = [
                insightsBlue,
                insightsGreen,
                const Color(0xFF8B6CE8),
                const Color(0xFFE7A33E),
                const Color(0xFF29A6B8),
              ];

              final Color color = colors[index % colors.length];

              return Padding(
                padding: const EdgeInsets.only(bottom: 21),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: insightsNavy,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          formatAmount(entry.value),
                          style: const TextStyle(
                            color: insightsNavy,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 48,
                          child: Text(
                            '${(percentage * 100).toStringAsFixed(1)}%',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: insightsMuted,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percentage.clamp(0.0, 1.0).toDouble(),
                        minHeight: 10,
                        backgroundColor: const Color(0xFFEDF0F5),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35),
      decoration: BoxDecoration(
        color: insightsBackground,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 34,
            color: insightsMuted,
          ),
          SizedBox(height: 12),
          Text(
            'No expense data available',
            style: TextStyle(
              color: insightsNavy,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Add expense transactions to see your spending breakdown.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: insightsMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getRecommendations() {
    final List<Map<String, dynamic>> recommendations = [];

    final double income = widget.controller.totalIncome;
    final double expenses = widget.controller.totalExpenses;
    final double balance = widget.controller.balance;

    if (widget.controller.transactions.isEmpty) {
      recommendations.add({
        'title': 'Start recording transactions',
        'description':
        'Add your income and expenses to generate financial insights.',
        'icon': Icons.add_chart,
        'color': insightsBlue,
      });
    } else if (income == 0) {
      recommendations.add({
        'title': 'No income recorded',
        'description':
        'Record your income to calculate your savings rate and compare it with your expenses.',
        'icon': Icons.info_outline,
        'color': insightsBlue,
      });
    } else {
      if (expenses > income) {
        recommendations.add({
          'title': 'Expenses exceed income',
          'description':
          'Your recorded expenses are higher than your income. Review your spending and identify costs you can reduce.',
          'icon': Icons.warning_amber_rounded,
          'color': insightsRed,
        });
      } else if (savingsRate < 20) {
        recommendations.add({
          'title': 'Low savings rate',
          'description':
          'Your current savings rate is below 20%. Review non-essential spending and consider setting a savings target.',
          'icon': Icons.savings_outlined,
          'color': insightsBlue,
        });
      } else {
        recommendations.add({
          'title': 'Positive savings position',
          'description':
          'Your recorded income exceeds your expenses. Continue monitoring spending and maintain your savings habit.',
          'icon': Icons.check_circle_outline,
          'color': insightsGreen,
        });
      }

      if (expenseRatio > 80 && expenses <= income) {
        recommendations.add({
          'title': 'High expense ratio',
          'description':
          'More than 80% of your recorded income is being spent. Review your largest expense categories.',
          'icon': Icons.trending_up,
          'color': insightsRed,
        });
      }

      if (highestCategoryAmount > 0) {
        recommendations.add({
          'title': 'Largest spending category: $highestSpendingCategory',
          'description':
          'You have spent ${formatAmount(highestCategoryAmount)} in this category. Check whether this spending matches your priorities.',
          'icon': Icons.category_outlined,
          'color': insightsBlue,
        });
      }

      if (balance < 0) {
        recommendations.add({
          'title': 'Negative financial balance',
          'description':
          'Your total recorded expenses exceed your total recorded income. Review your financial records and spending commitments.',
          'icon': Icons.account_balance_wallet_outlined,
          'color': insightsRed,
        });
      }
    }

    return recommendations;
  }

  Widget _buildRecommendations() {
    final recommendations = _getRecommendations();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: insightsBorder),
        boxShadow: [
          BoxShadow(
            color: insightsNavy.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F0),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: insightsGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Recommendations',
                      style: TextStyle(
                        color: insightsNavy,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Suggestions based on your recorded transactions.',
                      style: TextStyle(
                        color: insightsMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...recommendations.map((item) {
            final Color color = item['color'] as Color;

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.055),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: color.withValues(alpha: 0.16),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            color: insightsNavy,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['description'] as String,
                          style: const TextStyle(
                            color: insightsMuted,
                            fontSize: 12,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2FA),
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: insightsMuted,
            size: 17,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'These insights are generated using basic financial rules and your recorded transactions. They are not AI-generated financial advice.',
              style: TextStyle(
                color: insightsMuted,
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
