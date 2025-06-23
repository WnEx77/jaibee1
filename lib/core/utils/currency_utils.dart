import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppCurrency {
  final String code;
  final String symbol;
  final String name;
  final String? asset; // For image asset if needed

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.name,
    this.asset,
  });

  String? getAsset({bool isDarkMode = false}) {
    if (asset == null) return null;
    if (isDarkMode && code == 'SAR') {
      return 'assets/images/Saudi_Riyal_Symbol_DarkMode.png';
    }
    return asset;
  }
}

const List<AppCurrency> supportedCurrencies = [
  AppCurrency(
    code: 'SAR',
    symbol: '﷼',
    name: 'Saudi Riyal',
    asset: 'assets/images/Saudi_Riyal_Symbol.png',
  ),
  AppCurrency(code: 'USD', symbol: '\$', name: 'US Dollar'),
  AppCurrency(code: 'EUR', symbol: '€', name: 'Euro'),
];

AppCurrency getCurrencyByCode(String code) {
  return supportedCurrencies.firstWhere(
    (c) => c.code == code,
    orElse: () => supportedCurrencies.first,
  );
}

Future<Widget> buildCurrencySymbolWidget(
  BuildContext context, {
  Color? color,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('currency_code') ?? 'SAR';
  final currency = getCurrencyByCode(code);

  final isDark = Theme.of(context).brightness == Brightness.dark;
  final asset = currency.getAsset(isDarkMode: isDark);
  final symbolColor = color ?? (isDark ? Colors.white : Colors.black);

  if (asset != null) {
    return Image.asset(asset, width: 22, height: 22, color: symbolColor);
  } else {
    return Text(
      currency.symbol,
      style: TextStyle(fontSize: 22, color: symbolColor),
    );
  }
}
