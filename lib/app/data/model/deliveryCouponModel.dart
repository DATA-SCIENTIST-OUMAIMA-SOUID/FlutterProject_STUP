import 'dart:core';

class DeliveryCouponModel {
  String? code;
  List? users;

  DeliveryCouponModel({this.code, this.users});

  factory DeliveryCouponModel.fromJson(Map<String, dynamic> parsedJson) {
    return DeliveryCouponModel(
      code: parsedJson['code'] ?? 0,
      users: parsedJson['users'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {'code': code, 'users': users};

    return json;
  }
}
