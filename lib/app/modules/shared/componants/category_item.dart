import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/model/VendorCategoryModel.dart';
import '../../../data/services/helper.dart';
import '../../../translations/languageController.dart';
import '../../../utils/constants.dart';
import '../../category_module/category_detials_page.dart';
import '../AppGlobal.dart';

Mycontroll mycontroll = Get.put(Mycontroll());
buildCategoryItem(VendorCategoryModel model) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      onTap: () {
        push(
          Get.context!,
          CategoryDetailsScreen(
            category: model,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CachedNetworkImage(
            imageUrl: getImageVAlidUrl(model.photo.toString()),
            imageBuilder: (context, imageProvider) => Container(
              height: MediaQuery.of(context).size.height * 0.11,
              width: MediaQuery.of(context).size.width * 0.23,
              decoration: BoxDecoration(
                  border: Border.all(width: 6, color: Color(COLOR_PRIMARY)),
                  borderRadius: BorderRadius.circular(30)),
              child: Container(
                // height: 80,width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isDarkMode()
                          ? const Color(DarkContainerBorderColor)
                          : Colors.grey.shade100,
                      width: 1),
                  color: isDarkMode()
                      ? const Color(DarkContainerColor)
                      : Colors.white,
                  boxShadow: [
                    isDarkMode()
                        ? const BoxShadow()
                        : BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 5,
                          ),
                  ],
                ),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      )),
                ),
              ),
            ),
            memCacheHeight:
                (Get.context != null && MediaQuery.of(Get.context!) != null)
                    ? (MediaQuery.of(Get.context!).size.height * 0.11).toInt()
                    : 0,
            memCacheWidth:
                (Get.context != null && MediaQuery.of(Get.context!) != null)
                    ? (MediaQuery.of(Get.context!).size.width * 0.23).toInt()
                    : 0,
            placeholder: (context, url) => ClipOval(
              child: Container(
                // padding: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(75 / 1)),
                  border: Border.all(
                    color: Color(COLOR_PRIMARY),
                    style: BorderStyle.solid,
                    width: 2.0,
                  ),
                ),
                width: 75,
                height: 75,
                child: Icon(
                  Icons.fastfood,
                  color: Color(COLOR_PRIMARY),
                ),
              ),
            ),
            errorWidget: (context, url, error) => ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  AppGlobal.placeHolderImage!,
                  fit: BoxFit.cover,
                )),
          ),
          // displayCircleImage(model.photo, 90, false),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
                child: mycontroll.langCode != null
                    ? Text(
                        mycontroll.langCode == 'ar'
                            ? model.title.toString()
                            : model.titleEn.toString(),
                        style: TextStyle(
                          color: isDarkMode()
                              ? Colors.white
                              : const Color(0xFF000000),
                          fontFamily: "Poppinsr",
                        ))
                    : Text(model.title.toString(),
                        style: TextStyle(
                          color: isDarkMode()
                              ? Colors.white
                              : const Color(0xFF000000),
                          fontFamily: "Poppinsr",
                        ))),
          )
        ],
      ),
    ),
  );
}
