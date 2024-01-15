import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:super_talab_user/app/modules/shared/componants/custom_Button.dart';
import '../../main.dart';
import '../data/model/User.dart';
import '../data/services/FirebaseHelper.dart';
import '../data/services/helper.dart';
import '../utils/constants.dart';
import 'AccountDetailsScreen.dart';
import 'auth_module/auth_page.dart';
import 'contact_us_module/contact_us_page.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  late User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode() ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile'.tr,
          style: TextStyle(
              color: isDarkMode() ? Colors.white : Colors.black,
              letterSpacing: 1),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Color(COLOR_PRIMARY),
          ),
        ),
      ),
      body: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 1.0, right: 32, left: 32),
          child: Text(
            "${user.firstName} ${user.lastName}",
            style: TextStyle(
                color: isDarkMode() ? Colors.white : Colors.black,
                fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: Get.height * 0.05,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            children: <Widget>[
              ListTile(
                onTap: () {
                  push(context, AccountDetailsScreen(user: user));
                },
                title: Text(
                  "accountDetails".tr,
                  style: const TextStyle(fontSize: 16),
                ),
                leading: const Icon(
                  CupertinoIcons.person_alt,
                  color: Colors.blue,
                ),
              ),
              // ListTile(
              //   onTap: () {
              //     push(context, SettingsScreen(user: user));
              //   },
              //   title: Text(
              //     "settings",
              //     style: TextStyle(fontSize: 16),
              //   ).tr,
              //   leading: Icon(
              //     CupertinoIcons.settings,
              //     color: Colors.grey,
              //   ),
              // ),
              ListTile(
                onTap: () {
                  push(context, const ContactUsScreen());
                },
                title: Text(
                  "contact us".tr,
                  style: const TextStyle(fontSize: 16),
                ),
                leading: Hero(
                  tag: 'contact us'.tr,
                  child: const Icon(
                    CupertinoIcons.phone_solid,
                    color: Colors.green,
                  ),
                ),
              ),
              ListTile(
                onTap: () async {
                  await showalert(
                      "deletingAccount".tr, context, "descdelete".tr);

                  /*await showProgress(context, "deletingAccount".tr, false);
                    await FireStoreUtils.deleteUser();
                    deleteData("phone_number");
                    deleteData("addressModelKey");
                    deleteData("addressModelKey2");
                    await hideProgress();
                    MyApp.currentUser = null;
                    pushAndRemoveUntil(context, authPage(), false);*/
                  //print("ok oumaima");
                },
                title: Text(
                  'Delete Account'.tr,
                  style: TextStyle(fontSize: 16),
                ),
                leading: Icon(
                  CupertinoIcons.delete,
                  color: Colors.red,
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: Get.height * 0.05,
        ),

        Padding(
          padding: const EdgeInsets.only(right: 15.0, left: 15),
          child: CustomButton(
            onPress: () async {
              user.active = false;
              user.lastOnlineTimestamp = Timestamp.now();
              await FireStoreUtils.updateCurrentUser(user);
              deleteData("phone_number");
              deleteData("addressModelKey");
              deleteData("addressModelKey2");

              MyApp.currentUser = null;
              pushAndRemoveUntil(context, authPage(), false);
            },
            text: 'Log Out'.tr,
            color: Color(COLOR_PRIMARY),
          ),
        ),

        // Padding(
        //   padding: const EdgeInsets.all(24.0),
        //   child: ConstrainedBox(
        //     constraints: const BoxConstraints(minWidth: double.infinity),
        //     child: TextButton(
        //       style: TextButton.styleFrom(
        //         backgroundColor: Colors.transparent,
        //         padding: EdgeInsets.only(top: 12, bottom: 12),
        //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: isDarkMode() ? Colors.grey.shade700 : Colors.grey.shade200)),
        //       ),
        //       child: Text(
        //         'Log Out'.tr,
        //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode() ? Colors.white : Colors.black),
        //       ),
        //       onPressed: () async {
        //         //user.active = false;
        //         user.lastOnlineTimestamp = Timestamp.now();
        //         await FireStoreUtils.updateCurrentUser(user);
        //         await auth.FirebaseAuth.instance.signOut();
        //         MyApp.currentUser = null;
        //         pushAndRemoveUntil(context, authPage(), false);
        //       },
        //     ),
        //   ),
        // ),
      ]),
    );
  }

  @override
  void initState() {
    user = widget.user;
    super.initState();
  }
}
