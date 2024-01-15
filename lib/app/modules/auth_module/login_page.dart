import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_talab_user/app/modules/auth_module/auth_controller.dart';
import 'package:super_talab_user/app/modules/auth_module/reset_passord.dart';

import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../shared/componants/def_form_field.dart';

class logingPage extends GetView<authController> {
  const logingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Get.theme.colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(COLOR_PRIMARY),
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Form(
        key: controller.loginFormKey,
        autovalidateMode: controller.validate,
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: Get.height * 0.1,
            ),
            Center(
              child: Text(
                'logIn'.tr,
                style: TextStyle(
                    color: Color(COLOR_PRIMARY),
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
            ),

            /// email address text field, visible when logging with email
            /// and password

            Padding(
              padding:
                  const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(COLOR_PRIMARY)),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                      ),
                      child: Text(
                        '${generateCountryFlag()} +972',
                        style:
                            const TextStyle(fontSize: 18, letterSpacing: 2.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: controller.phoneNumberController,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 18,
                        letterSpacing: 2.0,
                      ),
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.only(left: 16, right: 16),
                        hintText: 'phoneNumber'.tr,
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Color(COLOR_PRIMARY), width: 2.0)),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(Get.context!).colorScheme.error),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(Get.context!).colorScheme.error),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.phone,
                      validator: validateMobile,
                      onSaved: (value) {
                        controller.mobile = value!;
                      },
                    ),
                  ),
                ],
              ),
            ),
            defTextFormField(
                onSaved: (String? val) {
                  controller.password = val;
                },
                controller: controller.passwordController,
                validator: validatePassword,
                hintText: 'password'.tr,
                obscureText: true,
                keyboardType: TextInputType.name),


            Padding(
              padding: const EdgeInsets.only(top: 16, right: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => push(context, ResetPasswordScreen()),
                  child: Text(
                    'Forgot password ?'.tr,
                    style: TextStyle(color: Colors.red.shade300, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 24.0, left: 24.0, top: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(COLOR_PRIMARY),
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(
                        color: Color(COLOR_PRIMARY),
                      ),
                    ),
                  ),
                  child: Text(
                    'logIn'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode() ? Colors.black : Colors.white,
                    ),
                  ),
                  onPressed: () {
                    if (controller.loginFormKey.currentState?.validate() ??
                        false) {

                      controller.CheckIfUserExist(controller.result.join());

                    } else {
                      controller.validate = AutovalidateMode.onUserInteraction;
                    }
                  },
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  String generateCountryFlag() {
    String countryCode = 'ps';

    String flag = countryCode.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));

    return flag;
  }
}
