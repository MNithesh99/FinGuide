
import 'package:flutter/material.dart';

const Color sidebarNavy = Color(0xFF14243A);
const Color sidebarBlue = Color(0xFF3978F6);
const Color sidebarMuted = Color(0xFF91A1B8);

class WorkspaceSidebar extends StatelessWidget {
  final String selectedItem;
  final String workspace;
  final ValueChanged<String> onNavigate;
  final VoidCallback onHome;

  const WorkspaceSidebar({
    super.key,
    required this.selectedItem,
    required this.workspace,
    required this.onNavigate,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 235,
      color: sidebarNavy,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 25,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clickable FinGuide brand: returns to Dashboard.
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              hoverColor: Colors.white.withValues(alpha: 0.08),
              splashColor: sidebarBlue.withValues(alpha: 0.25),
              onTap: () => onNavigate('Dashboard'),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'FinGuide',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 42),

          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              'WORKSPACE',
              style: TextStyle(
                color: sidebarMuted,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 15),

          _navItem(
            icon: Icons.dashboard_rounded,
            title: 'Dashboard',
          ),

          _navItem(
            icon: Icons.receipt_long_rounded,
            title: 'Transactions',
          ),

          _navItem(
            icon: Icons.account_balance_rounded,
            title: 'Budget Planner',
          ),

          _navItem(
            icon: Icons.trending_up_rounded,
            title: 'Cash Flow',
          ),

          _navItem(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Financial Insights',
          ),

          const Spacer(),

          _navItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
          ),

          const SizedBox(height: 10),

          const Divider(
            color: Color(0xFF35465E),
          ),

          const SizedBox(height: 10),

          _navItem(
            icon: Icons.home_rounded,
            title: 'Back to Home',
            isHome: true,
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const CircleAvatar(
                radius: 17,
                backgroundColor: sidebarBlue,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  workspace == 'Business'
                      ? 'Business Account'
                      : 'Personal Account',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String title,
    bool isHome = false,
  }) {
    final bool selected = !isHome && selectedItem == title;

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: selected ? sidebarBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          hoverColor: Colors.white.withValues(alpha: 0.08),
          splashColor: Colors.white.withValues(alpha: 0.12),
          onTap: () {
            if (isHome) {
              onHome();
            } else {
              onNavigate(title);
            }
          },
          child: ListTile(
            dense: true,
            leading: Icon(
              icon,
              color: Colors.white,
              size: 19,
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 11,
            ),
          ),
        ),
      ),
    );
  }
}
