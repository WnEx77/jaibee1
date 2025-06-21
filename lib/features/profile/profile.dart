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
      builder: (_) => AlertDialog(
        title: Text(S.of(context)!.changeLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('🇺🇸 English'),
              onTap: () {
                Navigator.pop(context);
                _changeLanguage('en');
              },
            ),
            ListTile(
              title: const Text('🇸🇦 العربية'),
              onTap: () {
                Navigator.pop(context);
                _changeLanguage('ar');
              },
            ),
          ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email client')),
      );
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
