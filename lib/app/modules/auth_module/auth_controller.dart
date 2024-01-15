import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as F_auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_talab_user/app/data/model/User.dart' as userModel;

import '../../../main.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../../userPrefrence.dart';
import '../../utils/constants.dart';
import '../home_module/hoome__page.dart';
import 'otp.dart';

/// GetX Template Generator - fb.com/htngu.99
///

class authController extends GetxController {
  final F_auth.FirebaseAuth auth = F_auth.FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // authController controller = Get.find();

  String? firstName, lastName, email, mobile, password, confirmPassword;

  // final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  final Rxn<userModel.User> _user = Rxn<userModel.User>();

  File? image;

  RxBool isLoading = false.obs;
  final ImagePicker _imagePicker = ImagePicker();

  AutovalidateMode validate = AutovalidateMode.disabled;
  GlobalKey<FormState> loginFormKey = GlobalKey();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();

  AutovalidateMode signUpvalidate = AutovalidateMode.disabled;

  GlobalKey<FormState> signUpFormKey = GlobalKey();

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();

  TextEditingController lastNameController = TextEditingController();
  TextEditingController signUppasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  GlobalKey<FormState> resetFormKey = GlobalKey();
  GlobalKey<FormState> updateFormKey = GlobalKey();

  String resetemailAddress = '';
  late final Rxn<AutovalidateMode> resetvalidate =
      Rxn<AutovalidateMode>(AutovalidateMode.disabled);
  UserPreference userPreference = UserPreference();

  String verificationFailedMessage = "";

  List<int> result = [];

  String? get user => _user.value?.email;

