import 'dart:convert';

import 'package:get/get.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_talab_user/main.dart';

import '../../data/model/AddressModel.dart';
import '../../data/services/FirebaseHelper.dart';
import '../home_module/home_controller.dart';
import 'Add_NewAddress2.dart';
import 'add_New_Address.dart';

/// GetX Template Generator - fb.com/htngu.99
///

class changeaddressController extends GetxController {
  FireStoreUtils fireStoreUtils = FireStoreUtils();
  HomeController homecontroller = Get.find();

  List<AddressModel> addresses = [];

  late Rx<AddressModel> address1 = AddressModel().obs;
  late Rx<AddressModel> address2 = AddressModel().obs;
  var isloading = true;
  late RxInt selectedAddressIndex = 3.obs;
  var isOpened = false.obs;

  changeSelectedValue(int index) async {
    selectedAddressIndex.value = index;

    if (index == 0) {
      if (MyApp.currentUser!.userID != '') {
        MyApp.selectedPosotion = Position.fromMap({
          'latitude': address1.value.location.latitude,
          'longitude': address1.value.location.longitude,
          'timestamp': DateTime.now().millisecondsSinceEpoch
        });
        homecontroller.updatecurrentLocation(address1.value.name);
        MyApp.currentUser!.shippingAddress = address1.value;
        homecontroller.selectedAddress = address1.value;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('myIntKey', 0);
      }
    } else {
      if (MyApp.currentUser!.userID != '') {
        MyApp.selectedPosotion = Position.fromMap({
          'latitude': address2.value.location.latitude,
          'longitude': address2.value.location.longitude,
          'timestamp': DateTime.now().millisecondsSinceEpoch
        });
        homecontroller.selectedAddress = address2.value;
        homecontroller.updatecurrentLocation(address2.value.name);
        MyApp.currentUser!.shippingAddress = address2.value;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('myIntKey', 1);
      }
    }
  }

  Future<AddressModel?> getAddressFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? jsonAddress = prefs.getString('addressModelKey');

    if (jsonAddress == null) {
      return null;
    }

    Map<String, dynamic> decodedJson = jsonDecode(jsonAddress);
    AddressModel addressModel = AddressModel.fromJson(decodedJson);

    return addressModel;
  }

  Future<AddressModel?> getAddressFromSharedPreferences2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? jsonAddress = prefs.getString('addressModelKey2');

    if (jsonAddress == null) {
      return null;
    }

    Map<String, dynamic> decodedJson = jsonDecode(jsonAddress);
    AddressModel addressModel = AddressModel.fromJson(decodedJson);

    return addressModel;
  }

  getAddressFromSharedPreferencese() async {
    getAddressFromSharedPreferences().then((value) {
      if (value != null) {
        address1.value = value;
      }
    });
    getAddressFromSharedPreferences2().then((value) => {
          if (value != null) {address2.value = value}
        });
    isloading = false;
    update();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    addresses = [
      address1.value,
      address2.value,
    ];
    super.onInit();
    getAddressFromSharedPreferencese();
  }

  void onSubFAB1Pressed() {
    Get.to(() => const Add_NewAddress());
  }

  void onSubFAB2Pressed() {
    Get.to(() => const Add_NewAddress2());
  }

  void toggleSubFABs() {
    isOpened.value = !isOpened.value;
  }

  static void saveAddressToSharedPreferences(AddressModel addressModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonAddress = jsonEncode(addressModel.toJson());
    await prefs.setString('addressModelKey', jsonAddress);
  }

  static void saveAddressToSharedPreferences2(AddressModel addressModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonAddress = jsonEncode(addressModel.toJson());
    await prefs.setString('addressModelKey2', jsonAddress);
  }
}
