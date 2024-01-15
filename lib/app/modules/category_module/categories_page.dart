import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_talab_user/app/modules/category_module/category_detials_page.dart';

import '../../data/model/VendorCategoryModel.dart';
import '../../data/services/helper.dart';
import '../../translations/languageController.dart';
import '../../utils/constants.dart';
import '../home_module/home_controller.dart';
import '../shared/AppGlobal.dart';

Widget buildCuisineCell(VendorCategoryModel cuisineModel) {
  return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
      child: GestureDetector(
        onTap: () => push(
          Get.context!,
          CategoryDetailsScreen(
            category: cuisineModel,
          ),
        ),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            image: DecorationImage(
              image: NetworkImage(cuisineModel.photo.toString()),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), BlendMode.darken),
            ),
          ),
          child: Center(
            child: mycontroll.langCode != null
                ? Text(
                    mycontroll.langCode == 'ar'
                        ? cuisineModel.title.toString()
                        : cuisineModel.titleEn.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppinsm",
                        fontSize: 27),
                  )
                : Text(
                    cuisineModel.title.toString().tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppinsm",
                        fontSize: 27),
                  ),
          ),
        ),
      ));
}

Mycontroll mycontroll = Get.put(Mycontroll());

class categoriesPage extends GetView<HomeController> {
  const categoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.theme.colorScheme.background,
        appBar: AppGlobal.buildSimpleAppBar(context, "Categories".tr),
        body: controller.CategoriesList.isNotEmpty
            ? ListView.builder(
                itemCount: controller.CategoriesList.length,
                itemBuilder: (context, index) =>
                    buildCuisineCell(controller.CategoriesList[index]),
              )
            : Center(
                child: showEmptyState('xx'.tr, context),
              ));
  }
}
