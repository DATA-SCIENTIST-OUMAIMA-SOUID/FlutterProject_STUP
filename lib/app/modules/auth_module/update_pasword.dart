import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_talab_user/app/modules/auth_module/auth_controller.dart';

import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../shared/componants/def_form_field.dart';

class UpdtePasswordScreen extends GetView<authController> {
  const UpdtePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: Get.theme.iconTheme,
        elevation: 0.0,
      ),
      body: Form(
        autovalidateMode: controller.resetvalidate.value,
        key: controller.updateFormKey,

        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: const EdgeInsets.only(
                          top: 32.0, right: 16.0, left: 16.0),
                      child: Text(
                        'Update Password'.tr,
                        style: TextStyle(
                            color: Color(COLOR_PRIMARY),
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold),
                      )),
                ),
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
                  padding:
                  const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
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
                      onPressed: () {
                        controller.resetvalidate.value =
                            AutovalidateMode.onUserInteraction;
                        if (controller.updateFormKey.currentState!.validate()) {
                          controller.updateFormKey.currentState!.save();
                          controller.updatePassword(controller.signUppasswordController.text,controller.mobile);
                        }
                      },
                      child: Text(
                        'update'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode() ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
