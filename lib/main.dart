
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

void main() {
  runApp(const FinGuideApp());
}

const Color navy = Color(0xFF14243A);
const Color navyLight = Color(0xFF203653);
const Color blue = Color(0xFF3978F6);
const Color background = Color(0xFFF7F8FC);
const Color muted = Color(0xFF718096);
const Color borderColor = Color(0xFFE6EAF0);

class FinGuideApp extends StatelessWidget {
  const FinGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinGuide',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(seedColor: blue),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String selectedWorkspace = 'Individual';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 850) {
            return Row(
              children: [
                Expanded(
                  child: _buildBrandPanel(),
                ),
                Expanded(
                  child: _buildSelectionPanel(),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 360,
                  child: _buildBrandPanel(),
                ),
                _buildSelectionPanel(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrandPanel() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [navy, navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 45,
        vertical: 38,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'FinGuide',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'YOUR FINANCES.\nYOUR DECISIONS.',
            style: TextStyle(
              color: Color(0xFF9DBDFB),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.2,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Take control of\nyour financial future.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              height: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'A smarter way to manage money, plan budgets '
                'and understand your financial position — '
                'all in one place.',
            style: TextStyle(
              color: Color(0xFFCFD8E6),
              fontSize: 15,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 35),
          _feature(
            Icons.account_balance_wallet_outlined,
            'Manage your finances',
          ),
          const SizedBox(height: 17),
          _feature(
            Icons.analytics_outlined,
            'Understand financial performance',
          ),
          const SizedBox(height: 17),
          _feature(
            Icons.trending_up_rounded,
            'Make informed decisions',
          ),
          const Spacer(),
          const Text(
            'SMART FINANCIAL MANAGEMENT PLATFORM',
            style: TextStyle(
              color: Color(0xFF9BAAC0),
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF8FB4FF),
          size: 21,
        ),
        const SizedBox(width: 13),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionPanel() {
    return Container(
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.symmetric(
        horizontal: 42,
        vertical: 35,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 490),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WELCOME TO FINGUIDE',
                style: TextStyle(
                  color: blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'How will you use FinGuide?',
                style: TextStyle(
                  color: navy,
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Select a workspace to get started. '
                    'You can manage your finances with tools '
                    'designed for your needs.',
                style: TextStyle(
                  color: muted,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 32),
              _workspaceCard(
                title: 'Individual Finance',
                description:
                'Manage personal income, expenses, savings and budgets.',
                icon: Icons.person_outline_rounded,
                value: 'Individual',
              ),
              const SizedBox(height: 17),
              _workspaceCard(
                title: 'Small Business Finance',
                description:
                'Track revenue, operating expenses, budgets and cash flow.',
                icon: Icons.business_outlined,
                value: 'Business',
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded, size: 19),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Center(
                child: Text(
                  'Secure  •  Simple  •  Insightful',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _workspaceCard({
    required String title,
    required String description,
    required IconData icon,
    required String value,
  }) {
    final bool isSelected = selectedWorkspace == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedWorkspace = value;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? blue : borderColor,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: blue.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEAF0FF)
                    : const Color(0xFFF0F2F7),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                size: 25,
                color: isSelected ? blue : navy,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected ? blue : muted,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  void _continue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/dashboard'),
        builder: (_) => DashboardScreen(
          workspace: selectedWorkspace,
        ),
      ),
    );
  }
}
