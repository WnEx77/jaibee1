import 'package:flutter/material.dart';
import 'package:jaibee/shared/widgets/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
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
                  isArabic
                      ? '''
خصوصيتك مهمة بالنسبة لنا. يوضح هذا المستند كيف يقوم تطبيق "جيبي" بجمع واستخدام وحماية معلوماتك عند استخدامك للتطبيق.

1. **المعلومات التي نجمعها**
- لا نقوم بجمع أو تخزين أي معلومات تعريف شخصية مثل الاسم أو البريد الإلكتروني أو رقم الهاتف على أي خوادم خارجية.
- جميع بياناتك المالية (المعاملات، الميزانيات، الفئات، الأهداف، التفضيلات) يتم تخزينها محليًا على جهازك باستخدام قاعدة بيانات Hive.
- تفضيلاتك (مثل اللغة، السمة) يتم تخزينها محليًا باستخدام SharedPreferences.

2. **استخدام الإنترنت**
- قد يتصل التطبيق بالإنترنت فقط لجلب نصائح مالية ذكية (عبر خدمة الذكاء الاصطناعي) أو تحميل بعض الرموز أو الرسوم المتحركة.
- عند طلب النصيحة المالية، قد يتم إرسال ملخصك المالي وتفضيلاتك إلى خدمة الذكاء الاصطناعي، دون أي معلومات تعريف شخصية.

3. **الأمان**
- جميع بياناتك الحساسة مخزنة محليًا على جهازك فقط.
- لا يمكننا الوصول إلى بياناتك.
- عند حذف التطبيق، سيتم حذف جميع بياناتك من الجهاز.

4. **مشاركة البيانات**
- لا نشارك بياناتك مع أي طرف ثالث، باستثناء ما ترسله بنفسك عند طلب النصيحة المالية من الذكاء الاصطناعي.

5. **حقوق المستخدم**
- يمكنك حذف بياناتك في أي وقت عن طريق حذف التطبيق.
- يمكنك تغيير تفضيلاتك (اللغة، السمة) من داخل التطبيق.

6. **التغييرات على السياسة**
- قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سيتم عرض أي تغييرات داخل التطبيق.

للاستفسار أو الدعم، يرجى التواصل معنا عبر البريد الإلكتروني: jaibee.care@gmail.com
'''
                      : '''
Your privacy is important to us. This document explains how the "Jaibee" app collects, uses, and protects your information when you use the app.

1. **Information We Collect**
- We do not collect or store any personally identifiable information such as name, email, or phone number on any external servers.
- All your financial data (transactions, budgets, categories, goals, preferences) is stored locally on your device using the Hive database.
- Your preferences (such as language, theme) are stored locally using SharedPreferences.

2. **Internet Usage**
- The app may connect to the internet only to fetch smart financial advice (via AI service) or to download some icons or animations.
- When requesting financial advice, your financial summary and preferences may be sent to the AI service, but no personally identifiable information is sent.

3. **Security**
- All your sensitive data is stored locally on your device only.
- We do not have access to your data.
- If you uninstall the app, all your data will be deleted from the device.

4. **Data Sharing**
- We do not share your data with any third parties, except what you explicitly send when requesting AI financial advice.

5. **User Rights**
- You can delete your data at any time by uninstalling the app.
- You can change your preferences (language, theme) within the app.

6. **Changes to This Policy**
- We may update the privacy policy from time to time. Any changes will be shown inside the app.

For inquiries or support, please contact us at: jaibee.care@gmail.com
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