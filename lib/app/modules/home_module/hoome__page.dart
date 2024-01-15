import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_talab_user/app/modules/home_module/super_maket_screen.dart';
import 'package:super_talab_user/app/modules/home_module/view_all_restaurant.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';
import '../../data/model/BannerModel.dart';
import '../../data/model/ProductModel.dart';
import '../../data/model/VendorModel.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../../theme/app_theme.dart';
import '../../translations/languageController.dart';
import '../../utils/constants.dart';
import '../ProductDetailsScreen.dart';
import '../changeaddress_module/add_New_Address.dart';
import '../changeaddress_module/changeaddress_page.dart';
import '../shared/AppGlobal.dart';
import '../shared/drawer.dart';
import '../vendor_module/vendor_page.dart';
import 'home_controller.dart';

class home_Page extends GetView<HomeController> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ThemeController _themeController = Get.find();

  home_Page({super.key});
  Mycontroll mycontroll = Get.put(Mycontroll());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Get.theme.colorScheme.background,
        drawer: const DrawerWidget(),
        body: SafeArea(
          child: Obx(
            () => controller.isLocationLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.isLocationAvail.value
                    ? Center(
                        child: showEmptyState("notHaveLocation".tr, context,
                            action: () async {
                          Get.to(() => const Add_NewAddress());
                        }, buttonTitle: 'Select Location'.tr),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                  child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.menu,
                                      color: isDarkMode()
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    onPressed: () =>
                                        scaffoldKey.currentState!.openDrawer(),
                                  ),
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: isDarkMode()
                                        ? Colors.white
                                        : Colors.black,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Text(controller.currentLocation,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: isDarkMode()
                                                ? Colors.white
                                                : Colors.black,
                                            fontFamily: "Poppinsr")),
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              changeaddressPage(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            return child;
                                          },
                                        ))
                                            .then((value) {
                                          if (value != null) {
                                            (controller.currentLocation =
                                                value);
                                          }
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Color(COLOR_PRIMARY),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        elevation: 4.0,
                                      ),
                                      child: Text("Change".tr)),
                                ],
                              )),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            controller.isHomeBannerLoading.value
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.25,
                                    child: PageView.builder(
                                      padEnds: false,
                                      itemCount:
                                          controller.bannerTopHome.length,
                                      scrollDirection: Axis.horizontal,
                                      controller: controller.pageController,
                                      onPageChanged: (int index) {
                                        controller.currentPageIndex.value =
                                            index; // Update the currentPageIndex
                                      },
                                      itemBuilder: (context, index) => Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: buildBestDealPage(
                                            controller.bannerTopHome[index]),
                                      ),
                                    )),
                            SizedBox(
                              height: 15,
                              child: PageIndicator(
                                currentPageIndex:
                                    controller.currentPageIndex.value,
                                totalPageCount: controller.bannerTopHome.length,
                                dotSize: 10.0, // Customize dot size if needed
                                selectedColor: Color(
                                    COLOR_PRIMARY), // Customize selected dot color
                                unselectedColor: Colors.red
                                    .shade100, // Customize unselected dot color
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            InkWell(
                              onTap: () {
                                Get.toNamed('/ViewAllOffersScreen');
                              },
                              child: Stack(children: [
                                Container(
                                  width: Get.width,
                                  height: Get.height * 0.25,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 1,
                                        offset: const Offset(
                                            0, 2), // changes position of shadow
                                      ),
                                    ],
                                    image: const DecorationImage(
                                      image: AssetImage(
                                          'assets/images/offers.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: Get.height * 0.1,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'See All Offers'.tr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.to(
                                        () => const ViewAllRestaurantScreen());
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: Get.width * 0.47,
                                        height: Get.height * 0.2,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              spreadRadius: 2,
                                              blurRadius: 1,
                                              offset: const Offset(0,
                                                  2), // changes position of shadow
                                            ),
                                          ],
                                          image: const DecorationImage(
                                            image: AssetImage(
                                                'assets/images/foods.png'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: Get.height * 0.05,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                            color:
                                                Colors.black.withOpacity(0.6),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'food'.tr,
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
                                InkWell(
                                  onTap: () {
                                    Get.to(() => const SuperMarketPage());
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: Get.width * 0.47,
                                        height: Get.height * 0.2,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              spreadRadius: 2,
                                              blurRadius: 1,
                                              offset: const Offset(0,
                                                  2), // changes position of shadow
                                            ),
                                          ],
                                          image: const DecorationImage(
                                            image: AssetImage(
                                                'assets/images/supermarket.png'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: Get.height * 0.05,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                            color:
                                                Colors.black.withOpacity(0.6),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'supermarket'.tr,
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
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  Widget buildBestDealPage(BannerModel categoriesModel) {
    return InkWell(
      onTap: () async {
        if (categoriesModel.redirect_type == "store") {
          VendorModel? vendorModel = await FireStoreUtils.getVendor(
              categoriesModel.redirect_id.toString());
          push(
            Get.context!,
            NewVendorProductsScreen(
              vendorModel: vendorModel!,
              deliveryPrice: null,
            ),
          );
        } else if (categoriesModel.redirect_type == "product") {
          final fireStoreUtils = FireStoreUtils();
          ProductModel? productModel = await fireStoreUtils
              .getProductByProductID(categoriesModel.redirect_id.toString());
          VendorModel? vendorModel =
              await FireStoreUtils.getVendor(productModel.vendorID);

          if (vendorModel != null) {
            push(
              Get.context!,
              ProductDetailsScreen(
                vendorModel: vendorModel,
                productModel: productModel,
              ),
            );
          }
        } else if (categoriesModel.redirect_type == "external_link") {
          /*final uri = Uri.parse(categoriesModel.redirect_id.toString());
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            throw 'Could not launch ${categoriesModel.redirect_id.toString()}';
          }*/
        }
      },
      child: SizedBox(
        width: Get.width * 0.5,
        child: Stack(
          children: [
            Container(
              child: CachedNetworkImage(
                imageUrl: getImageVAlidUrl(categoriesModel.photo.toString()),
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image:
                        DecorationImage(image: imageProvider, fit: BoxFit.fill),
                  ),
                ),
                color: Colors.black.withOpacity(0.5),
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                )),
                errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      AppGlobal.placeHolderImage!,
                      width: MediaQuery.of(context).size.width * 0.75,
                      fit: BoxFit.fitWidth,
                    )),
                fit: BoxFit.fitWidth,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: Get.width * 0.75,
                alignment: Alignment.center,
                height: Get.height * 0.07,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    color: Colors.black.withOpacity(0.2)),
                child: mycontroll.langCode != null
                    ? Text(
                        mycontroll.langCode == 'ar'
                            ? categoriesModel.title.toString()
                            : categoriesModel.titleEn.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold))
                    : Text(categoriesModel.title.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  final int currentPageIndex;
  final int totalPageCount;
  final double dotSize;
  final Color selectedColor;
  final Color unselectedColor;

  const PageIndicator({
    super.key,
    required this.currentPageIndex,
    required this.totalPageCount,
    this.dotSize = 10.0,
    this.selectedColor = Colors.black,
    this.unselectedColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: totalPageCount,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  (index == currentPageIndex) ? selectedColor : unselectedColor,
            ),
          ),
        );
      },
    );
  }
}
