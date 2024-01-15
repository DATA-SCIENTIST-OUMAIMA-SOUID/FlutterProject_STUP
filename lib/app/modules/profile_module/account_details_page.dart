import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_talab_user/app/modules/profile_module/profile_controller.dart';

import '../../../main.dart';
import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../shared/AppGlobal.dart';

class AccountDetailsPage extends GetView<profileController> {
  const AccountDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppGlobal.buildSimpleAppBar(context, "accountDetails".tr),
          body: SingleChildScrollView(
            child: Form(
              key: controller.key,
              autovalidateMode: controller.validate,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(
                          left: 16.0, right: 16, bottom: 8, top: 24),
                      child: Text(
                        'publicInfo',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                    Material(
                        elevation: 2,
                        color: isDarkMode() ? Colors.black12 : Colors.white,
                        child: ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children:
                                ListTile.divideTiles(context: context, tiles: [
                              ListTile(
                                title: Text(
                                  'firstName'.tr,
                                  style: TextStyle(
                                    color: isDarkMode()
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                trailing: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 100),
                                  child: TextFormField(
                                    controller: controller.firstName,
                                    validator: validateName,
                                    textInputAction: TextInputAction.next,
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: isDarkMode()
                                            ? Colors.white
                                            : Colors.black),
                                    cursorColor: const Color(COLOR_ACCENT),
                                    textCapitalization:
                                        TextCapitalization.words,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'firstName'.tr,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 5)),
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'lastName'.tr,
                                  style: TextStyle(
                                      color: isDarkMode()
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                trailing: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 100),
                                  child: TextFormField(
                                    controller: controller.lastName,
                                    validator: validateName,
                                    textInputAction: TextInputAction.next,
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: isDarkMode()
                                            ? Colors.white
                                            : Colors.black),
                                    cursorColor: const Color(COLOR_ACCENT),
                                    textCapitalization:
                                        TextCapitalization.words,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'lastName'.tr,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 5)),
                                  ),
                                ),
                              ),
                            ]).toList())),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16, bottom: 8, top: 24),
                      child: Text(
                        'privateDetails'.tr,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                    Material(
                      elevation: 2,
                      color: isDarkMode() ? Colors.black12 : Colors.white,
                      child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: ListTile.divideTiles(
                            context: context,
                            tiles: [
                              ListTile(
                                title: Text(
                                  'emailAddress'.tr,
                                  style: TextStyle(
                                      color: isDarkMode()
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                trailing: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 200),
                                  child: TextFormField(
                                    controller: controller.email,
                                    validator: validateEmail,
                                    textInputAction: TextInputAction.next,
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: isDarkMode()
                                            ? Colors.white
                                            : Colors.black),
                                    cursorColor: const Color(COLOR_ACCENT),
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'emailAddress'.tr,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 5)),
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'phoneNumber'.tr,
                                  style: TextStyle(
                                      color: isDarkMode()
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                trailing: InkWell(
                                  onTap: () {
                                    controller.showAlertDialog(Get.context!);
                                  },
                                  child: Text(MyApp.currentUser!.phoneNumber),
                                ),
                              ),
                            ],
                          ).toList()),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 32.0, bottom: 16),
                        child: ConstrainedBox(
                          constraints:
                              const BoxConstraints(minWidth: double.infinity),
                          child: Material(
                            elevation: 2,
                            color: isDarkMode() ? Colors.black12 : Colors.white,
                            child: CupertinoButton(
                              padding: const EdgeInsets.all(12.0),
                              onPressed: () async {
                                controller.validateAndSave();
                              },
                              child: Text(
                                'save'.tr,
                                style: TextStyle(
                                    fontSize: 18, color: Color(COLOR_PRIMARY)),
                              ),
                            ),
                          ),
                        )),
                  ]),
            ),
          )),
    );
  }
}
