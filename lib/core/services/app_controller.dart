import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends ChangeNotifier {
  Locale _locale = const Locale('ar'); // 👈 عربي افتراضي

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  /// تحميل اللغة من التخزين
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code');

    if (langCode != null && (langCode == 'ar' || langCode == 'en')) {
      _locale = Locale(langCode);
      notifyListeners();
    }
  }

  /// تغيير اللغة + حفظها
  Future<void> changeLanguage(String langCode) async {
    if (langCode == _locale.languageCode) return;

    _locale = Locale(langCode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
  }
}
