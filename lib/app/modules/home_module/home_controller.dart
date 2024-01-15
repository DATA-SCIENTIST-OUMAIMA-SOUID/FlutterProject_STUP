import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:place_picker/place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_talab_user/app/data/services/helper.dart';

import '../../../main.dart';
import '../../data/model/AddressModel.dart';
import '../../data/model/BannerModel.dart';
import '../../data/model/DeliveryChargeModel.dart';
import '../../data/model/ProductModel.dart';
import '../../data/model/User.dart';
import '../../data/model/VendorCategoryModel.dart';
import '../../data/model/VendorModel.dart';
import '../../data/model/offer_model.dart';
import '../../data/provider/localDatabase.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../utils/constants.dart';
import '../changeaddress_module/changeaddress_controller.dart';

enum DrawerSelection {
  Home,
  Wallet,
  dineIn,
  Search,
  Cuisines,
  Cart,
  Profile,
  Orders,
  MyBooking,
  termsCondition,
  privacyPolicy,
  chooseLanguage,
  referral,
  inbox,
  driver,
  Logout,
  LikedRestaurant,
  LikedProduct
}

class HomeController extends GetxController {
  final fireStoreUtils = FireStoreUtils();

  late final DrawerSelection drawerSelection;

  late CartDatabase cartDatabase;
  late User user;
  late String appBarTitle;
  late Widget currentWidget;

  late Future<List<ProductModel>> productsFuture;

  RxList vendors = [].obs;
  RxList CategoriesList = [].obs;
  RxBool isLoading = true.obs;
  RxBool isLocationLoading = true.obs;
  String? name = "";
  /*RxBool isLocationAvail = (MyApp.selectedPosotion.latitude == 0 &&
      MyApp.selectedPosotion.longitude == 0)
      .obs;*/
  RxBool isLocationAvail = (MyApp.selectedPosotion.latitude == 0 &&
          MyApp.selectedPosotion.longitude == 0)
      .obs;

  RxList<ProductModel> products = <ProductModel>[].obs;
  String currentLocation = "";

  String? selctedOrderTypeValue = "Delivery".tr;

  final addressformKey = GlobalKey<FormState>();

  // String? line1, line2, zipCode, city;

  List<AddressModel> addressList = [];
  AddressModel selectedAddress = AddressModel();

  String? country;
  var street = TextEditingController();
  var street1 = TextEditingController();
  var landmark = TextEditingController();
  var landmark1 = TextEditingController();
  var zipcode = TextEditingController();
  var zipcode1 = TextEditingController();
  var city = TextEditingController();
  var city1 = TextEditingController();
  var cutries = TextEditingController();
  var cutries1 = TextEditingController();
  var lat;
  var long;

  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  bool isLocationPermissionAllowed = false;

  RxList offerVendorList = [].obs;

  RxList offersList = [].obs;
  late dynamic address1 = ''.obs;
  late dynamic address2 = ''.obs;

  var deliveryCharges = "".obs;

  final PageController pageController = PageController(initialPage: 0);
  RxInt currentPageIndex =
      0.obs; // Variable to store the index of the currently selected page

  final int totalPages =
      5; // Adjust this value according to the total number of pages
  final Duration scrollDuration =
      const Duration(seconds: 5); // Adjust this for scrolling interval

  ScrollController scrollController = ScrollController();

  Timer? _timer;

  List<VendorCategoryModel> categoryWiseProductList = [];

  RxList bannerTopHome = [].obs;

  List<BannerModel> bannerMiddleHome = [];

  RxBool isHomeBannerLoading = true.obs;

  bool isHomeBannerMiddleLoading = true;

  bool? storyEnable = false;

  late Rx<LocationResult?> result = Rx<LocationResult?>(null);

  adressvalidateForm() async {
    if (addressformKey.currentState?.validate() ?? false) {
      addressformKey.currentState!.save();
      update();

      {
        String passAddress =
            "${street.text}, ${landmark.text}, ${city.text}, ${zipcode.text}, ${cutries.text}";
        Navigator.pop(Get.context!, passAddress);
        update();
      }
    } else {
      autoValidateMode = AutovalidateMode.onUserInteraction;
      update();
    }
  }

