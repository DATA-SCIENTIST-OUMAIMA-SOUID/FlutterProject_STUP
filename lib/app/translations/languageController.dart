/*import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/model/Language.dart';
import 'local_storge.dart';

class LanguageController extends GetxController {
  late Language appLocale ;
  void changeLanguage(String type) async {
    LocalStorage localStorage = LocalStorage();
    if (appLocale == type) {
      return;
    }
    if (type == 'ar') {
      appLocale.languageCode = 'ar';
      LocalStorage.saveLanguageToDisk('ar');
    } else {
      appLocale.languageCode = 'en';
      LocalStorage.saveLanguageToDisk('en');
    }
    update();
  }

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();

    LocalStorage localStorage = LocalStorage();
    appLocale = await LocalStorage.languageSelected  ?? 'ar';
    Get.updateLocale(Locale(appLocale));
    update();
  }
}*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_talab_user/app/translations/local_storge.dart';

import '../data/model/Language.dart';
/*
class LanguageController extends GetxController {
  late Language appLocale = Language(3, "🇵🇸", "اَلْعَرَبِيَّةُ‎", "ar");

  void changeLanguage(String type) async {
    LocalStorage localStorage = LocalStorage();
    if (appLocale.languageCode == type) {
      return;
    }
    if (type == 'ar') {
      appLocale = Language(3, "🇵🇸", "اَلْعَرَبِيَّةُ‎", "ar");
      LocalStorage.saveLanguageToDisk(appLocale);
    } else {
      appLocale = Language(2, "🇺🇸", "English", "en");
      LocalStorage.saveLanguageToDisk(appLocale);
    }
    Get.updateLocale(Locale(appLocale.languageCode));
    update();
  }

  @override
  onInit() async {
    super.onInit();

    LocalStorage localStorage = LocalStorage();
    appLocale = (await LocalStorage.languageSelected) ??
        Language(3, "🇵🇸", "اَلْعَرَبِيَّةُ‎", "ar");
    Get.updateLocale(Locale(appLocale.languageCode));
    update();
  }
}
*/

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mycontroll extends GetxController {
  RxString? langCode;
  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    langCode = prefs.getString('locale') as RxString?;
    if (langCode != null) {
      changeLanguage(Locale(langCode as String));
    }
  }

  Future<void> changeLanguage(Locale locale) async {
    await Get.updateLocale(locale);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    await getSavedLanguageCode();
    langCode = await getSavedLanguageCode();
  }

  Future<RxString?> getSavedLanguageCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    langCode = prefs.getString('locale')?.obs;
    return langCode;
  }
}
