import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;
  final Locale locale;

  Language(this.id, this.flag, this.name, this.languageCode, this.locale);

  static List<Language> languageList() {
    return <Language>[
      Language(2, "🇺🇸", "English", "en", Locale('en', 'US')),
      Language(3, "🇵🇸", "اَلْعَرَبِيَّةُ‎", "ar", Locale('ar', 'PS')),
    ];
  }
}