  getAddressFromFirebase() async {
    var addressFromSharedPreferences = await getAddressFromSharedPreferences();

    if (addressFromSharedPreferences != null) {
      MyApp.selectedPosotion = Position.fromMap({
        'latitude': addressFromSharedPreferences.location.latitude,
        'longitude': addressFromSharedPreferences.location.longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch
      });
      isLocationAvail.value = false;
      isLocationLoading.value = false;
      selectedAddress = addressFromSharedPreferences;
    } else {
      isLocationLoading.value = false;
    }
  }

  getAddressFromFirebase2() async {
    var addressFromSharedPreferences2 =
        await getAddressFromSharedPreferences2();
//3106665
    if (addressFromSharedPreferences2 != null) {
      MyApp.selectedPosotion = Position.fromMap({
        'latitude': addressFromSharedPreferences2.location.latitude,
        'longitude': addressFromSharedPreferences2.location.longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch
      });
      isLocationAvail.value = false;
      isLocationLoading.value = false;
      selectedAddress = addressFromSharedPreferences2;

      updatecurrentLocation(selectedAddress.name);
    } else {
      isLocationLoading.value = false;
    }
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

  Future<AddressModel?> getAddressFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the JSON string from SharedPreferences using the key
    String? jsonAddress = prefs.getString('addressModelKey');

    if (jsonAddress != null) {
      // If the JSON string is not null, parse it back to a Map using jsonDecode
      Map<String, dynamic> addressMap = jsonDecode(jsonAddress);

      // Create an instance of AddressModel from the Map
      AddressModel addressModel = AddressModel.fromJson(addressMap);

      return addressModel;
    } else {
      // If the JSON string is null, return null (no saved data)
      return null;
    }
  }

  getAllCategories() async {
    var collectionReference = FireStoreUtils.firestore
        .collection(VENDORS_CATEGORIES)
        .where('publish', isEqualTo: true)
        .where('show_in_homepage', isEqualTo: true);
    collectionReference.get().then((QuerySnapshot snapshot) {
      for (var document in snapshot.docs) {
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
        CategoriesList.add(VendorCategoryModel.fromJson(data!));
      }
    });
  }

  getAllOffers() async {
    isLoading.value = true;
    var collectionReference = FireStoreUtils.firestore
        .collection(COUPON)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now());

