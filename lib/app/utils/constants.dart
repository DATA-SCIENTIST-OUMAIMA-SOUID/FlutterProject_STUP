// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:map_location_picker/map_location_picker.dart';

import '../data/model/CurrencyModel.dart';
import '../data/model/TaxModel.dart';
import '../data/model/VendorModel.dart';

const BOOKREQUEST = 'TableBook';
const COD = 'CODSettings';
const COLOR_ACCENT = 0xFF8fd468;
const COLOR_PRIMARY_DARK = 0xFF683A;
const CONTACT_US = 'ContactUs';
const COUPON = 'coupons';
const COUPON_BG_COLOR = 0xFFFCF8F3;
const COUPON_DASH_COLOR = 0xFFCACFDA;
const Currency = 'currencies';
const DARK_BG_COLOR = 0xff121212;
const DARK_CARD_BG_COLOR = 0xff242528;
const DARK_COLOR = 0xff191A1C;
const DARK_GREY_TEXT_COLOR = 0xff9F9F9F;
const DARK_VIEWBG_COLOR = 0xff191A1C;
const DarkContainerBorderColor = 0xff515151;

const DarkContainerColor = 0xff26272C;
const Deliverycharge = 6;
const FACEBOOK_BUTTON_COLOR = 0xFF415893;

const FavouriteRestaurant = "favorite_restaurant";
//import 'package:geolocator/geolocator.dart';
//import '../data/model/CurrencyModel.dart';
//import '../data/model/TaxModel.dart';
//import '../data/model/VendorModel.dart';

const FINISHED_ON_BOARDING = 'finishedOnBoarding';
const GlobalURL = "https://foodie.siswebapp.com/";
const GREY_TEXT_COLOR = 0xff5E5C5C;
const HOUR_MILLIS = 60 * MINUTE_MILLIS;
const ISLOGGEDN = 'isLoggedIn';
const MENU_ITEM = 'menu_items';
const MINUTE_MILLIS = 60 * SECOND_MILLIS;
const Order_Rating = 'foods_review';
const ORDER_STATUS_ACCEPTED = 'Order Accepted';
const ORDER_STATUS_COMPLETED = 'Order Completed';
const ORDER_STATUS_DRIVER_PENDING = 'Driver Pending';
const ORDER_STATUS_DRIVER_REJECTED = 'Driver Rejected';
const ORDER_STATUS_IN_TRANSIT = 'In Transit';

const ORDER_STATUS_PLACED = 'Order Placed';
const ORDER_STATUS_REJECTED = 'Order Rejected';
const ORDER_STATUS_SHIPPED = 'Order Shipped';
const ORDERREQUEST = 'Order';
const ORDERS = 'restaurant_orders';
const PAYMENT_SERVER_URL = 'https://murmuring-caverns-94283.herokuapp.com/';
const PRODUCTS = 'vendor_products';
const REPORTS = 'reports';
const REVIEW_ATTRIBUTES = "review_attributes";
const SECOND_MILLIS = 1000;

const SERVER_KEY =
    'AAAAV8pZyzs:APA91bGnF6JDf2sVzBoPLlXHk52nhXy_Q_YXpcFTlFrUOLh9owuKmlyNKY9vnHCdDEUDRLL8OwFEwH9bLK9Snv7OnEed6db_Cn5DBK0L1eSyvwA7X90vqioxCVKJSRJCA93zmU48SkZ9';
const Setting = 'settings';

const StripeSetting = 'stripeSettings';
const USER_ROLE_CUSTOMER = 'customer';
const USER_ROLE_DRIVER = 'driver';
const USER_ROLE_VENDOR = 'vendor';
const USERS = 'users';
const VENDOR_ATTRIBUTES = "vendor_attributes";
const VENDORS = 'vendors';
const VENDORS_CATEGORIES = 'vendor_categories';

const Wallet = "wallet";
List<VendorModel> allstoreList = [];
// CurrencyModel? currencyData;
// List<VendorModel> allstoreList = [];
String appVersion = '';

var COLOR_PRIMARY = 0xFFFF61313;

CurrencyModel? currencyData;

String currName = "";
int decimal = 2;
String GOOGLE_API_KEY = 'AIzaSyBjGBGxacrb2lmQQljFzqFjyjn-FPcHd9Q';
bool isDineInEnable = false;
bool isRight = false;
String placeholderImage =
    'https://firebasestorage.googleapis.com/v0/b/super-talab.appspot.com/o/error_image.jpg?alt=media&token=874488e4-11bb-47b9-a6e2-738d40601fe4';
double radiusValue = 0.0;

String referralAmount = "0.0";

String symbol = '₪';

// double getTaxValue(TaxModel? taxModel, double amount) {
//   double taxVal = 0;
//   if (taxModel != null && taxModel.tax != null && taxModel.tax! > 0) {
//     if (taxModel.type == "fix") {
//       taxVal = taxModel.tax!.toDouble();
//     } else {
//       taxVal = (amount * taxModel.tax!.toDouble()) / 100;
//     }
//   }
//   return double.parse(taxVal.toStringAsFixed(2));
// }

Uri createCoordinatesUrl(double latitude, double longitude, [String? label]) {
  Uri uri;
  if (kIsWeb) {
    uri = Uri.https('www.google.com', '/maps/search/',
        {'api': '1', 'query': '$latitude,$longitude'});
  } else if (Platform.isAndroid) {
    var query = '$latitude,$longitude';
    if (label != null) query += '($label)';
    uri = Uri(scheme: 'geo', host: '0,0', queryParameters: {'q': query});
  } else if (Platform.isIOS) {
    var params = {'ll': '$latitude,$longitude'};
    if (label != null) params['q'] = label;
    uri = Uri.https('maps.apple.com', '/', params);
  } else {
    uri = Uri.https('www.google.com', '/maps/search/',
        {'api': '1', 'query': '$latitude,$longitude'});
  }

  return uri;
}

double getDoubleVal(dynamic input) {
  if (input == null) {
    return 0.1;
  }

  if (input is int) {
    return double.parse(input.toString());
  }

  if (input is double) {
    return input;
  }
  return 0.1;
}

String getImageVAlidUrl(String url) {
  String imageUrl = placeholderImage;
  if (url.isNotEmpty) {
    imageUrl = url;
  }
  return imageUrl;
}

String getKm(Position pos1, Position pos2) {
  double distanceInMeters = Geolocator.distanceBetween(
      pos1.latitude, pos1.longitude, pos2.latitude, pos2.longitude);
  double kilometer = distanceInMeters / 1000;

  return kilometer.toStringAsFixed(2).toString();
}

String getReferralCode() {
  var rng = Random();
  return (rng.nextInt(900000) + 100000).toString();
}

double getTaxValue(TaxModel? taxModel, double amount) {
  double taxVal = 0;
  if (taxModel != null && taxModel.tax != null && taxModel.tax! > 0) {
    if (taxModel.type == "fix") {
      taxVal = taxModel.tax!.toDouble();
    } else {
      taxVal = (amount * taxModel.tax!.toDouble()) / 100;
    }
  } else {
    taxVal = amount;
  }
  return double.parse(taxVal.toStringAsFixed(2));
}
