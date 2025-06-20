import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/s.dart';
import '../home/jaibee_home_screen.dart';
import 'onboarding_page_model.dart';
import '../../core/theme/mint_jade_theme.dart';
import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  late List<OnboardingPageModel> _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Always reinitialize pages in case locale has changed
    _pages = [
      OnboardingPageModel(
        title: S.of(context)!.welcomeTitle,
        description: S.of(context)!.welcomeDescription,
        imageAsset: 'assets/images/logo.png',
      ),
      OnboardingPageModel(
        title: S.of(context)!.trackTitle,
        description: S.of(context)!.trackDescription,
        imageAsset: 'assets/onboarding/track.png',
      ),
      OnboardingPageModel(
        title: S.of(context)!.budgetTitle,
        description: S.of(context)!.budgetDescription,
        imageAsset: 'assets/onboarding/budget.png',
      ),
      OnboardingPageModel(
        title: S.of(context)!.adviceTitle,
        description: S.of(context)!.adviceDescription,
        imageAsset: 'assets/onboarding/advice.png',
      ),
    ];
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const JaibeeHomeScreen()),
      );
    }
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
                JaibeeTrackerApp.setLocale(context, const Locale('en'));
              },
            ),
            ListTile(
              title: const Text('🇸🇦 العربية'),
              onTap: () {
                Navigator.pop(context);
                JaibeeTrackerApp.setLocale(context, const Locale('ar'));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mintJade = theme.extension<MintJadeColors>()!;

    return Scaffold(
      body: Stack(
        children: [
          AppBackground(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    itemCount: _pages.length,
                    itemBuilder: (_, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(page.imageAsset, height: 240),
                            const SizedBox(height: 32),
                            Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: mintJade.selectedIconColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              page.description,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: mintJade.unselectedIconColor.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentIndex == index ? 14 : 10,
                      height: _currentIndex == index ? 14 : 10,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? mintJade.selectedIconColor
                            : mintJade.unselectedIconColor.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: mintJade.buttonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_currentIndex == _pages.length - 1) {
                        _finishOnboarding();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _currentIndex == _pages.length - 1
                          ? S.of(context)!.getStarted
                          : S.of(context)!.next,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Language icon at the top-right corner
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: _showLanguageDialog,
                  child: const Icon(Icons.language, color: Colors.blueGrey, size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
