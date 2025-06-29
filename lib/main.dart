import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jaibee/features/home/jaibee_home_screen.dart';
import 'package:provider/provider.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/mint_jade_theme.dart';
import 'l10n/s.dart';
import 'data/models/budget.dart';
import 'data/models/category.dart';
import 'data/models/goal_model.dart';
import 'data/models/trancs.dart';
import 'features/home/splash_screen.dart';
import 'core/services/notification_service.dart';
import 'features/transactions/transaction_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('onboarding_completed') ?? false;

  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(GoalAdapter());

  // Place this before opening the 'categories' box, if you want to delete it before use.
  // await Hive.deleteBoxFromDisk('categories');
  // await Hive.deleteBoxFromDisk('transactions');
  // await Hive.deleteBoxFromDisk('budgets');

  await Hive.openBox('transactions');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<double>('settings');
  await Hive.openBox<Budget>('budgets');
  await Hive.openBox<Goal>('goals');
  await Hive.openBox<Category>('userCategories');

  // await prefs.clear(); // ← to test the onboarding screen ONLY

  // Remove this line in production

  await _addDefaultCategoriesIfEmpty();
  await _addDefaultMonthlyLimitIfNotExists();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: JaibeeTrackerApp(
        initialRoute: seenOnboarding ? 'home' : 'onboarding',
      ),
    ),
  );
}

Future<void> _addDefaultCategoriesIfEmpty() async {
  final categoriesBox = Hive.box<Category>('categories');
  if (categoriesBox.isEmpty) {
    final defaultCategories = [
      Category(name: 'food', icon: 'restaurant'),
      Category(name: 'coffee', icon: 'coffee'),
      Category(name: 'shopping', icon: 'shopping_cart'),
      Category(name: 'transport', icon: 'directions_car'),
      Category(name: 'entertainment', icon: 'movie'),
      Category(name: 'home', icon: 'home'),
      Category(name: 'bills', icon: 'credit_card'),
      Category(name: 'other', icon: 'category'),
    ];
    await categoriesBox.addAll(defaultCategories);
  }
}

Future<void> _addDefaultMonthlyLimitIfNotExists() async {
  final settingsBox = Hive.box<double>('settings');
  if (!settingsBox.containsKey('monthlyLimit')) {
    await settingsBox.put('monthlyLimit', 1000.0);
  }
}

class JaibeeTrackerApp extends StatefulWidget {
  final String initialRoute;
  const JaibeeTrackerApp({super.key, required this.initialRoute});

  static void setLocale(BuildContext context, Locale newLocale) {
    final state = context.findAncestorStateOfType<_JaibeeTrackerAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<JaibeeTrackerApp> createState() => _JaibeeTrackerAppState();
}

class _JaibeeTrackerAppState extends State<JaibeeTrackerApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale');
    if (code != null) {
      setState(() {
        _locale = Locale(code);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Cairo')),
      extensions: const <ThemeExtension<dynamic>>[
        MintJadeColors(
          appBarColor: Color(0xFFE9F4F2),
          navBarColor: Color(0xFFF5F5F5), // Light gray for clarity
          selectedIconColor: Color(0xFF009688), // Strong teal
          unselectedIconColor: Color(0xFF9E9E9E), // Neutral dark grey
          buttonColor: Colors.teal,
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
      extensions: const <ThemeExtension<dynamic>>[
        MintJadeColors(
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
        for (var supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) return supported;
        }
        return supportedLocales.first;
      },
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(), // Always show splash first
      routes: {
        '/transactions': (context) => JaibeeHomeScreen(),
        // Add other routes here if needed
      },
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          behavior: HitTestBehavior.opaque,
          child: child!,
        );
      },
    );
  }
}
