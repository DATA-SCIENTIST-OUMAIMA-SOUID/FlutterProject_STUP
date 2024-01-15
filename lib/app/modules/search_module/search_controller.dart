import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/model/ProductModel.dart';
import '../../data/model/VendorModel.dart';
import '../../data/services/FirebaseHelper.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class searchController extends GetxController{

  late RxList<VendorModel> vendorList = <VendorModel>[].obs;
  late RxList<VendorModel> vendorSearchList = <VendorModel>[].obs;
  late RxList<ProductModel> productList = <ProductModel>[].obs;
  late RxList<ProductModel> productSearchList = <ProductModel>[].obs;
  final TextEditingController SearchController = TextEditingController();

  final FireStoreUtils fireStoreUtils = FireStoreUtils();



  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fireStoreUtils.getVendors().then((value) {

      vendorList.value = value;


    });
    fireStoreUtils.getAllProducts().then((value) {

      productList.value = value;

    });
  }
  @override
  void dispose() {
    vendorSearchList.clear();
    productSearchList.clear();
    super.dispose();
  }
}