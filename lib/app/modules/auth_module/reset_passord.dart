import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_talab_user/app/modules/auth_module/auth_controller.dart';

import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../shared/componants/def_form_field.dart';

class ResetPasswordScreen extends GetView<authController> {
  const ResetPasswordScreen({super.key});

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
        key: controller.resetFormKey,
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
                        'Reset Password'.tr,
                        style: TextStyle(
                            color: Color(COLOR_PRIMARY),
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold),
                      )),
                ),

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
                            style: const TextStyle(
                                fontSize: 18, letterSpacing: 2.0),
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
                                  color:
                                      Theme.of(Get.context!).colorScheme.error),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(Get.context!).colorScheme.error),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
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
                  padding:
                      const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: double.infinity),
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
                      onPressed: () => controller.resetPassword(),
                      child: Text(
                        'Send OTP'.tr,
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

  String generateCountryFlag() {
    String countryCode = 'ps';

    String flag = countryCode.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));

    return flag;
  }
}
