import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class onboardingController extends GetxController{
  final List<String> titlesList = [
    // easyLocal.tr('Welcome to FOODIES'),
    // 'Order Food'.tr,
    'Choose Your Favorite Food'.tr,
    'Fastest Delivery'.tr,
    ''.tr,

  ];

  final List<String> subtitlesList = [
    // 'Log in and order delicious food from restaurants around you.'.tr,
    // 'Hungry? Order food in just a few clicks and we\'ll take care of you.'.tr,
    'Find perfect restaurant nearby or  place order at your favorite restaurant in few clicks.'.tr,
    'A diverse list of different dining restaurants throughout the territory and around your area carefully selected'.tr,
    ''.tr,

  ];

  final List<dynamic> imageList = [
    'assets/images/intro_2.png',
    'assets/images/intro_1.png',
    'assets/images/intro_3.png',
  ];
  final List<dynamic> darkimageList = [
    'assets/images/intro_1_dark.png',
    'assets/images/intro_2_dark.png',
    'assets/images/intro_3_dark.png',
  ];
  RxInt currentIndex = 0.obs;



  Future<bool> setFinishedOnBoarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(FINISHED_ON_BOARDING, true);
  }
}
