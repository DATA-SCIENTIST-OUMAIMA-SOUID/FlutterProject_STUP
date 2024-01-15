import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../shared/componants/def_form_field.dart';
import 'auth_controller.dart';
import 'otp.dart';

class SignUp_page extends GetView<authController> {
  File? _image;
  String verificationFailedMessage = "";

  final ImagePicker _imagePicker = ImagePicker();

  SignUp_page({super.key});

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
      body: SingleChildScrollView(
        child: Form(
          key: controller.signUpFormKey,
          autovalidateMode: controller.signUpvalidate,
          child: formUI(),
        ),
      ),
    );
  }

  Widget formUI() {
    return Column(
      children: <Widget>[
        Center(
          child: Text(
            'createNewAccount'.tr,
            style: TextStyle(
                color: Color(COLOR_PRIMARY),
                fontWeight: FontWeight.bold,
                fontSize: 25.0),
          ),
        ),
        defTextFormField(
            onSaved: (String? val) {
              controller.firstName = val;
            },
            validator: validateName,
            hintText: 'firstName'.tr,
            controller: controller.firstNameController,
            keyboardType: TextInputType.name),
        defTextFormField(
            onSaved: (String? val) {
              controller.lastName = val;
            },
            controller: controller.lastNameController,
            validator: validateName,
            hintText: 'lastName'.tr,
            keyboardType: TextInputType.name),
        defTextFormField(
            onSaved: (String? val) {
              controller.email = val;
            },
            controller: controller.emailController,
            validator: validateEmail,
            hintText: 'emailAddress (optional)'.tr,
            keyboardType: TextInputType.emailAddress),
        defTextFormField(
            onSaved: (String? val) {
              controller.password = val;
            },
            controller: controller.signUppasswordController,
            validator: validatePassword,
            hintText: 'password'.tr,
            obscureText: true,
            keyboardType: TextInputType.name),
        defTextFormField(
            onSaved: (String? val) {
              controller.confirmPassword = val;
            },
            obscureText: true,
            controller: controller.confirmPasswordController,
            validator: (val) => validateConfirmPassword(
                controller.signUppasswordController.text, val),
            hintText: 'confirmPassword'.tr,
            keyboardType: TextInputType.name),
        Padding(
          padding: const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(COLOR_PRIMARY)),
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                  ),
                  child: Text(
                    '${generateCountryFlag()} +972',
                    style: const TextStyle(fontSize: 18, letterSpacing: 2.0),
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
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'^0')),
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 16, right: 16),
                    hintText: 'phoneNumber'.tr,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: Color(COLOR_PRIMARY),
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(Get.context!).colorScheme.error,
                      ),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(Get.context!).colorScheme.error,
                      ),
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
        Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
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
                'Sign Up'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode() ? Colors.black : Colors.white,
                ),
              ),
              onPressed: () {
                if (controller.signUpFormKey.currentState?.validate() ??
                    false) {
                  controller.result.clear();
                  Random random = Random();

                  for (int i = 0; i < 6; i++) {
                    int randomNumber = random.nextInt(
                        10); // Generates a random number between 0 and 9 (inclusive).
                    controller.result.add(randomNumber);
                  }
                  print(controller.result);
                  print(controller.phoneNumberController.text);
                  print("kajshdasd");
                  controller.sendSMS(controller.phoneNumberController.text,
                      controller.result.join());
                  Get.to(() => const MyVerify(
                        isLogin: false,
                      ));
                } else {
                  controller.validate = AutovalidateMode.onUserInteraction;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  String generateCountryFlag() {
    String countryCode = 'ps';

    String flag = countryCode.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));

    return flag;
  }
}
