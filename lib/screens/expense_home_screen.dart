import 'package:flutter/material.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/screens/add_tranc.dart';
import 'package:jaibee1/screens/report.dart';
import 'package:jaibee1/screens/tranc_screen.dart';
import 'package:jaibee1/main.dart';
import 'package:jaibee1/screens/profile.dart';
import 'package:jaibee1/screens/budget_screen.dart';
import 'package:jaibee1/widgets/app_background.dart'; // ⬅️ Import background wrapper
import 'package:jaibee1/screens/manage_categories.dart';

class ExpenseHomeScreen extends StatefulWidget {
  const ExpenseHomeScreen({super.key});

  @override
  State<ExpenseHomeScreen> createState() => _ExpenseHomeScreenState();
}

class _ExpenseHomeScreenState extends State<ExpenseHomeScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Widget> _screens = [
    const TransactionScreen(),
    const BudgetScreen(),
    const AddTransactionScreen(),
    const ReportsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _changeLanguage(String langCode) {
    Locale newLocale = Locale(langCode);
    ExpenseTrackerApp.setLocale(context, newLocale);
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(S.of(context)!.changeLanguage),
          children: [
            SimpleDialogOption(
              child: Text(S.of(context)!.english),
              onPressed: () {
                _changeLanguage('en');
                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(
              child: Text(S.of(context)!.arabic),
              onPressed: () {
                _changeLanguage('ar');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // void _goToProfile() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const ProfileScreen()),
  //   );
  // }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onNavItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color appBarColor = isDark
        ? Colors.black
        : const Color.fromARGB(255, 130, 148, 179);
    final Color navBarColor = isDark
        ? Colors.black
        : const Color.fromARGB(255, 130, 148, 179);
    final Color selectedIconColor = Colors.white;
    final Color unselectedIconColor = isDark
        ? Colors.grey.shade500
        : Colors.grey.shade300;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: AppBackground(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            title: Text(S.of(context)!.appTitle),
            backgroundColor: appBarColor,
            foregroundColor: Colors.white,
            elevation: 2,
            actions: [
              IconButton(
                icon: const Icon(Icons.category),
                tooltip: S
                    .of(context)!
                    .manageCategories, // Add this key to your .arb file for localization
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageCategoriesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _screens,
            physics: const NeverScrollableScrollPhysics(),
          ),
          floatingActionButton: SizedBox(
            height: 64,
            width: 64,
            child: FloatingActionButton(
              onPressed: () => _onNavItemTapped(2),
              tooltip: S.of(context)!.addTransaction,
              backgroundColor: appBarColor,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 32),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: Container(
            height: 60,
            decoration: BoxDecoration(
              color: navBarColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, -1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.list,
                  label: S.of(context)!.transactions,
                  index: 0,
                  isSelected: _currentPage == 0,
                  onTap: () => _onNavItemTapped(0),
                  selectedColor: selectedIconColor,
                  unselectedColor: unselectedIconColor,
                ),
                _buildNavItem(
                  icon: Icons.account_balance_wallet,
                  label: S.of(context)!.budgets,
                  index: 1,
                  isSelected: _currentPage == 1,
                  onTap: () => _onNavItemTapped(1),
                  selectedColor: selectedIconColor,
                  unselectedColor: unselectedIconColor,
                ),
                const SizedBox(width: 64), // FAB space
                _buildNavItem(
                  icon: Icons.bar_chart,
                  label: S.of(context)!.reports,
                  index: 3,
                  isSelected: _currentPage == 3,
                  onTap: () => _onNavItemTapped(3),
                  selectedColor: selectedIconColor,
                  unselectedColor: unselectedIconColor,
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: S.of(context)!.profile,
                  index: 4,
                  isSelected: _currentPage == 4,
                  onTap: () => _onNavItemTapped(4),
                  selectedColor: selectedIconColor,
                  unselectedColor: unselectedIconColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
    required Color selectedColor,
    required Color unselectedColor,
    double iconSize = 24.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: isSelected ? selectedColor : unselectedColor,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? selectedColor : unselectedColor,
            ),
          ),
        ],
      ),
    );
  }
}
