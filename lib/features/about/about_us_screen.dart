import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/l10n/s.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
    with SingleTickerProviderStateMixin {
  String _appVersion = '';
  // String _appName = '';
  String _packageName = '';
  String _buildNumber = '';

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadVersion();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
      // _appName = info.appName;
      _packageName = info.packageName;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseTextColor = isDark ? Colors.white70 : Colors.black87;
    final subTextColor = isDark ? Colors.white60 : Colors.black54;
    final lightTextColor = isDark ? Colors.white38 : Colors.black38;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(localizer.aboutUs),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/logo.png',
                    width: 100, // equivalent to diameter of radius 50
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Jaibee',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: baseTextColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_appVersion.isNotEmpty)
                    Text(
                      'v$_appVersion ($_buildNumber)',
                      style: TextStyle(
                        color: baseTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const SizedBox(height: 28),
                  Text(
                    localizer.aboutAppDescription,
                    style: TextStyle(
                      fontSize: 17,
                      color: baseTextColor,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      Icon(Icons.info_outline, color: subTextColor),
                      const SizedBox(height: 4),
                      Text(
                        'Package ID: $_packageName',
                        style: TextStyle(color: subTextColor),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        '${localizer.developedBy}: Abdulrahman Bin Moharib',
                        style: TextStyle(color: subTextColor, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📧 jaibee.care@gmail.com',
                        style: TextStyle(color: subTextColor, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '© 2025 JaiBee App',
                        style: TextStyle(fontSize: 12, color: lightTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
