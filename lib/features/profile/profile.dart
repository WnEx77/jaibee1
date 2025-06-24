import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:jaibee/l10n/s.dart';
import 'package:jaibee/main.dart';
import 'package:jaibee/features/goals/goals_screen.dart';
import 'package:jaibee/features/about/about_us_screen.dart';
import 'package:jaibee/features/webview/webview_screen.dart';
import 'package:jaibee/core/theme/theme_provider.dart';
import 'package:jaibee/shared/widgets/app_background.dart';
import 'package:jaibee/features/reports/export_report_screen.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:jaibee/features/about/privacy_policy_screen.dart';
import 'package:jaibee/core/utils/currency_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _goalsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _goalsController.text = prefs.getString('user_goals') ?? '';
    });
  }

  void _changeLanguage(String langCode) {
    JaibeeTrackerApp.setLocale(context, Locale(langCode));
  }

  void _showLanguageDialog() {
    final s = S.of(context)!;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                s.changeLanguage,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(
                flag: '🇸🇦',
                language: s.arabic,
                onTap: () {
                  Navigator.pop(context);
                  _changeLanguage('ar');
                },
              ),
              const SizedBox(height: 10),
              _buildLanguageOption(
                flag: '🇺🇸',
                language: s.english,
                onTap: () {
                  Navigator.pop(context);
                  _changeLanguage('en');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String flag,
    required String language,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Text(language, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }

  void _launchBuyMeACoffee() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const InAppWebViewScreen(url: 'https://buymeacoffee.com/wnex77'),
      ),
    );
  }

  Future<void> _contactSupport() async {
    final s = S.of(context)!;
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'jaibee.care@gmail.com',
      query: 'subject=Contact%20Support',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      // ignore: use_build_context_synchronously
      Flushbar(
        message: s.couldNotLaunchEmailClient,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      ).show(context);
    }
  }

  Future<void> _openSupportPage() async {
    final s = S.of(context)!;
    final url = Uri.parse('https://github.com/wnex77/jaibee1/issues');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Flushbar(
        message: s.couldNotOpenSupportPage,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      ).show(context);
    }
  }

  Future<void> _showCurrencyPicker(BuildContext context) async {
    final s = S.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    String currentCode = prefs.getString('currency_code') ?? 'SAR';

    // Always show Saudi Riyal symbol with teal color
    final saudiRiyal = supportedCurrencies.firstWhere(
      (c) => c.code == 'SAR',
      orElse: () => supportedCurrencies.first,
    );
    final saudiAsset = saudiRiyal.getAsset(
      isDarkMode: Theme.of(context).brightness == Brightness.dark,
    );

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (saudiAsset != null)
                  Image.asset(
                    saudiAsset,
                    width: 52,
                    height: 52,
                    color: Colors.teal,
                  )
                else
                  Icon(Icons.attach_money, size: 52, color: Colors.teal),
                const SizedBox(height: 12),
                Text(
                  s.selectCurrency,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ...supportedCurrencies.map(
                  (currency) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: _buildCurrencyOption(
                      currency: currency,
                      isSelected: currentCode == currency.code,
                      onTap: () async {
                        await prefs.setString('currency_code', currency.code);
                        Navigator.pop(context);
                        setState(() {}); // Refresh UI
                        // Show flushbar after currency update
                        Flushbar(
                          message: s.currencyUpdated,
                          duration: const Duration(seconds: 2),
                          backgroundColor: Colors.green,
                          margin: const EdgeInsets.all(16),
                          borderRadius: BorderRadius.circular(12),
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                        ).show(context);
                      },
                      // Localize currency name:
                      localizedName: _getLocalizedCurrencyName(currency, s),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyOption({
    required AppCurrency currency,
    required bool isSelected,
    required VoidCallback onTap,
    String? localizedName,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = currency.getAsset(isDarkMode: isDark);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.15)
              : Theme.of(context).colorScheme.secondary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              asset != null
                  ? Image.asset(asset, width: 22, height: 22)
                  : Text(currency.symbol, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Text(
                localizedName ?? '${currency.name} (${currency.code})',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check, color: Colors.teal, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper to localize currency names
  String _getLocalizedCurrencyName(AppCurrency currency, S s) {
    switch (currency.code) {
      case 'SAR':
        return s.saudiRiyal;
      case 'USD':
        return s.usDollar;
      case 'EUR':
        return s.euro;
      default:
        return '${currency.name} (${currency.code})';
    }
  }

  Future<Widget> buildCurrencySymbolWidget(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('currency_code') ?? 'SAR';
    final currency = getCurrencyByCode(code);

    // Use theme from context for dark mode
    // final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = currency.getAsset();
    if (asset != null) {
      return Image.asset(asset, width: 26, height: 26, color: Colors.teal);
    } else {
      return Text(
        currency.symbol,
        style: const TextStyle(fontSize: 26, color: Colors.teal),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;

    return Scaffold(
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Settings Section
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildCardTile(
                      icon: Icons.language,
                      label: s.changeLanguage,
                      onTap: _showLanguageDialog,
                    ),
                    _buildDivider(),
                    Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: SizedBox(
                              width: 28, // Fixed width for all currency icons
                              height: 28,
                              child: Center(
                                child: FutureBuilder<Widget>(
                                  future: buildCurrencySymbolWidget(context),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData) {
                                      return snapshot.data!;
                                    }
                                    return const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            title: Text(
                              s.currency,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onTap: () => _showCurrencyPicker(context),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minLeadingWidth: 0,
                            visualDensity: const VisualDensity(vertical: -2),
                          ),
                          _buildDivider(),
                          ListTile(
                            leading: const Icon(
                              Icons.brightness_6,
                              color: Colors.blueGrey,
                            ),
                            title: Text(
                              s.darkMode,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            trailing: Consumer<ThemeProvider>(
                              builder: (context, themeProvider, _) {
                                return Switch(
                                  value: themeProvider.isDarkTheme,
                                  onChanged: themeProvider.toggleTheme,
                                );
                              },
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minLeadingWidth: 0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Actions Section
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildCardTile(
                      icon: Icons.flag,
                      label: s.setGoals,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GoalsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildCardTile(
                      icon: Icons.picture_as_pdf,
                      label: s.exportTransactionsAsPdf,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExportReportScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Info Section
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildCardTile(
                      icon: Icons.account_circle_outlined,
                      label: s.aboutUs,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AboutUsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildCardTile(
                      icon: Icons.privacy_tip_outlined,
                      label: s.privacyPolicy,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildCardTile(
                      icon: Icons.email_outlined,
                      label: s.contactUs,
                      onTap: _contactSupport,
                    ),
                  ],
                ),
              ),

              // Support Section
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildCardTile(
                      icon: Icons.local_cafe_outlined,
                      label: s.buyMeACoffee,
                      onTap: _launchBuyMeACoffee,
                    ),
                    _buildDivider(),
                    _buildCardTile(
                      icon: Icons.support_agent,
                      label: s.supportAndFeedback,
                      onTap: _openSupportPage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal, size: 28),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minLeadingWidth: 0,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 0,
        thickness: 0.7,
        color: Colors.grey.withOpacity(0.18),
      ),
    );
  }
}
