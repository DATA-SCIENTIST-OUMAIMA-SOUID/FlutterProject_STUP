import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_talab_user/app/modules/profile_module/profile_controller.dart';

import '../../../main.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../auth_module/auth_page.dart';

/// GetX Template Generator - fb.com/htngu.99
///

class profilePage extends GetView<profileController> {
  const profilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 32, left: 32),
            child: Text(
              controller.user.fullName(),
              style: TextStyle(
                  color: isDarkMode() ? Colors.white : Colors.black,
                  fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: <Widget>[
                ListTile(
                  onTap: () {
                    // push(context, AccountDetailsScreen(user: controller.user));
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
                    // push(context, ContactUsScreen());
                  },
                  title: Text(
                    "contactUs".tr,
                    style: const TextStyle(fontSize: 16),
                  ),
                  leading: Hero(
                    tag: 'contactUs'.tr,
                    child: const Icon(
                      CupertinoIcons.phone_solid,
                      color: Colors.green,
                    ),
                  ),
                ),
                ListTile(
                  onTap: () async {

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm Deletion'.tr),
                          content: Text(
                            'This action cannot be undone. Are you sure?'.tr,
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await showProgress(context, "deletingAccount".tr, false);
                                await FireStoreUtils.deleteUser();
                                await hideProgress();
                                MyApp.currentUser = null;
                                pushAndRemoveUntil(context, authPage(), false);
                                Navigator.of(context).pop();
                                // TODO: Add your deletion logic here
                              },
                              child: Text(
                                'Delete Account'.tr,
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },


                  title: Text(
                    'Delete Account'.tr,
                    style: TextStyle(fontSize: 16),
                  ),
                  leading: Icon(
                    CupertinoIcons.delete,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                          color: isDarkMode()
                              ? Colors.grey.shade700
                              : Colors.grey.shade200)),
                ),
                child: Text(
                  'Log Out'.tr,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode() ? Colors.white : Colors.black),
                ),
                onPressed: () async {
                  //user.active = false;
                  controller.user.lastOnlineTimestamp = Timestamp.now();
                  await FireStoreUtils.updateCurrentUser(controller.user);
                  await auth.FirebaseAuth.instance.signOut();
                  MyApp.currentUser = null;
                  //  pushAndRemoveUntil(context, AuthScreen(), false);
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
