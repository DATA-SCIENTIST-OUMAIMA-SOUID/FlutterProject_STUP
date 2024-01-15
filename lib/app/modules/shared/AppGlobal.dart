import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../cart_module/cart_page.dart';

class AppGlobal {
  static double deliveryCharges = 0.0;

  static String? placeHolderImage = "";

  static AppBar buildAppBar(BuildContext context, String title) {
    return AppBar(
      centerTitle: false,
      backgroundColor: Get.theme.colorScheme.background,
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_ios,
          color: Color(COLOR_PRIMARY),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
            fontFamily: "Poppinsm",
            color: isDarkMode() ? Colors.white : Colors.black,
            fontWeight: FontWeight.normal),
      ),
      actions: [
        IconButton(
            padding: const EdgeInsets.only(right: 7),
            icon: Image(
              image: const AssetImage("assets/images/search.png"),
              width: 20,
              color: isDarkMode() ? Colors.white : null,
            ),
            onPressed: () async {
              Get.toNamed('/search');
              await Future.delayed(const Duration(seconds: 1), () {});
            }),
        IconButton(
            padding: const EdgeInsets.only(right: 17),
            tooltip: 'Cart'.tr,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Image(
                  image: const AssetImage("assets/images/cart.png"),
                  width: 20,
                  color: isDarkMode() ? Colors.white : null,
                ),
              ],
            ),
            onPressed: () {
              push(
                context,
                const cartPage(),
              );
            }),
      ],
    );
  }

  static AppBar buildSimpleAppBar(BuildContext context, String title) {
    return AppBar(
      centerTitle: false,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_ios,
          color: Color(COLOR_PRIMARY),
        ),
      ),
      title: Text(title,
          style: TextStyle(
              fontFamily: 'Poppinssb'.tr,
              color: isDarkMode() ? Colors.white : Colors.black)),
    );
  }
}
