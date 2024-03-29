import 'package:cloud_firestore/cloud_firestore.dart';

import 'AddressModel.dart';
import 'TaxModel.dart';
import 'User.dart';
import 'VendorModel.dart';

class OrderModel {
  String authorID, paymentMethod;

  User author;

  User? driver;

  String? driverID;

  List products;

  Timestamp createdAt;

  String vendorID;

  VendorModel vendor;

  String status;

  AddressModel address;

  String id;
  num? discount;
  num? total;
  num? subtotal;
  num? deliverycharge;

  String? couponCode;
  String? couponId, notes;

  // var extras = [];
  //String? extra_size;
  String? tipValue;
  String? adminCommission;
  String? adminCommissionType;
  final bool? takeAway;
  TaxModel? taxModel;
  String? deliveryCharge;
  Map<String, dynamic>? specialDiscount;

  OrderModel(
      {address,
      author,
      this.driver,
      this.total,
      this.subtotal,
      this.deliverycharge,
      this.driverID,
      this.authorID = '',
      this.paymentMethod = '',
      createdAt,
      this.id = '',
      required this.products,
      this.status = '',
      this.discount = 0,
      this.couponCode = '',
      this.couponId = '',
      this.notes = '',
      vendor,
      /*this.extras = const [], this.extra_size,*/ this.tipValue,
      this.adminCommission,
      this.takeAway = false,
      this.adminCommissionType,
      this.deliveryCharge,
      this.specialDiscount,
      this.vendorID = '',
      taxModel})
      : this.address = address ?? AddressModel(),
        this.author = author ?? User(),
        this.createdAt = createdAt ?? Timestamp.now(),
        this.vendor = vendor ?? VendorModel(),
        this.taxModel = taxModel ?? null;

  factory OrderModel.fromJson(Map<String, dynamic> parsedJson) {
    num discountVal = 0;
    if (parsedJson['discount'] == null) {
      discountVal = 0;
    } else if (parsedJson['discount'] is String) {
      discountVal = double.parse(parsedJson['discount']);
    } else {
      discountVal = parsedJson['discount'];
    }
    return OrderModel(
      address: parsedJson.containsKey('address')
          ? AddressModel.fromJson(parsedJson['address'])
          : AddressModel(),
      author: parsedJson.containsKey('author')
          ? User.fromJson(parsedJson['author'])
          : User(),
      authorID: parsedJson['authorID'] ?? '',
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
      id: parsedJson['id'] ?? '',
      status: parsedJson['status'] ?? '',
      subtotal: parsedJson['subtotal'] ?? 0,
      deliverycharge: parsedJson['deliverycharge'] ?? 0,
      discount: discountVal,
      couponCode: parsedJson['couponCode'] ?? '',
      total: parsedJson['total'] ?? '',
      products:parsedJson['products'],
      couponId: parsedJson['couponId'] ?? '',
      notes: (parsedJson["notes"] != null &&
              parsedJson["notes"].toString().isNotEmpty)
          ? parsedJson["notes"]
          : "",
      vendor: parsedJson.containsKey('vendor')
          ? VendorModel.fromJson(parsedJson['vendor'])
          : VendorModel(),
      vendorID: parsedJson['vendorID'] ?? '',
      driver: parsedJson.containsKey('driver')
          ? User.fromJson(parsedJson['driver'])
          : null,
      driverID:
          parsedJson.containsKey('driverID') ? parsedJson['driverID'] : null,
      adminCommission: parsedJson["adminCommission"] != null
          ? parsedJson["adminCommission"]
          : "",
      adminCommissionType: parsedJson["adminCommissionType"] != null
          ? parsedJson["adminCommissionType"]
          : "",
      tipValue:
          parsedJson["tip_amount"] != null ? parsedJson["tip_amount"] : "",
      specialDiscount: parsedJson["specialDiscount"] ?? {},

      takeAway: parsedJson["takeAway"] != null ? parsedJson["takeAway"] : false,
      //extras: parsedJson["extras"]!=null?parsedJson["extras"]:[],
      // extra_size: parsedJson["extras_price"]!=null?parsedJson["extras_price"]:"",
      deliveryCharge: parsedJson["deliveryCharge"],
      paymentMethod: parsedJson["payment_method"] ?? '',
      taxModel: (parsedJson.containsKey('taxSetting') &&
              parsedJson['taxSetting'] != null)
          ? TaxModel.fromJson(parsedJson['taxSetting'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': this.address.toJson(),
      'author': this.author.toJson(),
      'authorID': this.authorID,
      'createdAt': this.createdAt,
      'payment_method': this.paymentMethod,
      'id': this.id,
      'products': this.products.map((e) => e.toJson()).toList(),
      'status': this.status,
      'discount': this.discount,
      'total': this.total,
      'subtotal': this.subtotal,
      'deliverycharge': this.deliverycharge,
      'couponCode': this.couponCode,
      'couponId': this.couponId,
      'notes': this.notes,
      'vendor': this.vendor.toJson(),
      'vendorID': this.vendorID,
      'adminCommission': this.adminCommission,
      'adminCommissionType': this.adminCommissionType,
      "tip_amount": this.tipValue,
      if (taxModel != null) "taxSetting": this.taxModel!.toJson(),
      // "extras":this.extras,
      //"extras_price":this.extra_size,
      "takeAway": this.takeAway,
      "deliveryCharge": this.deliveryCharge,
      "specialDiscount": this.specialDiscount,
    };
  }
}
