import 'package:flutter/material.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/screens/add_tranc.dart';
import 'package:jaibee1/screens/report.dart';
import 'package:jaibee1/screens/tranc_screen.dart';
import 'package:jaibee1/main.dart';
import 'package:jaibee1/screens/profile.dart';

class ExpenseHomeScreen extends StatefulWidget {
  const ExpenseHomeScreen({super.key});

  @override
  State<ExpenseHomeScreen> createState() => _ExpenseHomeScreenState();
}

class _ExpenseHomeScreenState extends State<ExpenseHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TransactionScreen(),
    const AddTransactionScreen(),
    const ReportsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';

    int navBarIndex = (_selectedIndex == 0)
        ? 0
        : (_selectedIndex == 2)
        ? 1
        : 0;
    bool isFabSelected = _selectedIndex == 1;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        resizeToAvoidBottomInset:
            true, // Let scaffold adjust when keyboard shows
        appBar: AppBar(
          centerTitle: true,
          title: Text(S.of(context)!.appTitle),
          backgroundColor: const Color.fromARGB(255, 130, 148, 179),
          foregroundColor: Colors.white,
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              tooltip: S.of(context)!.changeLanguage,
              onPressed: _showLanguageDialog,
            ),
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: S.of(context)!.profile,
              onPressed: _goToProfile,
            ),
          ],
        ),
        body: _screens[_selectedIndex],
        floatingActionButton: SizedBox(
          height: 64,
          width: 64,
          child: FloatingActionButton(
            onPressed: () => _onItemTapped(1),
            tooltip: S.of(context)!.addTransaction,
            backgroundColor: const Color.fromARGB(255, 130, 148, 179),
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 32),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 130, 148, 179),
          selectedItemColor: isFabSelected
              ? Colors.white.withOpacity(0.6)
              : Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          currentIndex: navBarIndex,
          onTap: (index) {
            if (index == 0) {
              _onItemTapped(0);
            } else if (index == 1) {
              _onItemTapped(2);
            }
          },
          iconSize: 28,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.list),
              label: S.of(context)!.transactions,
              tooltip: S.of(context)!.transactions,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart),
              label: S.of(context)!.reports,
              tooltip: S.of(context)!.reports,
            ),
          ],
        ),
      ),
    );
  }
}
