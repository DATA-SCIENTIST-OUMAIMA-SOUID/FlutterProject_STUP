import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_talab_user/app/utils/constants.dart';

import 'data/model/User.dart';

class UserPreference {
  static late SharedPreferences _preferences;

  static const razorPayDataKey = "razorPayData";

  static const _userId = "userId";
  static String walletKey = "walletKey";

  static String UserName = "UserName";

  static String Email = "Email";

  static String _setdeliveryCharges = "deliveryCharges";


  static const _orderId = "orderId";

  static const _paymentId = "paymentId";
  static getEmail() {
    Email = _preferences.getString(Email)!;
    return Email ?? "";
  }

  static getOrderId() {
    final String? orderId = _preferences.getString(_orderId);
    return orderId ?? "";
  }

  static getdeliveryCharges() {
    final String? deliveryCharges = _preferences.getString(_setdeliveryCharges);
    return deliveryCharges ?? "";
  }



  static getPaymentId() {
    final String? paymentId = _preferences.getString(_paymentId);
    return paymentId ?? "";
  }

  static getWalletData() {
    final bool? isEnable = _preferences.getBool(walletKey);
    return isEnable;
  }

  static geUserName() {
    UserName = _preferences.getString(UserName)!;
    return UserName ?? "";
  }

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<void> saveUserModelToSharedPreferences(User userModel) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userModelJson = json.encode({
      'wallet_amount': userModel.walletAmount,
      'email': userModel.email,
      'firstName': userModel.firstName,
      'lastName': userModel.lastName,
      'settings': userModel.settings.toJson(),
      'phoneNumber': userModel.phoneNumber,
      'id': userModel.userID,
      'active': userModel.active,
      'lastOnlineTimestamp':
          userModel.lastOnlineTimestamp.toDate().toIso8601String(),
      'profilePictureURL': userModel.profilePictureURL,
      'appIdentifier': userModel.appIdentifier,
      'fcmToken': userModel.fcmToken,
      'location': userModel.location.toJson(),
      'shippingAddress': userModel.shippingAddress.toJson(),
      'shippingAddress2': userModel.shippingAddress2.toJson(),
      'stripeCustomer': userModel.stripeCustomer,
      'role': userModel.role,
      // Add other properties of the userModel
    });
    await prefs.setString('userModel', userModelJson);
  }

  static setEmail({required String email}) {
    _preferences.setString(email, email);
  }

  static setdeliveryCharges({required String deliveryCharges}) {
    _preferences.setString("deliveryCharges", deliveryCharges);
  }

  static Future<bool> setIsLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(ISLOGGEDN, true);
  }

  static setMobile({required String mobile}) {
    _preferences.setString(mobile, mobile);
  }

  static setOrderId({required String orderId}) {
    _preferences.setString(_orderId, orderId);
  }

  static setPaymentId({required String paymentId}) {
    _preferences.setString(_paymentId, paymentId);
  }

  static setUserId({required String userID}) {
    _preferences.setString(_userId, userID);
  }

  static setUserName({required String UserName}) {
    _preferences.setString(UserName, UserName);
  }

  static setWalletData(bool isEnable) async {
    await _preferences.setBool(walletKey, isEnable);
  }
}
