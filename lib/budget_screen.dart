
import 'package:flutter/material.dart';

import 'finance_controller.dart';
import 'transactions_screen.dart';
import 'cash_flow_screen.dart';
import 'financial_insights_screen.dart';
import 'smooth_page_route.dart';
import 'workspace_sidebar.dart';

const Color budgetNavy = Color(0xFF14213D);
const Color budgetBlue = Color(0xFF2563EB);
const Color budgetBackground = Color(0xFFF5F7FB);
const Color budgetMuted = Color(0xFF64748B);
const Color budgetBorder = Color(0xFFE8EDF4);
const Color budgetGreen = Color(0xFF059669);
const Color budgetRed = Color(0xFFDC2626);
const Color budgetOrange = Color(0xFFD97706);

class BudgetScreen extends StatefulWidget {
  final String workspace;
  final FinanceController controller;

  const BudgetScreen({
    super.key,
    required this.workspace,
    required this.controller,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final List<Map<String, dynamic>> budgets = [
    {
      'category': 'Food',
      'limit': 8000.0,
      'color': const Color(0xFF2563EB),
    },
    {
      'category': 'Housing',
      'limit': 15000.0,
      'color': const Color(0xFF7C3AED),
    },
    {
      'category': 'Transport',
      'limit': 4000.0,
      'color': const Color(0xFF0891B2),
    },
    {
      'category': 'Entertainment',
      'limit': 3000.0,
      'color': const Color(0xFFD97706),
    },
  ];

  double _spentForCategory(String category) {
    return widget.controller.transactions
        .where(
          (transaction) =>
      transaction.isExpense &&
          transaction.category.toLowerCase() ==
              category.toLowerCase(),
    )
        .fold(
      0.0,
          (total, transaction) => total + transaction.amount,
    );
  }

  double get totalBudget {
    return budgets.fold(
      0.0,
          (sum, item) => sum + (item['limit'] as double),
    );
  }

  double get totalSpent {
    return budgets.fold(
      0.0,
          (sum, item) =>
      sum + _spentForCategory(item['category'] as String),
    );
  }

  String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
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

  void addBudget() {
    final categoryController = TextEditingController();
    final limitController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Create Budget',
            style: TextStyle(
              color: budgetNavy,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogInput(
                  controller: categoryController,
                  label: 'Category',
                  hint: 'e.g. Shopping',
                  icon: Icons.category_outlined,
                ),
                const SizedBox(height: 16),
                _dialogInput(
                  controller: limitController,
                  label: 'Monthly Limit',
                  hint: 'Enter amount in rupees',
                  icon: Icons.currency_rupee_rounded,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: budgetMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final category = categoryController.text.trim();
                final limit =
                double.tryParse(limitController.text.trim());

                if (category.isEmpty ||
                    limit == null ||
                    !limit.isFinite ||
                    limit <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter a category and a valid positive limit.',
                      ),
                    ),
                  );
                  return;
                }

                final alreadyExists = budgets.any(
                      (budget) =>
                  (budget['category'] as String).toLowerCase() ==
                      category.toLowerCase(),
                );

                if (alreadyExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'A budget for this category already exists.',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  budgets.add({
                    'category': category,
                    'limit': limit,
                    'color': const Color(0xFF64748B),
                  });
                });

                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: budgetNavy,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Create Budget'),
            ),
          ],
        );
      },
    ).then((_) {
      categoryController.dispose();
      limitController.dispose();
    });
  }

  Widget _dialogInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: budgetMuted, size: 20),
        filled: true,
        fillColor: budgetBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: budgetBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: budgetBlue,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: budgetBackground,
      body: SafeArea(
        child: Row(
          children: [
            WorkspaceSidebar(
              selectedItem: 'Budget Planner',
              workspace: widget.workspace,
              onNavigate: _navigate,
              onHome: _goHome,
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.controller,
                builder: (context, child) {
                  final remaining = totalBudget - totalSpent;
                  final usage = totalBudget == 0
                      ? 0.0
                      : totalSpent / totalBudget;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 750;

                      return SingleChildScrollView(
                        padding: EdgeInsets.all(compact ? 18 : 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(compact),
                            const SizedBox(height: 28),
                            _buildSummaryCards(
                              compact: compact,
                              remaining: remaining,
                            ),
                            const SizedBox(height: 24),
                            _buildOverallUsage(usage),
                            const SizedBox(height: 30),
                            _buildCategoryHeader(compact),
                            const SizedBox(height: 16),
                            ...budgets.map(
                                  (budget) => _buildBudgetCard(budget),
                            ),
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
                color: const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 15,
                    color: budgetBlue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.workspace} Workspace',
                    style: const TextStyle(
                      color: budgetBlue,
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
                  color: budgetMuted.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Budget Planner',
          style: TextStyle(
            fontSize: compact ? 25 : 30,
            fontWeight: FontWeight.w800,
            color: budgetNavy,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Set spending limits and keep your finances on track.',
          style: TextStyle(
            color: budgetMuted,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards({
    required bool compact,
    required double remaining,
  }) {
    final cards = [
      _summaryCard(
        title: 'Total Budget',
        amount: formatAmount(totalBudget),
        subtitle: 'Your planned spending limit',
        icon: Icons.account_balance_wallet_outlined,
        color: budgetBlue,
        background: const Color(0xFFEAF1FF),
      ),
      _summaryCard(
        title: 'Total Spent',
        amount: formatAmount(totalSpent),
        subtitle: 'Across budget categories',
        icon: Icons.shopping_bag_outlined,
        color: budgetOrange,
        background: const Color(0xFFFFF4E5),
      ),
      _summaryCard(
        title: 'Remaining',
        amount: formatAmount(remaining),
        subtitle: remaining < 0
            ? 'You are over your total budget'
            : 'Available budget balance',
        icon: Icons.savings_outlined,
        color: remaining < 0 ? budgetRed : budgetGreen,
        background: remaining < 0
            ? const Color(0xFFFFEEEE)
            : const Color(0xFFE8F8F1),
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
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: budgetBorder),
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
                color: budgetMuted.withValues(alpha: 0.6),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: budgetMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: const TextStyle(
                color: budgetNavy,
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
              color: budgetMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallUsage(double usage) {
    final isOverBudget = usage > 1;
    final progressColor = isOverBudget ? budgetRed : budgetBlue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: budgetBorder),
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
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: budgetBlue,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Budget Usage',
                      style: TextStyle(
                        color: budgetNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Your spending against the total planned budget',
                      style: TextStyle(
                        color: budgetMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(usage * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: progressColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: usage.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: const Color(0xFFEDF0F5),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  isOverBudget
                      ? 'You have exceeded your total budget.'
                      : 'You have used ${formatAmount(totalSpent)} of ${formatAmount(totalBudget)}.',
                  style: TextStyle(
                    color: isOverBudget ? budgetRed : budgetMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!isOverBudget)
                Text(
                  '${formatAmount(totalBudget - totalSpent)} left',
                  style: const TextStyle(
                    color: budgetGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(bool compact) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category Budgets',
                style: TextStyle(
                  color: budgetNavy,
                  fontSize: compact ? 18 : 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Monitor spending limits for each category.',
                style: TextStyle(
                  color: budgetMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: addBudget,
          icon: const Icon(Icons.add, size: 18),
          label: Text(compact ? 'Add' : 'Add Budget'),
          style: ElevatedButton.styleFrom(
            backgroundColor: budgetNavy,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 13 : 18,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(Map<String, dynamic> budget) {
    final category = budget['category'] as String;
    final spent = _spentForCategory(category);
    final limit = budget['limit'] as double;
    final progress = limit == 0 ? 0.0 : spent / limit;
    final isOverBudget = spent > limit;
    final color = budget['color'] as Color;
    final remaining = limit - spent;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: budgetBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(category),
                  color: color,
                  size: 21,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        color: budgetNavy,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Monthly spending limit',
                      style: TextStyle(
                        color: budgetMuted.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOverBudget)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Over budget',
                    style: TextStyle(
                      color: budgetRed,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'On track',
                    style: TextStyle(
                      color: budgetGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 21),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount spent',
                      style: TextStyle(
                        color: budgetMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatAmount(spent),
                      style: const TextStyle(
                        color: budgetNavy,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Budget limit',
                    style: TextStyle(
                      color: budgetMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatAmount(limit),
                    style: const TextStyle(
                      color: budgetNavy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: const Color(0xFFEDF0F5),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? budgetRed : color,
              ),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(1)}% used',
                style: const TextStyle(
                  color: budgetMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                isOverBudget
                    ? 'Exceeded by ${formatAmount(-remaining)}'
                    : '${formatAmount(remaining)} remaining',
                style: TextStyle(
                  color: isOverBudget ? budgetRed : budgetGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_outlined;
      case 'housing':
        return Icons.home_outlined;
      case 'transport':
        return Icons.directions_car_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'health':
        return Icons.health_and_safety_outlined;
      case 'education':
        return Icons.school_outlined;
      default:
        return Icons.category_outlined;
    }
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
            color: budgetBlue,
            size: 19,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Budget spending is calculated from expense transactions that match each category. Transactions in categories without a budget are not included in these totals.',
              style: TextStyle(
                color: budgetNavy,
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
