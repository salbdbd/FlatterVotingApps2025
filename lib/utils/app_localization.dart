import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings = {};
  Future<void> load() async {
    try {
      String jsonString = await rootBundle
          .loadString('assets/language/${locale.languageCode}.json');
      //   print("Loaded JSON: $jsonString"); // Debug: Check the raw JSON string

      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
      //   print('Loaded translations: $_localizedStrings'); // Debug log
    } catch (error) {
      print('Error loading localization file: $error');
    }
  }

  String translate(String key) {
    if (_localizedStrings[key] == null) {
      print("Can not find translation of $key");
    }
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'bn', 'ar', 'fa', 'hi', 'ur'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
