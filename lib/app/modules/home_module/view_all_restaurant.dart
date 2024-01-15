import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_talab_user/app/modules/home_module/home_controller.dart';

import '../../data/model/VendorModel.dart';
import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../shared/AppGlobal.dart';
import '../shared/componants/buildTitileRow.dart';
import '../shared/componants/category_item.dart';
import '../vendor_module/vendor_page.dart';

class ViewAllRestaurantScreen extends GetView<HomeController> {
  const ViewAllRestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode() ? const Color(DARK_COLOR) : const Color(0xffFFFFFF),
      appBar: AppGlobal.buildAppBar(context, "All Restaurant".tr),
      body: Column(
        children: [
          buildTitleRow(
            titleValue: "Categories".tr,
            onClick: () {
              Get.toNamed('/categories');
            },
          ),
          Container(
            color: isDarkMode()
                ? const Color(DARK_COLOR)
                : const Color(0xffFFFFFF),
            child: Obx(
              () => controller.isLoading.value
                  ? Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor:
                            AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                      ),
                    )
                  : controller.CategoriesList.isEmpty
                      ? Center(
                          child: Text(
                            "No Categories Found".tr,
                            style: const TextStyle(fontSize: 20),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.only(left: 10),
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.CategoriesList.length >= 15
                                ? 15
                                : controller.CategoriesList.length,
                            itemBuilder: (context, index) {
                              return buildCategoryItem(
                                  controller.CategoriesList[index]);
                            },
                          ),
                        ),
            ),

            // child: FutureBuilder<List<VendorCategoryModel>>(
            //     future: controller.fireStoreUtils.getCuisines(),
            //     initialData: const [],
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return Center(
            //           child: CircularProgressIndicator.adaptive(
            //             valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
            //           ),
            //         );
            //       }
            //
            //       if ((snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) ) {
            //         return Container(
            //             padding: const EdgeInsets.only(left: 10),
            //             height: 150,
            //             child: ListView.builder(
            //               scrollDirection: Axis.horizontal,
            //               itemCount: snapshot.data!.length >= 15 ? 15 : snapshot.data!.length,
            //               itemBuilder: (context, index) {
            //                 return buildCategoryItem(snapshot.data![index]);
            //               },
            //             ));
            //       } else {
            //         return showEmptyState('No Categories'.tr, context);
            //       }
            //     }),
          ),
          Expanded(
            child: Obx(
              () => controller.isLoading.value
                  ? Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor:
                            AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                      ),
                    )
                  : controller.vendors.isEmpty
                      ? Center(
                          child: Text(
                            "xx".tr,
                            style: const TextStyle(fontSize: 20),
                          ),
                        )
                      : ListView.builder(
                          itemCount: controller.vendors.length,
                          itemBuilder: (context, index) {
                            return buildAllRestaurantsData(
                                controller.vendors[index],
                                controller.getKm(
                                  controller.vendors[index].latitude,
                                  controller.vendors[index].longitude,
                                ),
                                controller
                                    .statusCheck(controller.vendors[index]),
                                controller.getdeliveryCharges(
                                    controller.vendors[index]));
                          }),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAllRestaurantsData(
      VendorModel vendorModel, text, isOpen, deliveryCharges) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          Get.context!,
          MaterialPageRoute(
            builder: (context) => NewVendorProductsScreen(
              vendorModel: vendorModel,
              deliveryPrice: controller.deliveryCharges,
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(Get.context!).size.width * 0.75,
        height: 260,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100, width: 0.1),
            boxShadow: [
              isDarkMode()
                  ? const BoxShadow()
                  : BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 8.0,
                      spreadRadius: 1.2,
                      offset: const Offset(0.2, 0.2),
                    ),
            ],
            color: Colors.white),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: CachedNetworkImage(
                  imageUrl: getImageVAlidUrl(vendorModel.photo),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => Center(
                      child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  )),
                  errorWidget: (context, url, error) => ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        AppGlobal.placeHolderImage!,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                      )),
                  fit: BoxFit.cover,
                )),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(vendorModel.title,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontFamily: "Poppinsm",
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff000000),
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text('delivery price '.tr + deliveryCharges + symbol,
                              maxLines: 1,
                              style: const TextStyle(
                                fontFamily: "Poppinsm",
                                letterSpacing: 0.5,
                                color: Color(0xff000000),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const ImageIcon(
                            AssetImage('assets/images/location3x.png'),
                            size: 15,
                            color: Color(0xff555353),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: Text(vendorModel.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: "Poppinsm",
                                    letterSpacing: 0.5,
                                    color: Color(0xff555353),
                                  )),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                Container(
                                  height: 5,
                                  width: 5,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff555353),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Text(text + " km",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: "Poppinsm",
                                        color: Color(0xff555353),
                                      )),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                )
              ],
            ),
            isOpen
                ? Container()
                : Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: Get.height * 0.23,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                        color: Colors.black.withOpacity(0.4),
                      ),
                      child: Center(
                        child: Text(
                          'Closed'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
