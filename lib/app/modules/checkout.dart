import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_talab_user/app/modules/place_order.dart';

import '../../main.dart';
import '../data/model/OrderModel.dart';
import '../data/model/ProductModel.dart';
import '../data/model/TaxModel.dart';
import '../data/model/VendorModel.dart';
import '../data/model/deliveryCouponModel.dart';
import '../data/provider/localDatabase.dart';
import '../data/services/FirebaseHelper.dart';
import '../data/services/helper.dart';
import '../utils/constants.dart';

class CheckoutScreen extends StatefulWidget {
  final double total;
  final double subtotal;

  final double? discount;
  final String? couponCode;
  final String? couponId, notes;
  final List<CartProduct> products;
  final List<String>? extraAddons;
  final String? tipValue;
  final bool? takeAway;
  final String? deliveryCharge;
  final String? size;
  final bool isPaymentDone;
  final TaxModel? taxModel;
  final Map<String, dynamic>? specialDiscountMap;
  final String? txt;

  const CheckoutScreen(
      {Key? key,
      required this.isPaymentDone,
      required this.total,
      required this.subtotal,
      this.discount,
      this.couponCode,
      this.couponId,
      this.notes,
      required this.products,
      this.extraAddons,
      this.tipValue,
      this.takeAway,
      this.deliveryCharge,
      this.taxModel,
      this.specialDiscountMap,
      this.size,
      required this.txt})
      : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final fireStoreUtils = FireStoreUtils();
  final FireStoreUtils _fireStoreUtils = FireStoreUtils();
  late Map<String, dynamic>? adminCommission;
  String? adminCommissionValue = "", addminCommissionType = "";
  bool? isEnableAdminCommission = false;
  late List<DeliveryCouponModel> couponsList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode() ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Checkout'.tr,
              style: TextStyle(
                  fontSize: 24,
                  color: isDarkMode()
                      ? Colors.grey.shade300
                      : Colors.grey.shade800,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                Divider(
                  height: 3,
                ),
                Container(
                  color: isDarkMode() ? Colors.black : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Deliver to'.tr,
                          style: TextStyle(
                              color: Color(COLOR_PRIMARY),
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            '${MyApp.currentUser!.shippingAddress.line1} ${MyApp.currentUser!.shippingAddress.line2}',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 3,
                ),
                Container(
                  color: isDarkMode() ? Colors.black : Colors.white,
                  child: ListTile(
                    leading: Text(
                      'Total'.tr,
                      style: TextStyle(
                          color: Color(COLOR_PRIMARY),
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    trailing: Text(
                      symbol + widget.total.toDouble().toStringAsFixed(decimal),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: Color(COLOR_PRIMARY),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                FireStoreUtils.createOrder();

                if (!widget.isPaymentDone) {
                  Future.delayed(const Duration(microseconds: 3), () {
                    placeOrder();
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                      visible: widget.isPaymentDone,
                      child: const SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ))),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'PLACE ORDER'.tr,
                    style: TextStyle(
                        color: isDarkMode() ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchCoupons() async {
    try {
      List<DeliveryCouponModel> fetchedCoupons =
          await fireStoreUtils.getDeliveryCouponFromFirebase();
      setState(() {
        couponsList = fetchedCoupons;
      });
    } catch (e) {
      // Handle the error, show an error message, or perform fallback behavior

      // For example, show a snackbar or an error message dialog
    }
  }

  @override
  void initState() {
    fetchCoupons();
    super.initState();
    placeAutoOrder();
  }

  placeAutoOrder() {
    if (widget.isPaymentDone) {
      Future.delayed(const Duration(seconds: 2), () {
        placeOrder();
      });
    }
  }

  placeOrder() async {
    for (int a = 0; a < couponsList.length; a++) {
      if (widget.txt == couponsList[a].code.toString()) {
        for (int b = 0; b < couponsList[a].users!.length; b++) {
          if (MyApp.currentUser!.userID !=
              couponsList[a].users![b].toString()) {
          } else {
            try {
              await _fireStoreUtils.addUserToCoupon(
                  widget.txt!, MyApp.currentUser!.userID);
            } catch (e) {
              // Handle the error

              // For example, show a snackbar or an error message dialog
            }
          }
        }
      }
    }

    List<CartProduct> tempProduc = [];

    for (CartProduct cartProduct in widget.products) {
      CartProduct tempCart = cartProduct;
      // tempCart.extras = cartProduct.extras?.split(",");
      tempProduc.add(tempCart);
    }
    FireStoreUtils fireStoreUtils = FireStoreUtils();
    //place order
    Get.defaultDialog(
      title: 'Placing Order...'.tr,
      content: const CircularProgressIndicator(),
    );
    VendorModel vendorModel = await fireStoreUtils
        .getVendorByVendorID(widget.products.first.vendorID)
        .whenComplete(() => setPrefData());
    log("${vendorModel.fcmToken}{}{}{}{======TOKENADD${vendorModel.toJson()}");
    OrderModel orderModel = OrderModel(
        address: MyApp.currentUser!.shippingAddress,
        author: MyApp.currentUser,
        authorID: MyApp.currentUser!.userID,
        createdAt: Timestamp.now(),
        products: tempProduc,
        status: ORDER_STATUS_PLACED,
        vendor: vendorModel,
        vendorID: widget.products.first.vendorID,
        discount: widget.discount,
        couponCode: widget.couponCode,
        couponId: widget.couponId,
        notes: widget.notes,
        taxModel: widget.taxModel,
        total: widget.total,
        subtotal: widget.subtotal,
        specialDiscount: widget.specialDiscountMap,
        //// extra_size: widget.extra_size,
        // extras: widget.extra_addons!,
        tipValue: widget.tipValue,
        adminCommission: isEnableAdminCommission! ? adminCommissionValue : "0",
        adminCommissionType:
            isEnableAdminCommission! ? addminCommissionType : "",
        takeAway: widget.takeAway,
        deliveryCharge: widget.deliveryCharge);

    OrderModel placedOrder = await fireStoreUtils.placeOrder(orderModel);
    for (int i = 0; i < tempProduc.length; i++) {
      await FireStoreUtils()
          .getProductByID(tempProduc[i].id.split('~').first)
          .then((value) async {
        ProductModel? productModel = value;
        log("-----------1>${value.toJson()}");
        if (tempProduc[i].variant_info != null) {
          for (int j = 0;
              j < productModel.itemAttributes!.variants!.length;
              j++) {
            if (productModel.itemAttributes!.variants![j].variantId ==
                tempProduc[i].id.split('~').last) {
              if (productModel.itemAttributes!.variants![j].variantQuantity !=
                  "-1") {
                productModel.itemAttributes!.variants![j].variantQuantity =
                    (int.parse(productModel
                                .itemAttributes!.variants![j].variantQuantity
                                .toString()) -
                            tempProduc[i].quantity)
                        .toString();
              }
            }
          }
        } else {
          if (productModel.quantity != -1) {
            productModel.quantity =
                productModel.quantity - tempProduc[i].quantity;
          }
        }

        await FireStoreUtils.updateProduct(productModel).then((value) {
          log("-----------2>${value!.toJson()}");
        });
      });
    }

    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceOrderScreen(orderModel: placedOrder),
    );
  }

  Future<void> setPrefData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    sp.setString("musics_key", "");
    sp.setString("addsize", "");
  }
}
