import 'package:flutter/material.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/screens/add_tranc.dart';
import 'package:jaibee1/screens/report.dart';
import 'package:jaibee1/screens/tranc_screen.dart';
import 'package:jaibee1/main.dart';
import 'package:jaibee1/screens/profile.dart';
import 'package:jaibee1/screens/budget_screen.dart';
import 'package:jaibee1/widgets/app_background.dart';
import 'package:jaibee1/screens/manage_categories.dart';

class ExpenseHomeScreen extends StatefulWidget {
  const ExpenseHomeScreen({super.key});

  @override
  State<ExpenseHomeScreen> createState() => _ExpenseHomeScreenState();
}

class _ExpenseHomeScreenState extends State<ExpenseHomeScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const TransactionScreen(),
      const BudgetScreen(),
      const AddTransactionScreen(),
      const ReportsScreen(),
      const ProfileScreen(),
      const ManageCategoriesScreen(), // newly added screen
    ];
    _pageController = PageController(initialPage: _currentPage);
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
        ? Colors.grey[900]!
        : const Color(0xFF4666B0);
    final Color navBarColor = isDark ? Colors.black : Colors.white;
    final Color selectedIconColor = isDark
        ? Colors.white
        : const Color(0xFF4666B0);
    final Color unselectedIconColor = Colors.grey[500]!;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: AppBackground(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              decoration: BoxDecoration(
                color: appBarColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  S.of(context)!.appTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                leading: _currentPage == 6
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => _onNavItemTapped(0),
                      )
                    : null,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.category),
                    tooltip: S.of(context)!.manageCategories,
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
            ),
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _screens,
            physics: const NeverScrollableScrollPhysics(),
          ),
          bottomNavigationBar: _currentPage != 5
              ? Container(
                  decoration: BoxDecoration(
                    color: navBarColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        icon: Icons.list,
                        label: S.of(context)!.transactions,
                        index: 0,
                        isSelected: _currentPage == 0,
                        selectedColor: selectedIconColor,
                        unselectedColor: unselectedIconColor,
                      ),
                      _buildNavItem(
                        icon: Icons.account_balance_wallet,
                        label: S.of(context)!.budgets,
                        index: 1,
                        isSelected: _currentPage == 1,
                        selectedColor: selectedIconColor,
                        unselectedColor: unselectedIconColor,
                      ),
                      GestureDetector(
                        onTap: () => _onNavItemTapped(2),
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: appBarColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      _buildNavItem(
                        icon: Icons.bar_chart,
                        label: S.of(context)!.reports,
                        index: 3,
                        isSelected: _currentPage == 3,
                        selectedColor: selectedIconColor,
                        unselectedColor: unselectedIconColor,
                      ),
                      _buildNavItem(
                        icon: Icons.person,
                        label: S.of(context)!.profile,
                        index: 4,
                        isSelected: _currentPage == 4,
                        selectedColor: selectedIconColor,
                        unselectedColor: unselectedIconColor,
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: selectedColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? selectedColor : unselectedColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
