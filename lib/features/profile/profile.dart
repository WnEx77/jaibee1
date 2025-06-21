import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/main.dart';
import 'package:jaibee1/features/goals/goals_screen.dart';
import 'package:jaibee1/features/about/about_us_screen.dart';
import 'package:jaibee1/features/webview/webview_screen.dart';
import 'package:jaibee1/core/theme/theme_provider.dart';
import 'package:jaibee1/core/theme/mint_jade_theme.dart';
import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/features/reports/export_report_screen.dart'; // Add this import
import 'package:another_flushbar/flushbar.dart';
import 'package:jaibee1/features/about/privacy_policy_screen.dart';

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
                S.of(context)!.changeLanguage,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(
                flag: '🇸🇦',
                language: 'العربية',
                onTap: () {
                  Navigator.pop(context);
                  _changeLanguage('ar');
                },
              ),
              const SizedBox(height: 10),
              _buildLanguageOption(
                flag: '🇺🇸',
                language: 'English',
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
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'amoharib77@gmail.com',
      query: 'subject=Contact%20Support',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      // ignore: use_build_context_synchronously
      Flushbar(
        message: 'Could not launch email client',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final mintTheme = Theme.of(context).extension<MintJadeColors>()!;

    return Scaffold(
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Language Selection
              _buildCardTile(
                icon: Icons.language,
                label: s.changeLanguage,
                onTap: _showLanguageDialog,
              ),

              // Dark Mode Toggle
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.brightness_6,
                    color: Colors.blueGrey,
                  ),
                  title: Text(s.darkMode),
                  trailing: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return Switch(
                        value: themeProvider.isDarkTheme,
                        onChanged: themeProvider.toggleTheme,
                      );
                    },
                  ),
                ),
              ),

              // About Us
              _buildCardTile(
                icon: Icons.account_circle_outlined,
                label: s.aboutUs,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                  );
                },
              ),

              // Contact Us
              _buildCardTile(
                icon: Icons.email_outlined,
                label: s.contactUs,
                onTap: _contactSupport,
              ),

              // Privacy Policy
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

              const SizedBox(height: 20),

              // Set Goals
              ElevatedButton.icon(
                icon: const Icon(Icons.flag),
                label: Text(s.setGoals),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mintTheme.unselectedIconColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GoalsScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Buy Me a Coffee
              ElevatedButton.icon(
                icon: Image.asset(
                  'assets/images/buy-me-a-coffee.png',
                  height: 30,
                  width: 30,
                ),
                label: Text(s.buyMeACoffee),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _launchBuyMeACoffee,
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueGrey),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
