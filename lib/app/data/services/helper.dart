import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_talab_user/app/data/services/FirebaseHelper.dart';
import 'package:super_talab_user/app/modules/auth_module/auth_page.dart';
import 'package:super_talab_user/main.dart';

import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

ProgressDialog? pd;

ThemeController themeController = ThemeController();

String audioMessageTime(Duration audioDuration) {
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  String twoDigitsHours(int n) {
    if (n >= 10) return '$n:';
    if (n == 0) return '';
    return '0$n:';
  }

  String twoDigitMinutes = twoDigits(audioDuration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(audioDuration.inSeconds.remainder(60));
  return '${twoDigitsHours(audioDuration.inHours)}$twoDigitMinutes:$twoDigitSeconds';
}

void deleteData(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}

Widget displayCircleImage(String picUrl, double size, hasBorder) =>
    CachedNetworkImage(
        height: size,
        width: size,
        imageBuilder: (context, imageProvider) =>
            _getCircularImageProvider(imageProvider, size, hasBorder),
        imageUrl: getImageVAlidUrl(picUrl),
        placeholder: (context, url) =>
            _getPlaceholderOrErrorImage(size, hasBorder),
        errorWidget: (context, url, error) =>
            _getPlaceholderOrErrorImage(size, hasBorder));

Widget displayImage(String picUrl) => CachedNetworkImage(
    imageBuilder: (context, imageProvider) =>
        _getFlatImageProvider(imageProvider),
    imageUrl: getImageVAlidUrl(picUrl),
    placeholder: (context, url) => _getFlatPlaceholderOrErrorImage(true),
    errorWidget: (context, url, error) =>
        _getFlatPlaceholderOrErrorImage(false));

String formatTimestamp(int timestamp) {
  var format = DateFormat('hh:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return format.format(date);
}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.

      return Future.error("LocationDenied".tr);
    }
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error("LocationServicesDisabled".tr);
    }
  }
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error("LocationPermanentlyDenied".tr);
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

// Function to retrieve the phone number from SharedPreferences
Future<String?> getPhoneNumber() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('phone_number');
}

hideProgress() {
  pd!.hide();
}

bool isDarkMode() {
  if (themeController.isDarkMode == true) {
    return true;
  } else {
    return false;
  }
}

String orderDate(Timestamp? timestamp) {
  return DateFormat(' MMM d yyyy').format(
      DateTime.fromMillisecondsSinceEpoch(timestamp!.millisecondsSinceEpoch));
}

push(BuildContext context, Widget destination) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => destination));
}

pushAndRemoveUntil(BuildContext context, Widget destination, bool predict) {
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => destination),
      (Route<dynamic> route) => predict);
}

pushReplacement(BuildContext context, Widget destination) {
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => destination));
}

Future<void> savePhoneNumber(String phoneNumber) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('phone_number', phoneNumber);
}

String setLastSeen(int seconds) {
  var format = DateFormat('hh:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  var diff = DateTime.now().millisecondsSinceEpoch - (seconds * 1000);
  if (diff < 24 * HOUR_MILLIS) {
    return format.format(date);
  } else if (diff < 48 * HOUR_MILLIS) {
    return 'yesterdayAtTime'.tr;
  } else {
    format = DateFormat('MMM d');
    return format.format(date);
  }
}

//helper method to show progress

//helper method to show alert dialog
showAlertDialog(
    BuildContext context, String title, String content, bool addOkButton) {
  // set up the AlertDialog
  Widget? okButton;
  if (addOkButton) {
    okButton = TextButton(
      child: Text('ok'.tr),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
  if (Platform.isIOS) {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [if (okButton != null) okButton],
    );
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  } else {
    AlertDialog alert = AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [if (okButton != null) okButton]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

Widget showEmptyState(String title, BuildContext context,
    {String? description, String? buttonTitle, VoidCallback? action}) {
  return Center(
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(title,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode() ? Colors.white : Colors.black)),
          const SizedBox(height: 10),
          Text(
            description == null ? "" : description.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: isDarkMode() ? Colors.white : Colors.black,
                fontSize: 16),
          ),
          const SizedBox(height: 25),
          if (action != null)
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Color(COLOR_PRIMARY),
                    ),
                    onPressed: action,
                    child: Text(
                      buttonTitle!,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    )),
              ),
            )
        ]),
  );
}

showProgress(BuildContext context, String message, bool isDismissible) async {
  pd = ProgressDialog(context,
      type: ProgressDialogType.normal, isDismissible: isDismissible);
  pd!.style(
      message: message,
      borderRadius: 10.0,
      backgroundColor: Color(COLOR_PRIMARY),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: const TextStyle(
          color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w600));
  await pd!.show();
}

