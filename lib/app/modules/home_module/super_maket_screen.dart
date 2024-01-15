import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_talab_user/app/utils/constants.dart';

class SuperMarketPage extends StatelessWidget {
  const SuperMarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Super Market'.tr, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(COLOR_PRIMARY),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Super Market'.tr, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.red)),
            SizedBox(height: 20),
            Text(' will be available soon '.tr, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
