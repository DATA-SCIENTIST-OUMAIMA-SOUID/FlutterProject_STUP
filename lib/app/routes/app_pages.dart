import 'package:get/get.dart';

import '../../app/modules/auth_module/auth_bindings.dart';
import '../../app/modules/auth_module/auth_page.dart';
import '../../app/modules/cart_module/cart_bindings.dart';
import '../../app/modules/cart_module/cart_page.dart';
import '../../app/modules/contact_us_module/contact_us_bindings.dart';
import '../../app/modules/contact_us_module/contact_us_page.dart';
import '../../app/modules/onboarding_module/onboarding_bindings.dart';
import '../../app/modules/onboarding_module/onboarding_page.dart';
import '../../app/modules/order_module/order_page.dart';
import '../../app/modules/profile_module/profile_bindings.dart';
import '../../app/modules/profile_module/profile_page.dart';
import '../modules/search_module/search_bindings.dart';
import '../../app/modules/search_module/search_page.dart';
import '../data/model/VendorModel.dart';
import '../modules/auth_module/login_page.dart';
import '../modules/auth_module/signUp_page.dart';
import '../modules/category_module/categories_page.dart';
import '../modules/changeaddress_module/changeaddress_bindings.dart';
import '../modules/changeaddress_module/changeaddress_page.dart';
import '../modules/home_module/home_bindings.dart';
import '../modules/home_module/hoome__page.dart';
import '../modules/home_module/view_all_offer_screen.dart';
import '../modules/splash_screen.dart';

part './app_routes.dart';

/// GetX Generator - fb.com/htngu.99
///

abstract class AppPages {
  static final pages = [
    GetPage(
      name: Routes.AUTH,
      page: () => authPage(),
      binding: authBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => onboardingPage(),
      binding: onboardingBinding(),
    ),
    GetPage(
      name: Routes.LOGING,
      page: () => const logingPage(),
      binding: authBinding(),
    ),
    GetPage(
      name: Routes.SIGINUP,
      page: () => SignUp_page(),
      binding: authBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => home_Page(),
      binding: homeBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const profilePage(),
      binding: profileBinding(),
    ),
    GetPage(
      name: Routes.CONTACT_US,
      page: () => const ContactUsScreen(),
      binding: ContactUsBinding(),
    ),
    GetPage(
      name: Routes.ViewAllOffersScreen,
      page: () => const ViewAllOffersScreen(),
      binding: homeBinding(),
    ),
    GetPage(
      name: Routes.CART,
      page: () => const cartPage(),
      binding: cartBinding(),
    ),
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.SEARCH,
      page: () =>  searchPage(),
      binding: searchBinding(),
    ),
    GetPage(
      name: Routes.CATEGORIES,
      page: () => categoriesPage(),
    ),
    GetPage(
      name: Routes.CHANGEADDRESS,
      page: () => const changeaddressPage(),
      binding: changeaddressBinding(),
    ),
    GetPage(
      name: Routes.ORDER,
      page: () => OrdersScreen(),
    ),
  ];

  VendorModel? vendorModel;
}