    collectionReference.get().then((QuerySnapshot snapshot) async {
      for (var document in snapshot.docs) {
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

        if (data!['isEnabled'] == true) {
          offersList.add(OfferModel.fromJson(data));
        }
      }

      isLoading.value = false;
    });
  }

  getAllVendors() async {
    isLoading.value = true;
    var collectionReference = FireStoreUtils.firestore.collection(VENDORS);

    await collectionReference.get().then((QuerySnapshot snapshot) {
      for (var document in snapshot.docs) {
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

        vendors.add(VendorModel.fromJson(data!));
      }
    });

    isLoading.value = false;
  }

  getBanner() async {
    await fireStoreUtils.getHomeTopBanner().then((value) {
      bannerTopHome.value = value;
      isHomeBannerLoading.value = false;
    });
  }

  String getdeliveryCharges(vendorModel) {
    if (selectedAddress.city.toLowerCase() == "tubas state".tr) {
      deliveryCharges.value = "5";
    } else if (selectedAddress.city.toLowerCase() == "tammun state".tr ||
        selectedAddress.city.toLowerCase() == "aqqaba state".tr ||
        selectedAddress.city.toLowerCase() == "wadi al-far'a state".tr ||
        selectedAddress.city.toLowerCase() == "Tayasir State".tr) {
      deliveryCharges.value = "15";
    } else {
      getDeliveyData(vendorModel);
      print("deliveryCharges.value");
      print(deliveryCharges.value);
    }

    return deliveryCharges.value;
  }

  Future<void> getDeliveyData(vendorModel) async {
    num km = num.parse(getKm(
      vendorModel.latitude,
      vendorModel.longitude,
    ));
    fireStoreUtils.getDeliveryCharges().then((value) {
      if (value != null) {
        DeliveryChargeModel deliveryChargeModel = value;
        print("deliveryChargesvalue");
        print(deliveryCharges.value);
        if (!deliveryChargeModel.vendorCanModify) {
          if (km > deliveryChargeModel.minimumDeliveryChargesWithinKm) {
            deliveryCharges.value =
                (km * deliveryChargeModel.deliveryChargesPerKm)
                    .toDouble()
                    .toStringAsFixed(decimal);
          } else {
            deliveryCharges.value = deliveryChargeModel.minimumDeliveryCharges
                .toDouble()
                .toStringAsFixed(decimal);
          }
        } else {
          if (vendorModel != null && vendorModel!.deliveryCharge != null) {
            if (km >
                vendorModel!.deliveryCharge!.minimumDeliveryChargesWithinKm) {
              deliveryCharges.value =
                  (km * vendorModel!.deliveryCharge!.deliveryChargesPerKm)
                      .toDouble()
                      .toStringAsFixed(decimal);
            } else {
              deliveryCharges.value = vendorModel!
                  .deliveryCharge!.minimumDeliveryCharges
                  .toDouble()
                  .toStringAsFixed(decimal);
            }
          } else {
            if (km > deliveryChargeModel.minimumDeliveryChargesWithinKm) {
              deliveryCharges.value =
                  (km * deliveryChargeModel.deliveryChargesPerKm)
                      .toDouble()
                      .toStringAsFixed(decimal);
            } else {
              deliveryCharges.value = deliveryChargeModel.minimumDeliveryCharges
                  .toDouble()
                  .toStringAsFixed(decimal);
            }
          }
        }
      }
    });
  }

  String getKm(double latitude, double longitude) {
    double distanceInMeters = Geolocator.distanceBetween(latitude, longitude,
        MyApp.selectedPosotion.latitude, MyApp.selectedPosotion.longitude);
    double kilometer = distanceInMeters / 1000;

    return kilometer.toStringAsFixed(decimal).toString();
  }

  getOfferVendorData() async {
    await FireStoreUtils().getAllCoupons().then((value) {
      for (var element1 in value) {
        for (var element in vendors) {
          if (element1.restaurantId == element.id &&
              element1.expireOfferDate!.toDate().isAfter(DateTime.now())) {
            offersList.add(element1);
            offerVendorList.add(element);
          }
        }
      }

      isLoading.value = false;
    });
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();

    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    WidgetsFlutterBinding.ensureInitialized();
    var phone = await getPhoneNumber();
    if (phone != null) {
      fireStoreUtils.getUserIdByPhone(phone);
    }
    var user = fireStoreUtils.currentUser;
    if (user != null) {
      this.user = user;
    }
    changeaddressController addressController =
        Get.put(changeaddressController());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int retrievedIntValue = prefs.getInt('myIntKey') ?? 3;
    if (retrievedIntValue == 0) {
      addressController.changeSelectedValue(0);
    }
    if (retrievedIntValue == 1) {
      addressController.changeSelectedValue(1);
    }

    getAllVendors();
    getAllCategories();
    getAddressFromFirebase();
    getOfferVendorData();
    getBanner();
  }

  void showPlacePicker() async {
    result.value = await Navigator.of(Get.context!).push<LocationResult>(
      MaterialPageRoute(
        builder: (context) => PlacePicker(GOOGLE_API_KEY),
      ),
    );

    city1.text = result.value!.locality!;
    street1.text = result.value!.formattedAddress!;
    landmark1.text = result.value!.locality!;
    zipcode1.text = result.value!.postalCode!;
    cutries1.text = result.value!.country!.name!;
  }

  void startAutoScroll(PageController pageController) {
    const scrollDuration = Duration(
        seconds: 3); // Adjust the scroll duration as per your preference

    // Cancel the previous timer if any to avoid multiple timers running simultaneously
    _timer?.cancel();

    // Create a new timer that changes the page index every 'scrollDuration'
    _timer = Timer.periodic(scrollDuration, (timer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pageController.page == bannerTopHome.length - 1) {
          // If the current page index is the last page, go back to the first page
          pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          // Otherwise, go to the next page
          pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  bool statusCheck(vendorModel) {
    var open = false;
    final now = DateTime.now();
    var day = DateFormat('EEEE', 'en_US').format(now);
    var date = DateFormat('dd-MM-yyyy').format(now);
    vendorModel.workingHours.forEach((element) {
      if (day == element.day.toString()) {
        if (element.timeslot!.isNotEmpty) {
          element.timeslot!.forEach((element) {
            var start =
                DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.from}");
            var end =
                DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.to}");
            if (isCurrentDateInRange(start, end)) {
              open = true;
            }
          });
        }
      }
    });

    return open;
  }

  updatecurrentLocation(Location) {
    currentLocation = MyApp.currentUser!.shippingAddress.name;
    print("currentLocation");

    print(currentLocation);

    update();
  }
}
