import 'package:flutter/material.dart';
import 'package:jaibee/shared/widgets/custom_app_bar.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: isArabic ? 'شروط الخدمة' : 'Terms of Service',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'شروط الخدمة' : 'Terms of Service',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Text(
                  '''
Effective Date: 06/24/2025

Welcome to Jaibee! By using our app, you agree to the following terms and conditions. Please read them carefully.

1. Acceptance of Terms
By accessing or using Jaibee (“the App”), you agree to be bound by these Terms of Service and our Privacy Policy. If you do not agree, please do not use the App.

2. Use of the App
The App is intended for personal finance tracking and budgeting only.
You must be at least 13 years old to use the App.
You agree not to use the App for any unlawful or prohibited purpose.

3. User Data & Privacy
The App stores your data locally on your device using secure storage (Hive database).
We do not collect or transmit your financial data unless you explicitly use export or backup features.
Please review our Privacy Policy for more details.

4. Account and Security
If you use any authentication or backup features, you are responsible for maintaining the confidentiality of your credentials.
You are responsible for all activities that occur under your account.

5. Financial Advice Disclaimer
The App provides information and tools for personal finance management only.
The App does not provide professional financial, legal, or tax advice.
All reports, recommendations, and analytics are for informational purposes only. You are solely responsible for any financial decisions you make.

6. Intellectual Property
All content, trademarks, logos, and code in the App are the property of the developer.
You may not copy, modify, distribute, or reverse engineer any part of the App.

7. Limitation of Liability
The App is provided “as is” without warranties of any kind.
The developer is not liable for any direct, indirect, incidental, or consequential damages arising from your use of the App.

8. Changes to the Terms
We may update these Terms from time to time. Continued use of the App after changes means you accept the new Terms.

9. Termination
We reserve the right to suspend or terminate your access to the App at any time, without notice, for conduct that violates these Terms.

10. Contact
If you have any questions about these Terms, please contact us at jaibee.care@gmail.com.
''',
                  style: const TextStyle(fontSize: 15, height: 1.7),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}