import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_talab_user/app/modules/changeaddress_module/changeaddress_controller.dart';

import '../../data/model/AddressModel.dart';
import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../home_module/hoome__page.dart';

class changeaddressPage extends GetView<changeaddressController> {
  const changeaddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(changeaddressController());
    return Scaffold(
      backgroundColor: isDarkMode() ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'Address'.tr,
          style: TextStyle(
            color: isDarkMode() ? Colors.white : Colors.black,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Get.offNamed('/home');
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Color(COLOR_PRIMARY),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            child: FutureBuilder<void>(
              future: Future.wait([]),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  // Data has been fetched successfully, now display it
                  controller.addresses = [
                    controller.address1.value,
                    controller.address2.value,
                  ];
                  if (controller.addresses[0].addressname == "" &&
                      controller.addresses[1].addressname == "") {
                    return Center(
                      child: Text(
                        "There are no addresses\nAdd one",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: isDarkMode() ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  } else {
                    return Obx(() => Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (controller.addresses[0] != null)
                              InkWell(
                                onTap: () {
                                  controller.changeSelectedValue(0);
                                  controller.selectedAddressIndex.value = 0;
                                  controller.update();

                                  controller.homecontroller
                                      .getAddressFromFirebase();
                                  Get.to(() => home_Page());
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Container(
                                    width: Get.width * 0.9,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: controller.selectedAddressIndex
                                                    .value ==
                                                0
                                            ? Color(COLOR_PRIMARY)
                                            : Colors.grey,

                                        // Set the desired border color
                                        width:
                                            2.0, // Set the desired border width
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.4),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                      color: isDarkMode()
                                          ? Colors.black
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          controller.addresses[0].name,
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 12.0),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_city,
                                                color: Colors.grey),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              controller.addresses[0].city,
                                              style: const TextStyle(
                                                  fontSize: 16.0),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                color: Colors.grey),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              controller
                                                  .addresses[0].addressname,
                                              style: const TextStyle(
                                                  fontSize: 16.0),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            const Icon(Icons.house,
                                                color: Colors.grey),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              controller.addresses[0].line1,
                                              style: const TextStyle(
                                                  fontSize: 16.0),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (controller.addresses[1].addressname != "")
                              InkWell(
                                onTap: () {
                                  controller.changeSelectedValue(1);

                                  controller.selectedAddressIndex.value = 1;
                                  controller.homecontroller
                                      .getAddressFromFirebase2();
                                  Get.to(() => home_Page());
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Container(
                                    width: Get.width * 0.9,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: controller.selectedAddressIndex
                                                    .value ==
                                                1
                                            ? Color(COLOR_PRIMARY)
                                            : Colors.grey,

                                        // Set the desired border color
                                        width:
                                            2.0, // Set the desired border width
                                      ),
                                      color: isDarkMode()
                                          ? Colors.black
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          controller.addresses[1].name,
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 12.0),
                                        // Row(
                                        //   children: [
                                        //     Icon(Icons.person, color: Colors.grey),
                                        //     SizedBox(width: 8.0),
                                        //     Text(
                                        //       "${controller.addresses[0]!.name}",
                                        //       style: TextStyle(fontSize: 16.0),
                                        //     ),
                                        //   ],
                                        // ),
                                        // SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_city,
                                                color: Colors.grey),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              controller.addresses[1].city,
                                              style: const TextStyle(
                                                  fontSize: 16.0),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                color: Colors.grey),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              controller
                                                  .addresses[1].addressname,
                                              style: const TextStyle(
                                                  fontSize: 16.0),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            const Icon(Icons.house,
                                                color: Colors.grey),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              controller.addresses[1].line2,
                                              style: const TextStyle(
                                                  fontSize: 16.0),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            TextButton(
                                onPressed: () {
                                  if (controller.selectedAddressIndex.value ==
                                      3) {
                                    Get.defaultDialog(
                                        title: "No address selected".tr,
                                        middleText:
                                            "select address to  continue".tr,
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: Text("OK".tr))
                                        ]);
                                  } else {
                                    Get.off(home_Page());
                                  }
                                },
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 15),
                                    decoration: BoxDecoration(
                                        color: Color(COLOR_PRIMARY),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Text(
                                      "CONTINUE".tr,
                                      style: TextStyle(color: Colors.white),
                                    ))),
                          ],
                        ));
                  }
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(
            () => Visibility(
              visible: controller.isOpened.value,
              child: FloatingActionButton.extended(
                backgroundColor: Color(COLOR_PRIMARY),
                onPressed: () => controller.onSubFAB2Pressed(),
                label: Text("Second Address".tr),
                heroTag: "secondAddressButton",
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Obx(
            () => Visibility(
              visible: controller.isOpened.value,
              child: FloatingActionButton.extended(
                backgroundColor: Color(COLOR_PRIMARY),
                onPressed: () => controller.onSubFAB1Pressed(),
                label: Text("First Address".tr),
                heroTag: "firstAddressButton",
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Obx(
            () => FloatingActionButton(
              backgroundColor: Color(COLOR_PRIMARY),
              onPressed: () => controller.toggleSubFABs(),
              heroTag: "mainButton",
              child: Icon(controller.isOpened.value ? Icons.close : Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
