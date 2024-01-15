import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../data/model/User.dart';
import '../data/provider/localDatabase.dart';
import '../data/services/FirebaseHelper.dart';
import '../data/services/helper.dart';
import '../routes/app_pages.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isFinishedOnBoarding = false;
  final FireStoreUtils _fireStoreUtils = FireStoreUtils();

  var isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/app_logo.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }

  Future<void> checkOnBoardingStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    isLoggedIn = prefs.getBool(ISLOGGEDN) ?? false;
    isFinishedOnBoarding = prefs.getBool(FINISHED_ON_BOARDING) ?? false;
  }

  @override
  void initState() {
    super.initState();
    checkOnBoardingStatus();
    navigateToNextScreen();
  }

  Future<void> navigateToNextScreen() async {
    await Future.delayed(const Duration(microseconds: 1));
    // Simulating a delay for splash screen

    if (isFinishedOnBoarding) {
      InternetConnectionChecker().onStatusChange.listen((connectionStatus) {
// Display a message whenever the connection status changes.
      });
      var connectionStatus =
          await (InternetConnectionChecker().connectionStatus);

      // Display a message depending on the connection status.
      if (connectionStatus == InternetConnectionStatus.connected) {
      } else {
        Get.dialog(Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Please check your internet connection.'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ));
      }
      var phone = await getPhoneNumber();
print(phone);
      if (phone != null && phone != "") {
        var uid = await _fireStoreUtils.getUserIdByPhone(phone);
print(uid);
        if (uid != null) {
          User? user = await FireStoreUtils.getCurrentUser(uid);
          if (user != null) {
            print(user.role);
            if (user.role == USER_ROLE_CUSTOMER) {

                print(user.active);
                user.active = true;
                user.userID = uid;
                user.role = USER_ROLE_CUSTOMER;
                user.fcmToken =
                    await FireStoreUtils.firebaseMessaging.getToken() ?? '';
                await FireStoreUtils.updateCurrentUser(user, id: uid);
                MyApp.currentUser = user;
                Navigator.pushReplacementNamed(context, Routes.HOME);

            } else {
              Navigator.pushReplacementNamed(context, Routes.AUTH);
            }
          } else {
            Navigator.pushReplacementNamed(context, Routes.AUTH);
          }
        } else {
          Navigator.pushReplacementNamed(context, Routes.AUTH);
        }
      } else {
        Navigator.pushReplacementNamed(context, Routes.AUTH);
      }
    } else {
      Navigator.pushReplacementNamed(context, Routes.ONBOARDING);
    }
  }
}
