import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:month_year_picker/month_year_picker.dart';

// -- Your generated localization class (S) --
import 'package:jaibee1/l10n/s.dart';

// -- Models imports (just placeholders here, adjust your real imports) --
import 'package:jaibee1/data/models/trancs.dart';
import 'package:jaibee1/data/models/category.dart';
import 'package:jaibee1/data/models/budget.dart';
import 'package:jaibee1/data/models/goal_model.dart';

// -- Your widgets and features --
import 'package:jaibee1/features/transactions/add_tranc.dart';
import 'package:jaibee1/features/transactions/tranc_screen.dart';
import 'package:jaibee1/features/transactions/manage_categories.dart';
import 'package:jaibee1/features/reports/report.dart';
import 'package:jaibee1/features/profile/profile.dart';
import 'package:jaibee1/features/budget/budget_screen.dart';

import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/shared/widgets/animated_screen_wrapper.dart';
import 'package:jaibee1/shared/widgets/custom_app_bar.dart';

import 'package:jaibee1/core/utils/create_animated_route.dart';
import 'package:jaibee1/core/theme/mint_jade_theme.dart';

// ==================== ExpenseHomeScreen ====================

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
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    final mintTheme = Theme.of(context).extension<MintJadeColors>()!;

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

// ==================== main() and supporting code ====================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(GoalAdapter());

  // Open boxes
  await Hive.openBox('transactions');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<double>('settings');
  await Hive.openBox<Budget>('budgets');
  await Hive.openBox<Goal>('goals');
  await Hive.openBox<Category>('userCategories');

  await addDefaultCategoriesIfEmpty();
  await addDefaultMonthlyLimitIfNotExists();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider()..loadThemeFromHive(),
      child: const ExpenseTrackerApp(),
    ),
  );
}

Future<void> addDefaultCategoriesIfEmpty() async {
  final categoriesBox = Hive.box<Category>('categories');

  if (categoriesBox.isEmpty) {
    final defaultUserCategories = [
      Category(name: 'shopping', icon: 'shopping_cart'),
      Category(name: 'transport', icon: 'directions_car'),
      Category(name: 'food', icon: 'restaurant'),
      Category(name: 'entertainment', icon: 'movie'),
      Category(name: 'home', icon: 'home'),
      Category(name: 'bills', icon: 'credit_card'),
      Category(name: 'other', icon: 'category'),
    ];

    await categoriesBox.addAll(defaultUserCategories);
  }
}

Future<void> addDefaultMonthlyLimitIfNotExists() async {
  final settingsBox = Hive.box<double>('settings');
  if (!settingsBox.containsKey('monthlyLimit')) {
    await settingsBox.put('monthlyLimit', 1000.0);
  }
}

// ==================== ThemeProvider ====================

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'isDarkTheme';
  final Box<double> _settingsBox = Hive.box<double>('settings');

  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  ThemeMode get themeMode => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadThemeFromHive() async {
    _isDarkTheme = (_settingsBox.get(_themeKey) ?? 0) == 1;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkTheme = isDark;
    await _settingsBox.put(_themeKey, isDark ? 1 : 0);
    notifyListeners();
  }
}

// ==================== ExpenseTrackerApp ====================

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    final _ExpenseTrackerAppState? state =
        context.findAncestorStateOfType<_ExpenseTrackerAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Cairo')),
      extensions: <ThemeExtension<dynamic>>[
        const MintJadeColors(
          appBarColor: Color(0xFFE9F4F2),
          navBarColor: Color(0xFFFFFFFF),
          selectedIconColor: Color(0xFFA8E6CF),
          unselectedIconColor: Color(0xFF9EB6B3),
          buttonColor: Color.fromARGB(255, 137, 225, 140),
        ),
      ],
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Cairo')),
      extensions: <ThemeExtension<dynamic>>[
        const MintJadeColors(
          appBarColor: Color(0xFF0A1F1E),
          navBarColor: Color(0xFF071615),
          selectedIconColor: Color(0xFFA8E6CF),
          unselectedIconColor: Color(0xFF3A5A57),
          buttonColor: Color.fromARGB(255, 84, 91, 84),
        ),
      ],
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'جيبي',
      locale: _locale,
      supportedLocales: S.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) return supportedLocale;
        }
        return supportedLocales.first;
      },
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: const ExpenseHomeScreen(),
    );
  }
}
