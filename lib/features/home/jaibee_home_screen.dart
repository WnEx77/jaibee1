import 'package:flutter/material.dart';
import 'package:jaibee1/features/transactions/add_tranc.dart';
import 'package:jaibee1/features/transactions/tranc_screen.dart';
import 'package:jaibee1/features/transactions/manage_categories.dart';
import 'package:jaibee1/features/reports/report.dart';
import 'package:jaibee1/features/profile/profile.dart';
import 'package:jaibee1/features/budget/budget_screen.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/shared/widgets/animated_screen_wrapper.dart';
import 'package:jaibee1/shared/widgets/custom_app_bar.dart';
import 'package:jaibee1/core/utils/create_animated_route.dart';
import 'package:jaibee1/core/theme/mint_jade_theme.dart';

class JaibeeHomeScreen extends StatefulWidget {
  const JaibeeHomeScreen({super.key});

  @override
  State<JaibeeHomeScreen> createState() => _JaibeeHomeScreenState();
}

class _JaibeeHomeScreenState extends State<JaibeeHomeScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const AnimatedScreenWrapper(child: TransactionScreen()),
      const AnimatedScreenWrapper(child: BudgetScreen()),
      const AnimatedScreenWrapper(child: AddTransactionScreen()),
      const AnimatedScreenWrapper(child: ReportsScreen()),
      const AnimatedScreenWrapper(child: ProfileScreen()),
      const AnimatedScreenWrapper(child: ManageCategoriesScreen()),
    ];
    _pageController = PageController(initialPage: _currentPage);
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
    // ✅ Locale logic must be inside build() (not initState) after MaterialApp is built
    final locale = Localizations.maybeLocaleOf(context);
    final isRtl = locale?.languageCode == 'ar';

    final mintTheme = Theme.of(context).extension<MintJadeColors>();
    if (mintTheme == null) {
      return const SizedBox(); // or a loader/spinner, etc.
    }

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: AppBackground(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          appBar: CustomAppBar(
            title: S.of(context)!.appTitle,
            showBackButton: _currentPage == 6,
            onBackPressed: () => _onNavItemTapped(0),
            actions: [
              IconButton(
                icon: const Icon(Icons.category),
                tooltip: S.of(context)!.manageCategories,
                onPressed: () {
                  Navigator.push(
                    context,
                    createAnimatedRoute(const ManageCategoriesScreen()),
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
          bottomNavigationBar: _currentPage != 5
              ? Container(
                  decoration: BoxDecoration(
                    color: mintTheme.navBarColor,
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
                        selectedColor: mintTheme.selectedIconColor,
                        unselectedColor: mintTheme.unselectedIconColor,
                      ),
                      _buildNavItem(
                        icon: Icons.account_balance_wallet,
                        label: S.of(context)!.budgets,
                        index: 1,
                        isSelected: _currentPage == 1,
                        selectedColor: mintTheme.selectedIconColor,
                        unselectedColor: mintTheme.unselectedIconColor,
                      ),
                      GestureDetector(
                        onTap: () => _onNavItemTapped(2),
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: mintTheme.appBarColor,
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
                        selectedColor: mintTheme.selectedIconColor,
                        unselectedColor: mintTheme.unselectedIconColor,
                      ),
                      _buildNavItem(
                        icon: Icons.person,
                        label: S.of(context)!.profile,
                        index: 4,
                        isSelected: _currentPage == 4,
                        selectedColor: mintTheme.selectedIconColor,
                        unselectedColor: mintTheme.unselectedIconColor,
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
