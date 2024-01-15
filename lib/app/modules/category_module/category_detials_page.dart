import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/model/VendorCategoryModel.dart';
import '../../data/model/VendorModel.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../../translations/languageController.dart';
import '../../utils/constants.dart';
import '../home_module/home_controller.dart';
import '../shared/AppGlobal.dart';
import '../vendor_module/vendor_page.dart';

Widget buildAllRestaurantsData(VendorModel vendorModel, text, isOpen) {
  HomeController homeController = Get.find<HomeController>();

  return GestureDetector(
    onTap: () {
      Navigator.push(
        Get.context!,
        MaterialPageRoute(
          builder: (context) => NewVendorProductsScreen(
            vendorModel: vendorModel,
            deliveryPrice: homeController.deliveryCharges,
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
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
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
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
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

class CategoryDetailsScreen extends StatefulWidget {
  final VendorCategoryModel category;
  const CategoryDetailsScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  _CategoryDetailsScreenState createState() => _CategoryDetailsScreenState();
}

Mycontroll mycontroll = Get.put(Mycontroll());

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  HomeController homeController = Get.find<HomeController>();
  Stream<List<VendorModel>>? categoriesFuture;
  final FireStoreUtils fireStoreUtils = FireStoreUtils();

  var vendors = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Get.theme.colorScheme.background,
          appBar: mycontroll.langCode != null
              ? AppGlobal.buildSimpleAppBar(
                  context,
                  mycontroll.langCode == 'ar'
                      ? widget.category.title.toString()
                      : widget.category.titleEn.toString())
              : AppGlobal.buildSimpleAppBar(
                  context, widget.category.title.toString()),
          body: vendors.isNotEmpty
              ? ListView.builder(
                  itemCount: vendors.length,
                  itemBuilder: (context, index) => buildAllRestaurantsData(
                      homeController.vendors[index],
                      homeController.getKm(
                        homeController.vendors[index].latitude,
                        homeController.vendors[index].longitude,
                      ),
                      homeController
                          .statusCheck(homeController.vendors[index])),
                )
              : Center(
                  child: showEmptyState('xx'.tr, context),
                )),
    );
  }

  @override
  void initState() {
    super.initState();

    for (var element in homeController.vendors) {
      if (element.categoryID == widget.category.id) {
        vendors.add(element);
      }
    }
    //

    // homeController.getVendorsByCategory(widget.category.id.toString()
  }
}
