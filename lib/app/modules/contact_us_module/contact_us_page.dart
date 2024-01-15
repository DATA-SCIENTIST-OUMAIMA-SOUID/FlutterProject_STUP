import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../shared/AppGlobal.dart';

/// GetX Template Generator - fb.com/htngu.99
///
class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  String address = "", phone = "", email = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode() ? Colors.black : Colors.white,
        appBar: AppGlobal.buildSimpleAppBar(context, "contactUs".tr),
        body: Column(children: <Widget>[
          Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Email '.tr,
                      style: TextStyle(
                          color: isDarkMode() ? Colors.white : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'supertalab@gmail.com',
                      style: TextStyle(
                          color: isDarkMode() ? Colors.white : Colors.black,
                          fontSize: 20),
                    ),
                  ])),
          Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Phone'.tr,
                      style: TextStyle(
                          color: isDarkMode() ? Colors.white : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '0569006915',
                      style: TextStyle(
                          color: isDarkMode() ? Colors.white : Colors.black,
                          fontSize: 20),
                    ),
                  ])),
          Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'WhatsApp'.tr,
                      style: TextStyle(
                          color: isDarkMode() ? Colors.white : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '+972 568 471 700',
                      style: TextStyle(
                          color: isDarkMode() ? Colors.white : Colors.black,
                          fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '+90 505 526 10 41',
                      style: TextStyle(
                          color: isDarkMode() ? Colors.white : Colors.black,
                          fontSize: 20),
                    ),
                  ]))
        ]),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    FireStoreUtils().getContactUs().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          print("yes");
          address = value['Address'];
          phone = value['Phone'];
          email = value['Email'];
        });
      }
    });
  }
}
