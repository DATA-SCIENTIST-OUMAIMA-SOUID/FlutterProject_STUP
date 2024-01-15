import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../main.dart';
import '../../data/model/User.dart';
import '../../data/services/FirebaseHelper.dart';

/// GetX Template Generator - fb.com/htngu.99
///

class profileController extends GetxController {
  late User user;
  GlobalKey<FormState> key = GlobalKey();
  AutovalidateMode validate = AutovalidateMode.disabled;
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobile = TextEditingController();

  bool _isPhoneValid = false;
  String? _phoneNumber = "";

  void initState() {
    user = MyApp.currentUser!;

    firstName.text = MyApp.currentUser!.firstName;
    lastName.text = MyApp.currentUser!.lastName;
    email.text = MyApp.currentUser!.email;
    mobile.text = MyApp.currentUser!.phoneNumber;
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel".tr),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("continue".tr),
      onPressed: () {
        if (_isPhoneValid) {
          MyApp.currentUser!.phoneNumber = _phoneNumber.toString();
          mobile.text = _phoneNumber.toString();

          Navigator.pop(context);
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Change Phone Number".tr),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.grey.shade200)),
        child: InternationalPhoneNumberInput(
          onInputChanged: (value) {
            _phoneNumber = "${value.phoneNumber}";
          },
          onInputValidated: (bool value) => _isPhoneValid = value,
          ignoreBlank: true,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          inputDecoration: InputDecoration(
            hintText: 'Phone Number'.tr,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            isDense: true,
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
          inputBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          initialValue: PhoneNumber(isoCode: 'US'),
          selectorConfig:
              const SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG),
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  updateUser() async {
    user.firstName = firstName.text;
    user.lastName = lastName.text;
    user.email = email.text;
    user.phoneNumber = mobile.text;
    var updatedUser = await FireStoreUtils.updateCurrentUser(user);
    if (updatedUser != null) {
      MyApp.currentUser = user;
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          content: Text(
        'detailsSavedSuccessfully'.tr,
        style: const TextStyle(fontSize: 17),
      )));
    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          content: Text(
        'couldNotSaveDetailsPleaseTryAgain'.tr,
        style: const TextStyle(fontSize: 17),
      )));
    }
  }

  validateAndSave() async {}
}