showalert(String title, BuildContext context, String desc) async {
  var alertStyle = AlertStyle(
    animationType: AnimationType.fromBottom,
    isCloseButton: true,
    backgroundColor: Colors.white,
    isOverlayTapDismiss: false,
    isButtonVisible: true,
    descStyle: TextStyle(fontWeight: FontWeight.bold),
    descTextAlign: TextAlign.center,
    animationDuration: Duration(milliseconds: 400),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0.0),
      side: BorderSide(
        color: Colors.black,
      ),
    ),
    titleStyle: TextStyle(
      color: Colors.black,
    ),
    alertAlignment: Alignment.center,
  );

  Alert(
    context: context,
    style: alertStyle,
    type: AlertType.error,
    title: title,
    desc: desc,
    buttons: [
      DialogButton(
        color: Colors.red,
        child: Text(
          "yes".tr,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () async {
          print("id: ${MyApp.currentUser!.userID}");
          await showProgress(context, "deletingAccount".tr, false);
          await FireStoreUtils.deleteUser();
          deleteData("phone_number");
          deleteData("addressModelKey");
          deleteData("addressModelKey2");
          await hideProgress();
          MyApp.currentUser = null;
          pushAndRemoveUntil(context, authPage(), false);
        },
        width: 120,
      ),
      DialogButton(
        color: Colors.black,
        child: Text(
          "no".tr,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
        width: 120,
      )
    ],
  ).show();
}

updateProgress(String message) {
  pd!.update(message: message, maxProgress: 100);
  // progressDialog.update(message: message);
}

String updateTime(Timer timer) {
  Duration callDuration = Duration(seconds: timer.tick);
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  String twoDigitsHours(int n) {
    if (n >= 10) return '$n:';
    if (n == 0) return '';
    return '0$n:';
  }

  String twoDigitMinutes = twoDigits(callDuration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(callDuration.inSeconds.remainder(60));
  return '${twoDigitsHours(callDuration.inHours)}$twoDigitMinutes:$twoDigitSeconds';
}

String? validateConfirmPassword(String? password, String? confirmPassword) {
  if (password != confirmPassword) {
    return "passwordNoMatch".tr;
  } else if (confirmPassword!.isEmpty) {
    return "confirmPassReq".tr;
  } else {
    return null;
  }
}

String? validateEmail(String? value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  if (value!.isEmpty) {
    return null;
  } else if (!regex.hasMatch(value ?? '')) {
    return "validEmail".tr;
  } else {
    return null;
  }
}

String? validateEmptyField(String? text) =>
    text == null || text.isEmpty ? 'This field can\'t be empty.'.tr : null;

String? validateMobile(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your phone number!';
  }

  // Regular expression to match a phone number with only numeric digits.
  const phoneRegex = r'^[0-9]+$';

  if (!RegExp(phoneRegex).hasMatch(value)) {
    return 'Invalid phone number format!';
  }

  return null; // Return null if the phone number is valid.
}

String? validateName(String? value) {
  String pattern =
      r'(^[a-zA-Z\u0600-\u06FF ]*$)'; // Including Arabic characters
  RegExp regExp = RegExp(pattern);
  if (value!.isEmpty) {
    return "nameIsRequired".tr;
  } else if (!regExp.hasMatch(value ?? '')) {
    return "nameMustBeValid".tr;
  }
  return null;
}

String? validatePassword(String? value) {
  if ((value?.length ?? 0) < 6) {
    return "passwordLength".tr;
  } else {
    return null;
  }
}

Widget _getCircularImageProvider(
    ImageProvider provider, double size, bool hasBorder) {
  return ClipOval(
      child: Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(size / 2)),
        border: Border.all(
          color: Colors.white,
          style: hasBorder ? BorderStyle.solid : BorderStyle.none,
          width: 1.0,
        ),
        image: DecorationImage(
          image: provider,
          fit: BoxFit.cover,
        )),
  ));
}

Widget _getFlatImageProvider(ImageProvider provider) {
  return Container(
    decoration: BoxDecoration(
        image: DecorationImage(image: provider, fit: BoxFit.cover)),
  );
}

Widget _getFlatPlaceholderOrErrorImage(bool placeholder) => Container(
      child: placeholder
          ? Center(
              child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
            ))
          : Icon(
              Icons.error,
              color: Color(COLOR_PRIMARY),
            ),
    );

Widget _getPlaceholderOrErrorImage(double size, hasBorder) => ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: const Color(COLOR_ACCENT),
            borderRadius: BorderRadius.all(Radius.circular(size / 2)),
            border: Border.all(
              color: Colors.white,
              style: hasBorder ? BorderStyle.solid : BorderStyle.none,
              width: 2.0,
            ),
            image: DecorationImage(
                image: Image.asset(
              'assets/images/placeholder.jpg',
              fit: BoxFit.cover,
              height: size,
              width: size,
            ).image)),
      ),
    );

class ShowDialogToDismiss extends StatelessWidget {
  final String content;
  final String title;
  final String buttonText;
  final String? secondaryButtonText;
  final VoidCallback? action;

  const ShowDialogToDismiss(
      {super.key,
      required this.title,
      required this.buttonText,
      required this.content,
      this.secondaryButtonText,
      this.action});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) {
      return AlertDialog(
        title: Text(
          title,
        ),
        content: Text(
          content,
        ),
        actions: [
          if (action != null)
            TextButton(
              onPressed: action,
              child: Text(
                secondaryButtonText!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          TextButton(
            child: Text(
              buttonText,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    } else {
      return CupertinoAlertDialog(
        title: Text(
          title,
        ),
        content: Text(
          content,
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(
              buttonText[0].toUpperCase() +
                  buttonText.substring(1).toLowerCase(),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          if (action != null)
            CupertinoDialogAction(
              isDefaultAction: true,
              isDestructiveAction: true,
              onPressed: action,
              child: Text(
                secondaryButtonText![0].toUpperCase() +
                    secondaryButtonText!.substring(1).toLowerCase(),
              ),
            ),
        ],
      );
    }
  }
}
