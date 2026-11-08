
import 'package:flutter/material.dart';

import 'finance_controller.dart';
import 'transactions_screen.dart';
import 'budget_screen.dart';
import 'cash_flow_screen.dart';
import 'financial_insights_screen.dart';
import 'workspace_sidebar.dart';
import 'smooth_page_route.dart';

const Color dashboardNavy = Color(0xFF14243A);
const Color dashboardBlue = Color(0xFF3978F6);
const Color dashboardBackground = Color(0xFFF5F7FB);
const Color dashboardMuted = Color(0xFF718096);
const Color dashboardBorder = Color(0xFFE8ECF2);
const Color dashboardGreen = Color(0xFF16A36A);
const Color dashboardRed = Color(0xFFE35D6A);

class DashboardScreen extends StatefulWidget {
  final String workspace;

  const DashboardScreen({
    super.key,
    required this.workspace,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late FinanceController controller;

  bool get isBusiness => widget.workspace == 'Business';

  @override
  void initState() {
    super.initState();
    controller = FinanceController(workspace: widget.workspace);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _openTransactions() {
    Navigator.push(
      context,
      SmoothPageRoute(
        page: TransactionsScreen(
          workspace: widget.workspace,
          controller: controller,
        ),
      ),
    );
  }

  void _openBudgetPlanner() {
    Navigator.push(
      context,
      SmoothPageRoute(
        page: BudgetScreen(
          workspace: widget.workspace,
          controller: controller,
        ),
      ),
    );
  }

  void _openCashFlow() {
    Navigator.push(
      context,
      SmoothPageRoute(
        page: CashFlowScreen(
          workspace: widget.workspace,
          controller: controller,
        ),
      ),
    );
  }

  void _openFinancialInsights() {
    Navigator.push(
      context,
      SmoothPageRoute(
        page: FinancialInsightsScreen(
          workspace: widget.workspace,
          controller: controller,
        ),
      ),
    );
  }

  void _navigate(String destination) {
    switch (destination) {
      case 'Dashboard':
        break;
      case 'Transactions':
        _openTransactions();
        break;
      case 'Budget Planner':
        _openBudgetPlanner();
        break;
      case 'Cash Flow':
        _openCashFlow();
        break;
      case 'Financial Insights':
        _openFinancialInsights();
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
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  String _formatAmount(double amount) {
    final int value = amount.round();
    final String number = value.toString();

    if (number.length <= 3) {
      return '₹$number';
    }

    final String lastThree =
    number.substring(number.length - 3);
    final String remaining =
    number.substring(0, number.length - 3);
    final List<String> groups = [];

    for (int i = remaining.length; i > 0; i -= 2) {
      final int start = i - 2 < 0 ? 0 : i - 2;
      groups.insert(0, remaining.substring(start, i));
    }

    return '₹${groups.join(',')},$lastThree';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dashboardBackground,
      body: Row(
        children: [
          WorkspaceSidebar(
            selectedItem: 'Dashboard',
            workspace: widget.workspace,
            onNavigate: _navigate,
            onHome: _goHome,
          ),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeSection(),
                            const SizedBox(height: 25),
                            _buildSectionHeading(
                              'Financial Summary',
                              'A quick look at your financial position',
                            ),
                            const SizedBox(height: 15),
                            _buildSummaryCards(),
                            const SizedBox(height: 28),
                            _buildSectionHeading(
                              'Financial Activity',
                              'Understand where your money is going',
                            ),
                            const SizedBox(height: 15),
                            _buildActivitySection(),
                            const SizedBox(height: 28),
                            _buildSectionHeading(
                              'Quick Access',
                              'Manage your finances from one place',
                            ),
                            const SizedBox(height: 15),
                            _buildQuickActions(),
                            const SizedBox(height: 25),
                            _buildDemoNotice(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: dashboardBorder),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isBusiness
                      ? Icons.business_rounded
                      : Icons.person_outline_rounded,
                  color: dashboardBlue,
                  size: 17,
                ),
                const SizedBox(width: 8),
                Text(
                  isBusiness
                      ? 'Business Workspace'
                      : 'Personal Workspace',
                  style: const TextStyle(
                    color: dashboardNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: dashboardMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: dashboardBlue,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF14243A),
            Color(0xFF203F65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: dashboardNavy.withValues(alpha: 0.13),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 600;

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'YOUR FINANCIAL COMMAND CENTER',
                        style: TextStyle(
                          color: Color(0xFFD8E7FF),
                          fontSize: 10,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 17),
                    Text(
                      isBusiness
                          ? 'Business Overview'
                          : 'Your finances,\nall in one place.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 23 : 29,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isBusiness
                          ? 'Monitor revenue, expenses and your overall business position.'
                          : 'Track income, manage expenses and make smarter financial decisions.',
                      style: const TextStyle(
                        color: Color(0xFFC4D2E4),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _heroButton(
                          label: 'View Transactions',
                          icon: Icons.arrow_forward_rounded,
                          onTap: _openTransactions,
                        ),
                        _heroSecondaryButton(
                          label: 'Explore Insights',
                          onTap: _openFinancialInsights,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 20),
                Container(
                  width: 115,
                  height: 115,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.13),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Color(0xFFDCE9FF),
                    size: 54,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _heroButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: dashboardNavy,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 13,
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
    );
  }

  Widget _heroSecondaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.35),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: dashboardNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: dashboardMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final cards = [
      {
        'title': isBusiness ? 'Total Revenue' : 'Total Income',
        'amount': _formatAmount(controller.totalIncome),
        'icon': Icons.trending_up_rounded,
        'color': dashboardGreen,
        'note': 'Recorded income',
      },
      {
        'title': isBusiness ? 'Operating Expenses' : 'Total Expenses',
        'amount': _formatAmount(controller.totalExpenses),
        'icon': Icons.receipt_long_rounded,
        'color': dashboardRed,
        'note': 'Recorded expenses',
      },
      {
        'title': isBusiness ? 'Net Position' : 'Available Balance',
        'amount': _formatAmount(controller.balance),
        'icon': Icons.account_balance_wallet_rounded,
        'color': dashboardBlue,
        'note': 'Income minus expenses',
      },
      {
        'title': isBusiness ? 'Surplus Rate' : 'Savings Rate',
        'amount': '${controller.savingsRate.toStringAsFixed(1)}%',
        'icon': Icons.pie_chart_rounded,
        'color': const Color(0xFF8B5CF6),
        'note': 'Balance / income',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int columns = width >= 1100
            ? 4
            : width >= 650
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            mainAxisExtent: 160,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];

            return _summaryCard(
              title: card['title'] as String,
              amount: card['amount'] as String,
              icon: card['icon'] as IconData,
              color: card['color'] as Color,
              note: card['note'] as String,
            );
          },
        );
      },
    );
  }

  Widget _summaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required String note,
  }) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: dashboardBorder),
        boxShadow: [
          BoxShadow(
            color: dashboardNavy.withValues(alpha: 0.025),
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
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: dashboardMuted,
                  size: 17,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: dashboardMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: const TextStyle(
                color: dashboardNavy,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: const TextStyle(
              color: dashboardMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 850) {
          return Column(
            children: [
              _buildCashFlowCard(),
              const SizedBox(height: 16),
              _buildRecentTransactionsCard(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildCashFlowCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildRecentTransactionsCard()),
          ],
        );
      },
    );
  }

  Widget _buildCashFlowCard() {
    final double income = controller.totalIncome;
    final double expenses = controller.totalExpenses;
    final double total = income + expenses;

    final double incomeRatio =
    total == 0 ? 0 : (income / total).clamp(0.0, 1.0);
    final double expenseRatio =
    total == 0 ? 0 : (expenses / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(21),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Income vs Expenses',
                  style: TextStyle(
                    color: dashboardNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.bar_chart_rounded,
                color: dashboardBlue,
                size: 21,
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            'Comparison of your recorded money flow',
            style: TextStyle(
              color: dashboardMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 24),
          _flowRow(
            label: isBusiness ? 'Revenue' : 'Income',
            amount: _formatAmount(income),
            color: dashboardGreen,
            ratio: incomeRatio,
          ),
          const SizedBox(height: 22),
          _flowRow(
            label: isBusiness ? 'Expenses' : 'Spending',
            amount: _formatAmount(expenses),
            color: dashboardRed,
            ratio: expenseRatio,
          ),
          const SizedBox(height: 23),
          const Divider(color: dashboardBorder),
          const SizedBox(height: 13),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Net financial position',
                  style: TextStyle(
                    color: dashboardMuted,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                _formatAmount(controller.balance),
                style: TextStyle(
                  color: controller.balance >= 0
                      ? dashboardGreen
                      : dashboardRed,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _openCashFlow,
              icon: const Icon(Icons.arrow_forward_rounded, size: 15),
              label: const Text('View cash flow'),
              style: TextButton.styleFrom(
                foregroundColor: dashboardBlue,
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _flowRow({
    required String label,
    required String amount,
    required Color color,
    required double ratio,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: dashboardNavy,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: dashboardNavy,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 9,
            backgroundColor: const Color(0xFFF0F2F6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsCard() {
    final transactions = controller.transactions.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(21),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Transactions',
                  style: TextStyle(
                    color: dashboardNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.history_rounded,
                color: dashboardBlue,
                size: 21,
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            'Your latest recorded financial activity',
            style: TextStyle(
              color: dashboardMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 15),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Center(
                child: Text(
                  'No transactions recorded yet.',
                  style: TextStyle(
                    color: dashboardMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else
            ...transactions.map(
                  (transaction) => _transactionRow(transaction),
            ),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _openTransactions,
              icon: const Icon(Icons.arrow_forward_rounded, size: 15),
              label: const Text('View all transactions'),
              style: TextButton.styleFrom(
                foregroundColor: dashboardBlue,
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionRow(FinanceTransaction transaction) {
    final bool income = transaction.isIncome;
    final Color color = income ? dashboardGreen : dashboardRed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              income
                  ? Icons.south_west_rounded
                  : Icons.north_east_rounded,
              color: color,
              size: 17,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: dashboardNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.category} • ${_formatDate(transaction.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: dashboardMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${income ? '+' : '-'}${_formatAmount(transaction.amount)}',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 600
            ? 2
            : 1;

        final actions = [
          {
            'title': 'Transactions',
            'subtitle': 'View and manage records',
            'icon': Icons.receipt_long_rounded,
            'color': dashboardBlue,
            'tap': _openTransactions,
          },
          {
            'title': 'Budget Planner',
            'subtitle': 'Plan category spending',
            'icon': Icons.pie_chart_outline_rounded,
            'color': const Color(0xFF8B5CF6),
            'tap': _openBudgetPlanner,
          },
          {
            'title': 'Cash Flow',
            'subtitle': 'Review money movement',
            'icon': Icons.swap_vert_rounded,
            'color': dashboardGreen,
            'tap': _openCashFlow,
          },
          {
            'title': 'Financial Insights',
            'subtitle': 'Explore financial indicators',
            'icon': Icons.insights_rounded,
            'color': const Color(0xFFE59A35),
            'tap': _openFinancialInsights,
          },
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 91,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];

            return _quickActionCard(
              title: action['title'] as String,
              subtitle: action['subtitle'] as String,
              icon: action['icon'] as IconData,
              color: action['color'] as Color,
              onTap: action['tap'] as VoidCallback,
            );
          },
        );
      },
    );
  }

  Widget _quickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: dashboardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: dashboardNavy,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: dashboardMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: dashboardMuted,
                size: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFDCE7FF),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: dashboardBlue,
            size: 19,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Demo workspace: Sample financial records are provided for testing. Changes reset when the app is restarted.',
              style: TextStyle(
                color: dashboardNavy,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: dashboardBorder),
      boxShadow: [
        BoxShadow(
          color: dashboardNavy.withValues(alpha: 0.025),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
