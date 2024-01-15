import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../main.dart';
import '../data/services/FirebaseHelper.dart';
import '../data/services/helper.dart';
import '../utils/constants.dart';

enum AuthProviders {
  PASSWORD,
  PHONE,
}

class ReAuthUserScreen extends StatefulWidget {
  final AuthProviders provider;
  final String? email;
  final String? phoneNumber;
  final bool deleteUser;

  const ReAuthUserScreen(
      {Key? key,
      required this.provider,
      this.email,
      this.phoneNumber,
      required this.deleteUser})
      : super(key: key);

  @override
  _ReAuthUserScreenState createState() => _ReAuthUserScreenState();
}

class _ReAuthUserScreenState extends State<ReAuthUserScreen> {
  final TextEditingController _passwordController = TextEditingController();
  late Widget body = CircularProgressIndicator.adaptive(
    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
  );
  String? _verificationID;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 16,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Text(
                  "Re-Authenticate".tr,
                  textAlign: TextAlign.center,
                ),
              ),
              body,
            ],
          ),
        ),
      ),
    );
  }

  void buildBody() async {
    switch (widget.provider) {
      case AuthProviders.PASSWORD:
        body = buildPasswordField();
        break;
      case AuthProviders.PHONE:
        await _submitPhoneNumber();
        body = buildPhoneField();
        break;
    }
    setState(() {});
  }

  Widget buildPasswordField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(hintText: 'Password'.tr),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(COLOR_PRIMARY),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
            ),
            onPressed: () async => passwordButtonPressed(),
            child: Text(
              'Verify'.tr,
              style:
                  TextStyle(color: isDarkMode() ? Colors.black : Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPhoneField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: PinCodeTextField(
            length: 6,
            appContext: context,
            keyboardType: TextInputType.phone,
            backgroundColor: Colors.transparent,
            pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 40,
                fieldWidth: 40,
                activeColor: Color(COLOR_PRIMARY),
                activeFillColor:
                    isDarkMode() ? Colors.grey.shade700 : Colors.grey.shade100,
                selectedFillColor: Colors.transparent,
                selectedColor: Color(COLOR_PRIMARY),
                inactiveColor: Colors.grey.shade600,
                inactiveFillColor: Colors.transparent),
            enableActiveFill: true,
            onCompleted: (v) {
              _submitCode(v);
            },
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      buildBody();
    });
  }

  passwordButtonPressed() async {
    if (_passwordController.text.isEmpty) {
      showAlertDialog(
        context,
        'Empty Password'.tr,
        'Password is required to update email'.tr,
        true,
      );
    } else {
      await Get.dialog(const CircularProgressIndicator());
      try {
        auth.UserCredential? result = await FireStoreUtils.reAuthUser(
            widget.provider,
            email: MyApp.currentUser!.email,
            password: _passwordController.text);
        if (result == null) {
          await hideProgress();
          showAlertDialog(
            context,
            "notVerify".tr,
            "double-check-password".tr,
            true,
          );
        } else {
          if (result.user != null) {
            if (widget.email != null)
              await result.user!.updateEmail(widget.email!);
            await hideProgress();
            Navigator.pop(context, true);
          } else {
            await hideProgress();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "notVerifyTryAgain".tr,
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            );
          }
        }
      } catch (e, s) {
        await hideProgress();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "notVerifyTryAgain".tr,
              style: const TextStyle(fontSize: 17),
            ),
          ),
        );
      }
    }
  }

  void _submitCode(String code) async {
    Get.dialog(const CircularProgressIndicator());
    try {
      if (_verificationID != null) {
        if (widget.deleteUser) {
          await FireStoreUtils.reAuthUser(widget.provider,
              verificationId: _verificationID!, smsCode: code);
        } else {
          auth.PhoneAuthCredential credential =
              auth.PhoneAuthProvider.credential(
                  smsCode: code, verificationId: _verificationID!);
          await auth.FirebaseAuth.instance.currentUser!
              .updatePhoneNumber(credential);
        }
        await hideProgress();
        Navigator.pop(context, true);
      } else {
        await hideProgress();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("notVerificationID".tr),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } on auth.FirebaseAuthException catch (exception) {
      await hideProgress();
      Navigator.pop(context);

      String message = "anErrorOccurredTryAgain".tr;
      switch (exception.code) {
        case 'invalid-verification-code':
          message = "invalidCodeOrExpired".tr;
          break;
        case 'user-disabled':
          message = "userDisabled".tr;
          break;
        default:
          message = "anErrorOccurredTryAgain".tr;
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
        ),
      );
    } catch (e, s) {
      await hideProgress();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "anErrorOccurredTryAgain".tr,
          ),
        ),
      );
    }
  }

  _submitPhoneNumber() async {
    Get.dialog(const CircularProgressIndicator());
    await FireStoreUtils.firebaseSubmitPhoneNumber(
      widget.phoneNumber!,
      (String verificationId) {
        if (mounted) {
          hideProgress();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "codeTimeOut".tr,
              ),
            ),
          );
        }
      },
      (String? verificationId, int? forceResendingToken) async {
        if (mounted) {
          await hideProgress();
          _verificationID = verificationId;
        }
      },
      (auth.FirebaseAuthException error) async {
        if (mounted) {
          await hideProgress();

          String message = "anErrorOccurredTryAgain".tr;
          switch (error.code) {
            case 'invalid-verification-code':
              message = "invalidCodeOrExpired".tr;
              break;
            case 'user-disabled':
              message = "userDisabled".tr;
              break;
            default:
              message = "anErrorOccurredTryAgain".tr;
              break;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
              ),
            ),
          );
          Navigator.pop(context);
        }
      },
      (auth.PhoneAuthCredential credential) async {},
    );
  }
}
