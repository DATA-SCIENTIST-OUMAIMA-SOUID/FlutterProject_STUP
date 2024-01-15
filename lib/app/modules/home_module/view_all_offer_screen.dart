import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_talab_user/app/modules/home_module/home_controller.dart';

import '../../data/services/helper.dart';
import '../shared/componants/offerItem.dart';

class ViewAllOffersScreen extends GetView<HomeController> {
  const ViewAllOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Get.theme.colorScheme.background,
        //isDarkMode(context) ? Color(COLOR_DARK) : null,
        body: Column(
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  child: Image(
                    image: const AssetImage("assets/images/offers_bg.png"),
                    fit: BoxFit.cover,
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                Positioned(
                    left: 20,
                    child: Text(
                      "OFFERS\nFOR YOU".tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    )),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin:
                            const EdgeInsets.only(left: 5, top: 10, right: 5),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.black38),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image(
                            image: AssetImage("assets/images/ic_back.png"),
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Obx(
                () => controller.offerVendorList.isEmpty
                    ? showEmptyState('No Offers Found'.tr, context)
                    : ListView.builder(
                        itemCount: controller.offerVendorList.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return offerItemView(
                            controller.offerVendorList[index],
                            controller.offersList[index],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
