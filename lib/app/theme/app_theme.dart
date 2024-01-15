import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
class ThemeController extends GetxController {
  var isDarkMode;
  ThemeMode currentThemeMode = ThemeMode.system;
  @override
  void onInit() {
    super.onInit();
    getThemeStatus();
  }
  void getThemeStatus() {
    if (currentThemeMode == ThemeMode.light) {
      isDarkMode.value = false;
    } else if (currentThemeMode == ThemeMode.dark) {
      isDarkMode.value = false;
      isDarkMode.value = false;
      print(isDarkMode.value);
    }
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    saveThemeStatus() async {
      SharedPreferences pref = await _prefs;
      pref.setBool('theme', isDarkMode.value);
    }
    getThemeStatus() async {
      var _isLight = _prefs.then((SharedPreferences prefs) {
        return prefs.getBool('theme') != null ? prefs.getBool('theme') : true;
      }).obs;
      isDarkMode.value = (await _isLight.value)!;
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.light : ThemeMode.dark);
    }
  }
}
class Themes {
  static ThemeData lightTheme = ThemeData(
    backgroundColor: Colors.white,
    primaryColor: Colors.black,
    canvasColor: Colors.red,
    colorScheme: ColorScheme.light(
      primary: Colors.red,
      secondary: Colors.white,
      error: Colors.red,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(
          color: Colors.white
      ),
    ),
    bottomAppBarColor: ColorConstants.gray800,
  );







  static ThemeData darkTheme = ThemeData.dark().copyWith(
    backgroundColor: Colors.black,
    primaryColor: Colors.white,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorConstants.gray900,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorConstants.gray900,
      elevation: 0,
      iconTheme: IconThemeData(
          color: Colors.white
      ),
    ),
    bottomAppBarColor: ColorConstants.gray800,
    inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10)
        ),
        hintStyle: TextStyle(
          fontSize: 14,
        )
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
        color: Colors.white
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
          fontSize: 48,
          color: Colors.white,
          fontWeight: FontWeight.bold
      ),
      headlineMedium: TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold
      ),
      headlineSmall: TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold
      ),
    ),
  );
}