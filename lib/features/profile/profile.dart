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
import 'package:jaibee1/features/reports/export_report_screen.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile header
              // Container(
              //   padding: const EdgeInsets.symmetric(vertical: 24),
              //   child: Column(
              //     children: [
              //       CircleAvatar(
              //         radius: 38,
              //         backgroundColor: mintTheme.buttonColor.withOpacity(0.1),
              //         child: Icon(Icons.person, size: 48, color: mintTheme.buttonColor),
              //       ),
              //       const SizedBox(height: 12),
              //       Text(
              //         s.profile,
              //         style: Theme.of(context).textTheme.titleLarge?.copyWith(
              //               fontWeight: FontWeight.bold,
              //               fontSize: 22,
              //             ),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 10),

              // Settings Section
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  ],
                ),
              ),

              // Main Actions Section
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    _buildCardTile(
                      icon: Icons.flag,
                      label: s.setGoals,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GoalsScreen()),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: _buildCardTile(
                  icon: Icons.local_cafe_outlined,
                  label: s.buyMeACoffee,
                  onTap: _launchBuyMeACoffee,
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
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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