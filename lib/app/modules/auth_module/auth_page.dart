import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_talab_user/app/modules/auth_module/auth_controller.dart';

import '../../../main.dart';
import '../../data/model/User.dart';
import '../../data/services/helper.dart';
import '../../utils/constants.dart';



class authPage extends GetView<authController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Image.asset(
              'assets/images/app_logo.png',
              fit: BoxFit.contain,
              width: 350,
              height: 300,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 16, top: 20, right: 16, bottom: 8),
            child: Text(
              'Welcome to Super Talab'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(COLOR_PRIMARY),
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: Text(
              "Order food from restaurants around you and it will be delivered to you as soon as possible".tr
              ,style: TextStyle(fontSize: 18,
              color:  isDarkMode() ? Colors.white : Colors.black,),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                right: 40.0, left: 40.0, top: 20, bottom: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: TextButton(
                child:  Text(
                  'SKIP'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(COLOR_PRIMARY)),
                ),
                onPressed: () {
                  MyApp.currentUser = User();
                  Get.offAllNamed('/home');
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.only(top: 12, bottom: 12),
                  ),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(
                        color: Color(COLOR_PRIMARY),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0, ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(COLOR_PRIMARY),
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(
                      color: Color(COLOR_PRIMARY),
                    ),
                  ),
                ),
                child: Text(
                  'Log In'.tr,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                onPressed: () {
                  print("object");
                  debugPrint(",jhnjh,j");
                  Get.toNamed('/login');
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                right: 40.0, left: 40.0, top: 20, bottom: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: TextButton(
                child: Text(
                  'Sign Up'.tr,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(COLOR_PRIMARY)),
                ),
                onPressed: () {
                  // Get.to(LoginWithPhoneNumber());

                  Get.toNamed('/sign_up');
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.only(top: 12, bottom: 12),
                  ),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(
                        color: Color(COLOR_PRIMARY),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