  void CheckIfUserExist(String pin) async {
    Get.dialog(Center(
      child: CircularProgressIndicator(
        color: Colors.red,
      ),
    ));
    mobile = phoneNumberController.text.trim();
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection(USERS);
    QuerySnapshot querySnapshot =
        await usersCollection.where('phoneNumber', isEqualTo: mobile).get();

    if (querySnapshot.docs.isNotEmpty) {
      Get.back();

      var documentSnapshot = querySnapshot.docs.first;
      var data = documentSnapshot.data();

      if (data is Map<String, dynamic>) {
        var user = userModel.User.fromJson(data);

        if (user.password == passwordController.text) {
          loginWithPhone(mobile);
        } else {
          Get.defaultDialog(
            title: "Wrong password".tr,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(
                      "Try again".tr,
                      style: const TextStyle(color: Colors.red),
                    )),
              ],
            ),
          );
        }
      }

      // sendSMS(mobile!, pin);
      //
      // Get.to(const MyVerify(
      //   isLogin: true,
      // ));
    } else {
      Get.back();

      Get.defaultDialog(
        title: "Phone Not Exists".tr,
        content: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text("Please sign up or try another mobile number".tr),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                    onPressed: () {
                      Get.toNamed('/sign_up');
                    },
                    child: Text(
                      "Sign Up".tr,
                      style: const TextStyle(color: Colors.red),
                    )),
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(
                      "Try again".tr,
                      style: const TextStyle(color: Colors.red),
                    )),
              ],
            )
          ],
        ),
      );
    }
  }

  loginWithEmailAndPassword(String email, String password) async {
    Get.dialog(const Center(child: CircularProgressIndicator()));

    dynamic result = await FireStoreUtils.loginWithEmailAndPassword(
        email.trim(), password.trim());
    Get.back();
    if (result != null &&
        result is userModel.User &&
        result.role == USER_ROLE_CUSTOMER) {
      result.fcmToken = await FireStoreUtils.firebaseMessaging.getToken() ?? '';
      await FireStoreUtils.updateCurrentUser(result).then((value) {
        MyApp.currentUser = result;
        UserPreference.saveUserModelToSharedPreferences(result);
        UserPreference.setIsLoggedIn;

        if (MyApp.currentUser!.active == true) {
          Get.toNamed("/home");
        } else {
          Get.defaultDialog(
              title: 'failed'.tr,
              content: Text('accountDisabledContactAdmin'.tr),
              confirm: TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('ok'.tr),
              ));

          // showAlertDialog(context, "accountDisabledContactAdmin".tr(), "", true);
        }
      });
    } else if (result != null && result is String) {
      Get.defaultDialog(
          title: 'failed'.tr,
          content: Text(result),
          confirm: TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('ok'.tr),
          ));
    } else {
      Get.defaultDialog(
          title: 'failed'.tr,
          content: Text('couldNotLogin'.tr),
          confirm: TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('ok'.tr),
          ));
    }
  }

  Future<void> loginWithPhone(mobile) async {
    Get.dialog(Center(
      child: CircularProgressIndicator(
        color: Colors.red,
      ),
    ));
    FireStoreUtils fireStoreUtils = FireStoreUtils();

    var uid = await fireStoreUtils.getUserIdByPhone(mobile);

    if (uid != null) {
      userModel.User? user = await FireStoreUtils.getCurrentUser(uid);
      if (user != null) {
        if (user.role == USER_ROLE_CUSTOMER) {
          if (user.active) {
            user.active = true;
            user.userID = uid;
            user.role = USER_ROLE_CUSTOMER;
            user.fcmToken =
                await FireStoreUtils.firebaseMessaging.getToken() ?? '';
            await FireStoreUtils.updateCurrentUser(user, id: uid);
            MyApp.currentUser = user;
          } else {
            user.lastOnlineTimestamp = Timestamp.now();
            user.fcmToken = "";
            await FireStoreUtils.updateCurrentUser(user);
          }
          UserPreference.saveUserModelToSharedPreferences(user);
          UserPreference.setIsLoggedIn;
          print("SDfsdfsdf");
          MyApp.currentUser = user;
          print(MyApp.currentUser!.phoneNumber);
          savePhoneNumber(user.phoneNumber);

          Get.offAllNamed("/home");
        }
      }
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    countryCodeController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    countryCodeController.text = "+970";
    // TODO: implement onInit
    super.onInit();
    // _user.bindStream(auth.authStateChanges());
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  resetPassword() async {
    if (resetFormKey.currentState?.validate() ?? false) {
      resetFormKey.currentState!.save();
      print("ressssssssssset");
      mobile = phoneNumberController.text.trim();
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection(USERS);
      QuerySnapshot querySnapshot =
          await usersCollection.where('phoneNumber', isEqualTo: mobile).get();

      if (querySnapshot.docs.isNotEmpty) {
        print("dasdasd");
        Get.snackbar(
          "SendingOTP".tr,
          "loading".tr,
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
        );

        result.clear();
        Random random = Random();

        for (int i = 0; i < 6; i++) {
          int randomNumber = random.nextInt(
              10); // Generates a random number between 0 and 9 (inclusive).
          result.add(randomNumber);
        }
        print(result);
        sendSMS(mobile!, result.join());

        Get.to(() => const MyVerify(isLogin: true));

        // ));
      } else {
        Get.defaultDialog(
          title: "Phone Not Exists".tr,
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Text("Please sign up or try another mobile number".tr),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                      onPressed: () {
                        Get.toNamed('/sign_up');
                      },
                      child: Text(
                        "Sign Up".tr,
                        style: const TextStyle(color: Colors.red),
                      )),
                  TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        "Try again".tr,
                        style: const TextStyle(color: Colors.red),
                      )),
                ],
              )
            ],
          ),
        );
      }
    } else {
      resetvalidate.value = AutovalidateMode.onUserInteraction;
    }
  }

  Future<void> sendSMS(String phone, String massage) async {
    String baseURL = "http://sms.htd.ps/API/SendSMS.aspx";
    String apiKey = "b2fc129bfcd43470cbed9c273f6e2326";
    String sender = "super talab";
    String phoneNumber =
        phone; // Replace this with the recipient's phone number
    String message =
        "your otb is $massage"; // Replace this with the desired message

    // Create the URL with query parameters
    String url =
        "$baseURL?id=$apiKey&sender=$sender&to=972$phoneNumber&msg=$message";

    try {
      // Make the GET request
      http.Response response = await http.get(Uri.parse(url));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
      } else {}
    } catch (e) {}
  }

  Future<bool> setFinishedOnBoarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(FINISHED_ON_BOARDING, true);
  }

  signUpWithEmailAndPassword() async {
    Get.dialog(Center(
        child: CircularProgressIndicator(
      color: Color(COLOR_PRIMARY),
    )));
    dynamic result = await FireStoreUtils.firebaseSignUpWithEmailAndPassword(
        email!.trim(), password!.trim(), firstName!, lastName!);

    if (result != null && result is userModel.User) {
      MyApp.currentUser = result;
      UserPreference.saveUserModelToSharedPreferences(result);
      UserPreference.setIsLoggedIn;
      // Get.to(LoginWithPhoneNumber());
      Get.offAllNamed('/home');
    } else if (result != null && result is String) {
      Get.back();
      Get.defaultDialog(
          content: Text(
            result,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(COLOR_PRIMARY),
            ),
          ),
          confirm: TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('ok'.tr,
                  style: TextStyle(
                    color: Color(COLOR_PRIMARY),
                  ))));
    } else {}
  }

  SignWithPhone() async {
    mobile = phoneNumberController.text.trim();
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection(USERS);
    QuerySnapshot querySnapshot =
        await usersCollection.where('phoneNumber', isEqualTo: mobile).get();

    if (querySnapshot.docs.isNotEmpty) {
      Get.defaultDialog(
        title: " Phone Exist",
        content: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text("Please login or try another mobile number"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                    onPressed: () {
                      Get.toNamed('/login');
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.red),
                    )),
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text(
                      "Try again",
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            )
          ],
        ),
      );
    } else {
      userModel.User user = userModel.User(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        fcmToken: await FireStoreUtils.firebaseMessaging.getToken() ?? '',
        phoneNumber: mobile ?? '',
        password: signUppasswordController.text,
        active: true,
        role: USER_ROLE_CUSTOMER,
        lastOnlineTimestamp: Timestamp.now(),
        settings: userModel.UserSettings(),
        email: emailController.text ?? '',
      );

      savePhoneNumber(mobile!);
      String? errorMessage = await FireStoreUtils.firebaseCreateNewUser(user);
      // hideProgress();
      if (errorMessage == null) {
        MyApp.currentUser = user;
        Get.offAllNamed('/home');
        // pushAndRemoveUntil(context, ContainerScreen(user: user), false);
      } else {
        // showAlertDialog(context, "failed".tr(), "notCreateUserPhone".tr(), true);
      }
    }
    // showProgress(true);
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static Future<userModel.User?> signInWithGoogle(
      {required BuildContext context}) async {
    F_auth.FirebaseAuth auth = F_auth.FirebaseAuth.instance;
    F_auth.User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final F_auth.AuthCredential credential =
          F_auth.GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final F_auth.UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;

        userModel.User usermodel = userModel.User(
          firstName: user!.displayName!,
          lastName: "",
          fcmToken: await FireStoreUtils.firebaseMessaging.getToken() ?? '',
          phoneNumber: user.phoneNumber ?? '',
          profilePictureURL: user.photoURL ?? '',
          userID: userCredential.user?.uid ?? '',
          role: USER_ROLE_CUSTOMER,
          active: true,
          lastOnlineTimestamp: Timestamp.now(),
          settings: userModel.UserSettings(),
          email: '',
        );
        FireStoreUtils.firebaseCreateNewUser(usermodel);

        MyApp.currentUser = usermodel;

        UserPreference.saveUserModelToSharedPreferences(usermodel);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool(ISLOGGEDN, true);

        final bool isLoggedIn = prefs.getBool(ISLOGGEDN) ?? false;
        Get.offAllNamed("/home");
      } on F_auth.FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar(
              content: 'The account already exists with a different credential',
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar(
              content: 'Error occurred while accessing credentials. Try again.',
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            content: e.toString(),
          ),
        );
      }
    }
    return null;
  }

  Future<void> updatePassword(String pass, mobile) async {
    FireStoreUtils fireStoreUtils = FireStoreUtils();
    try {
      var uid = await fireStoreUtils.getUserIdByPhone(mobile);
      userModel.User? user = await FireStoreUtils.getCurrentUser(uid!);
      user!.password = pass;
      FireStoreUtils.updateCurrentUser(user);

      Get.snackbar(
        "password updating ".tr,
        "loading".tr,
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        "password updating ".tr,
        e.toString(),
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
