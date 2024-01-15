import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/model/AttributesModel.dart';
import '../../data/model/ItemAttributes.dart';
import '../../data/model/ProductModel.dart';
import '../../data/model/ReviewAttributeModel.dart';
import '../../data/model/VendorModel.dart';
import '../../data/provider/localDatabase.dart';
import '../../data/services/FirebaseHelper.dart';
import '../ProductDetailsScreen.dart';

/// GetX Template Generator - fb.com/htngu.99
///

class productDetailsController extends GetxController {
  final ProductModel productModel;
  final VendorModel vendorModel;

  late CartDatabase cartDatabase;

  List<AddAddonsDemo> lstAddAddonsCustom = [];
  List<AddAddonsDemo> lstTemp = [];
  double priceTemp = 0.0, lastPrice = 0.0;
  int productQnt = 1;
  List<String> productImage = [];
  List<Variants>? variants = [];
  List<String> selectedVariants = [];
  List<String> selectedIndexVariants = [];
  List<String> selectedIndexArray = [];
  List<ReviewAttributeModel> reviewAttributeList = [];
  List<ProductModel> productList = [];
  List<ProductModel> storeProductList = [];
  bool showLoader = true;
  List<AttributesModel> attributesList = [];
  bool isOpen = false;

  final PageController pageController =
      PageController(viewportFraction: 1, keepPage: true);

  productDetailsController(
      {required this.productModel, required this.vendorModel});

  void getAddOnsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String musicsString = prefs.getString('musics_key') != null
        ? prefs.getString('musics_key')!
        : "";

    if (musicsString.isNotEmpty) {
      lstTemp = AddAddonsDemo.decode(musicsString);
      update();
    }

    if (productQnt > 0) {
      lastPrice = productModel.disPrice == "" || productModel.disPrice == "0"
          ? double.parse(productModel.price)
          : double.parse(productModel.disPrice!) * productQnt;
    }

    if (lstTemp.isEmpty) {
      if (productModel.addOnsTitle.isNotEmpty) {
        for (int a = 0; a < productModel.addOnsTitle.length; a++) {
          AddAddonsDemo addAddonsDemo = AddAddonsDemo(
              name: productModel.addOnsTitle[a],
              index: a,
              isCheck: false,
              categoryID: productModel.id,
              price: productModel.addOnsPrice[a]);
          lstAddAddonsCustom.add(addAddonsDemo);
          //saveAddonData(lstAddAddonsCustom);
        }
      }
      update();
    } else {
      var tempArray = [];

      for (int d = 0; d < lstTemp.length; d++) {
        if (lstTemp[d].categoryID == productModel.id) {
          AddAddonsDemo addAddonsDemo = AddAddonsDemo(
              name: lstTemp[d].name,
              index: lstTemp[d].index,
              isCheck: true,
              categoryID: lstTemp[d].categoryID,
              price: lstTemp[d].price);
          tempArray.add(addAddonsDemo);
        }
      }
      for (int a = 0; a < productModel.addOnsTitle.length; a++) {
        var isAddonSelected = false;

        for (int temp = 0; temp < tempArray.length; temp++) {
          if (tempArray[temp].name == productModel.addOnsTitle[a]) {
            isAddonSelected = true;
          }
        }
        if (isAddonSelected) {
          AddAddonsDemo addAddonsDemo = AddAddonsDemo(
              name: productModel.addOnsTitle[a],
              index: a,
              isCheck: true,
              categoryID: productModel.id,
              price: productModel.addOnsPrice[a]);
          lstAddAddonsCustom.add(addAddonsDemo);
        } else {
          AddAddonsDemo addAddonsDemo = AddAddonsDemo(
              name: productModel.addOnsTitle[a],
              index: a,
              isCheck: false,
              categoryID: productModel.id,
              price: productModel.addOnsPrice[a]);
          lstAddAddonsCustom.add(addAddonsDemo);
        }
      }
    }
    // updatePrice();
  }

  getData() async {
    if (productModel.photos.isEmpty) {
      productImage.add(productModel.photo);
    }
    for (var element in productModel.photos) {
      productImage.add(element);
    }

    for (var element in variants!) {
      productImage.add(element.variantImage.toString());
    }

    await FireStoreUtils.getAttributes().then((value) {
      attributesList = value;
      update();
    });

    SharedPreferences sp = await SharedPreferences.getInstance();

    await FireStoreUtils.getStoreProduct(productModel.vendorID.toString())
        .then((value) {
      for (var element in value) {
        if (element.id != productModel.id) {
          storeProductList.add(element);
        }
      }
      update();
    });

    await FireStoreUtils.getProductListByCategoryId(
            productModel.categoryID.toString())
        .then((value) {
      for (var element in value) {
        if (element.id != productModel.id) {
          productList.add(element);
        }
      }

      update();
    });

    update();
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  @override
  @override
  void onClose() {
    // TODO: implement onClose

    super.onClose();
  }

  @override
  void onInit() {
    // TODO: implement onInit

    super.onInit();
    lstAddAddonsCustom.clear();
    lstTemp.clear();
    priceTemp = 0.0;
    lastPrice = 0.0;
    productQnt = 1;
    productImage.clear();
    variants?.clear();
    selectedVariants.clear();
    selectedIndexVariants.clear();
    selectedIndexArray.clear();
    reviewAttributeList.clear();
    productList.clear();
    storeProductList.clear();
    showLoader = true;
    attributesList.clear();

    getAddOnsData();
    statusCheck();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    pageController.dispose();
    productImage.clear();
    variants?.clear();
    selectedVariants.clear();
    selectedIndexVariants.clear();
    selectedIndexArray.clear();
    reviewAttributeList.clear();
    productList.clear();
    storeProductList.clear();
    showLoader = true;
    attributesList.clear();

    super.onReady();
    pageController.dispose();
    productImage.clear();
    variants?.clear();
    selectedVariants.clear();
    selectedIndexVariants.clear();
    selectedIndexArray.clear();
    reviewAttributeList.clear();
    productList.clear();
    storeProductList.clear();
    showLoader = true;
    attributesList.clear();
  }

  statusCheck() {
    final now = DateTime.now();
    var day = DateFormat('EEEE', 'en_US').format(now);
    var date = DateFormat('dd-MM-yyyy').format(now);
    for (var element in vendorModel.workingHours) {
      if (day == element.day.toString()) {
        if (element.timeslot!.isNotEmpty) {
          for (var element in element.timeslot!) {
            var start =
                DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.from}");
            var end =
                DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.to}");
            if (isCurrentDateInRange(start, end)) {
              isOpen = true;
              update();
            }
          }
        }
      }
    }
  }
}
