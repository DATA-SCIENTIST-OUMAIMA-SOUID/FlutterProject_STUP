import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mapsToolkit;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_talab_user/app/modules/home_module/home_controller.dart';

import '../../../main.dart';
import '../../data/model/DeliveryChargeModel.dart';
import '../../data/model/ProductModel.dart';
import '../../data/model/TaxModel.dart';
import '../../data/model/VendorModel.dart';
import '../../data/model/deliveryCouponModel.dart';
import '../../data/model/offer_model.dart';
import '../../data/model/variant_info.dart';
import '../../data/provider/localDatabase.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../../userPrefrence.dart';
import '../../utils/constants.dart';
import '../ProductDetailsScreen.dart';
import '../checkout.dart';
import '../shared/AppGlobal.dart';
import '../vendor_module/vendor_page.dart';

Widget _buildChip(String label, int attributesOptionIndex) {
  return Container(
    decoration: BoxDecoration(
        color: const Color(0xffEEEDED), borderRadius: BorderRadius.circular(4)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    ),
  );
}

class cartPage extends StatefulWidget {
  const cartPage({super.key});

  @override
  _cartPageState createState() => _cartPageState();
}

class _cartPageState extends State<cartPage> {
  HomeController homeController = Get.find<HomeController>();
  late Future<List<CartProduct>> cartFuture;
  late List<CartProduct> cartProducts = [];
  late List<DeliveryCouponModel> couponsList = [];
  double total = 0.0;
  double subTotal = 0.0;
  double specialDiscount = 0.0;
  double specialDiscountAmount = 0.0;
  String specialType = "";
  TaxModel? taxModel;
  TextEditingController noteController = TextEditingController(text: '');
  late CartDatabase cartDatabase;
  double grandtotal = 0.0;
  late var snapshot;
  var per = 0.0;
  late Future<List<OfferModel>> coupon;
  TextEditingController txt = TextEditingController(text: '');
  final FireStoreUtils _fireStoreUtils = FireStoreUtils();
  double? percentage, type = 0.0;
  var amount = 0.00;
  late String couponId = '';
  List<String> tempAddonsList = [];
  String priceValue = "", vendorID = "";
  late List<AddAddonsDemo> lstExtras = [];
  late List<String> commaSepratedAddOns = [];
  late List<String> commaSepratedAddSize = [];
  String? commaSepratedAddOnsString = "";
  String? commaSepratedAddSizeString = "";
  double addOnsValue = 0.0, subTotalValue = 0.0, grandTotalValue = 0.0;
  String? adminCommissionValue = "", addminCommissionType = "";
  bool? isEnableAdminCommission = false;
  var addSizeDemo;
  var deliveryCharges = "0";
  VendorModel? vendorModel;
  String? selctedOrderTypeValue = "Delivery".tr;
  bool isDeliverFound = true;
  var tipValue = 0.0;
  String? SelectedDropValue = 'Delivery'.tr;
  bool isTipSelected = false,
      isTipSelected1 = false,
      isTipSelected2 = false,
      isTipSelected3 = false;
  final TextEditingController _textFieldController = TextEditingController();

  late Map<String, dynamic>? adminCommission;

  List<mapsToolkit.LatLng> polygonPoints = [
    mapsToolkit.LatLng(37.7749, -122.4194),
    mapsToolkit.LatLng(37.7749, -122.5194),
    mapsToolkit.LatLng(37.6749, -122.5194),
    mapsToolkit.LatLng(37.6749, -122.4194),
  ];

  // showSheet(CartProduct cartProduct) async {
  //   bool? shouldUpdate = await showModalBottomSheet(
  //     isDismissible: true,
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => CartOptionsSheet(
  //       cartProduct: cartProduct,
  //     ),
  //   );
  //   if (shouldUpdate != null) {
  //     cartFuture = cartDatabase.allCartProducts;
  //     setState(() {});
  //   }
  // }

  addtocard(CartProduct cartProduct, qun) async {
    await cartDatabase.updateProduct(CartProduct(
        id: cartProduct.id,
        name: cartProduct.name,
        photo: cartProduct.photo,
        price: cartProduct.price,
        vendorID: cartProduct.vendorID,
        quantity: qun,
        category_id: cartProduct.category_id,
        discountPrice: cartProduct.discountPrice!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode() ? const Color(DARK_COLOR) : const Color(0xffFFFFFF),
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Color(COLOR_PRIMARY),
          ),
        ),
      ),
      body: StreamBuilder<List<CartProduct>>(
        stream: cartDatabase.watchProducts,
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
              ),
            );
          }

          if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: Center(
                child:
                    showEmptyState("Empty Cart".tr, context, action: () async {
                  Get.toNamed('/home');
                }, buttonTitle: 'shop'.tr),
              ),
            );
          } else {
            cartProducts = snapshot.data!;
            if (!isDeliverFound) {
              getDeliveyData();
            }
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: cartProducts.length,
                          itemBuilder: (context, index) {
                            vendorID = cartProducts[index].vendorID;
                            return Container(
                              margin: const EdgeInsets.only(
                                  left: 13, top: 13, right: 13, bottom: 13),
                              decoration: BoxDecoration(
                                color: isDarkMode()
                                    ? Colors.grey.shade700
                                    : Colors.white,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: const Offset(
                                        0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  buildCartRow(cartProducts[index], lstExtras),
                                ],
                              ),
                            );
                          },
                        ),
                        buildTotalRow(snapshot.data!, lstExtras, vendorID),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (MyApp.currentUser!.userID == '') {
                      Get.offAllNamed("/auth");
                    } else {
                      if (couponId.isEmpty) {
                        txt.text = "";
                      }

                      Map<String, dynamic> specialDiscountMap = {
                        'special_discount': specialDiscountAmount,
                        'special_discount_label': specialDiscount,
                        'specialType': specialType
                      };

                      selctedOrderTypeValue == "Delivery".tr
                          ? push(
                              context,
                              CheckoutScreen(
                                subtotal: subTotal,
                                total: grandtotal,
                                discount: per == 0.0 ? type : per,
                                txt: txt.text,
                                couponCode: txt.text,
                                couponId: couponId,
                                notes: noteController.text,
                                products: cartProducts,
                                extraAddons: commaSepratedAddOns,
                                tipValue: "0",
                                takeAway: false,
                                deliveryCharge: deliveryCharges.toString(),
                                taxModel: taxModel,
                                specialDiscountMap: specialDiscountMap,
                                isPaymentDone: false,
                              ))
                          : push(
                              context,
                              CheckoutScreen(
                                total: grandtotal,
                                subtotal: subTotal,
                                discount: per == 0.0 ? type : per,
                                couponCode: txt.text,
                                couponId: couponId,
                                notes: noteController.text,
                                products: cartProducts,
                                extraAddons: commaSepratedAddOns,
                                tipValue: "0",
                                takeAway: true,
                                deliveryCharge: "0",
                                taxModel: taxModel,
                                specialDiscountMap: specialDiscountMap,
                                isPaymentDone: false,
                                txt: '',
                              ),
                            );
                    }
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 1,
                    height: MediaQuery.of(context).size.height * 0.080,
                    child: Container(
                      color: Color(COLOR_PRIMARY),
                      padding: const EdgeInsets.only(
                          left: 15, right: 10, bottom: 8, top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Text("Total : ".tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Poppinsl",
                                  color: Color(0xFFFFFFFF),
                                )),
                            Text(
                              symbol +
                                  grandtotal
                                      .toDouble()
                                      .toStringAsFixed(decimal),
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "Poppinsm",
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ]),
                          Text("PROCEED TO CHECKOUT".tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "Poppinsm",
                                color: Color(0xFFFFFFFF),
                              )),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }

  buildCartRow(CartProduct cartProduct, List<AddAddonsDemo> addons) {
    List addOnVal = [];
    var quen = cartProduct.quantity;
    double priceTotalValue = 0.0;
    // priceTotalValue   = double.parse(cartProduct.price);
    double addOnValDoule = 0;
    for (int i = 0; i < lstExtras.length; i++) {
      AddAddonsDemo addAddonsDemo = lstExtras[i];
      if (addAddonsDemo.categoryID == cartProduct.id) {
        addOnValDoule = addOnValDoule + double.parse(addAddonsDemo.price!);
      }
    }

    ProductModel? productModel;
    FireStoreUtils()
        .getProductByID(cartProduct.id.split('~').first)
        .then((value) {
      productModel = value;
    });

    VariantInfo? variantInfo;
    if (cartProduct.variant_info != null) {
      variantInfo =
          VariantInfo.fromJson(jsonDecode(cartProduct.variant_info.toString()));
    }
    if (cartProduct.extras == null) {
      addOnVal.clear();
    } else {
      if (cartProduct.extras is String) {
        if (cartProduct.extras == '[]') {
          addOnVal.clear();
        } else {
          String extraDecode = cartProduct.extras
              .toString()
              .replaceAll("[", "")
              .replaceAll("]", "")
              .replaceAll("\"", "");
          if (extraDecode.contains(",")) {
            addOnVal = extraDecode.split(",");
          } else {
            if (extraDecode.trim().isNotEmpty) {
              addOnVal = [extraDecode];
            }
          }
        }
      }

      if (cartProduct.extras is List) {
        addOnVal = List.from(cartProduct.extras);
      }
    }

    if (cartProduct.extras_price != null &&
        cartProduct.extras_price != "" &&
        double.parse(cartProduct.extras_price!) != 0.0) {
      priceTotalValue +=
          double.parse(cartProduct.extras_price!) * cartProduct.quantity;
    }
    priceTotalValue += double.parse(cartProduct.price) * cartProduct.quantity;

    // VariantInfo variantInfo= cartProduct.variant_info;
    return InkWell(
      onTap: () {
        _fireStoreUtils.getVendorByVendorID(cartProduct.vendorID).then((value) {
          push(
            context,
            NewVendorProductsScreen(
              vendorModel: value,
              deliveryPrice: homeController.deliveryCharges,
            ),
          );
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                      height: 80,
                      width: 80,
                      imageUrl: getImageVAlidUrl(cartProduct.photo),
                      imageBuilder: (context, imageProvider) => Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            )),
                          ),
                      errorWidget: (context, url, error) => ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(
                            AppGlobal.placeHolderImage!,
                            fit: BoxFit.cover,
                          ))),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartProduct.name,
                        style: const TextStyle(
                            fontSize: 18, fontFamily: "Poppinsm"),
                      ),
                      Text(
                        symbol +
                            priceTotalValue.toDouble().toStringAsFixed(decimal),
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Poppinsm",
                            color: Color(COLOR_PRIMARY)),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (quen != 0) {
                          quen--;
                          removetocard(cartProduct, quen);
                        }
                      },
                      child: Image(
                        image: const AssetImage("assets/images/minus.png"),
                        color: Color(COLOR_PRIMARY),
                        height: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      '${cartProduct.quantity}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (productModel!.itemAttributes != null) {
                          if (productModel!.itemAttributes!.variants!
                              .where((element) =>
                                  element.variantSku == variantInfo!.variantSku)
                              .isNotEmpty) {
                            if (int.parse(productModel!
                                        .itemAttributes!.variants!
                                        .where((element) =>
                                            element.variantSku ==
                                            variantInfo!.variantSku)
                                        .first
                                        .variantQuantity
                                        .toString()) >
                                    quen ||
                                int.parse(productModel!
                                        .itemAttributes!.variants!
                                        .where((element) =>
                                            element.variantSku ==
                                            variantInfo!.variantSku)
                                        .first
                                        .variantQuantity
                                        .toString()) ==
                                    -1) {
                              quen++;
                              addtocard(cartProduct, quen);
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Food out of stock"),
                              ));
                            }
                          } else {
                            if (productModel!.quantity > quen ||
                                productModel!.quantity == -1) {
                              quen++;
                              addtocard(cartProduct, quen);
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Food out of stock"),
                              ));
                            }
                          }
                        } else {
                          if (productModel!.quantity > quen ||
                              productModel!.quantity == -1) {
                            quen++;
                            addtocard(cartProduct, quen);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Food out of stock"),
                            ));
                          }
                        }
                      },
                      child: Image(
                        image: const AssetImage("assets/images/plus.png"),
                        color: Color(COLOR_PRIMARY),
                        height: 30,
                      ),
                    )
                  ],
                )
              ],
            ),
            variantInfo == null || variantInfo.variantOptions!.isEmpty
                ? Container()
                : Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: List.generate(
                        variantInfo.variantOptions!.length,
                        (i) {
                          return _buildChip(
                              "${variantInfo?.variantOptions![variantInfo.variantOptions!.keys.elementAt(i)]}",
                              i);
                        },
                      ).toList(),
                    ),
                  ),
            SizedBox(
              height: addOnVal.isEmpty ? 0 : 30,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ListView.builder(
                    itemCount: addOnVal.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Text(
                        "${addOnVal[index].toString().replaceAll("\"", "")} ${(index == addOnVal.length - 1) ? "" : ","}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTotalRow(
      List<CartProduct> data, List<AddAddonsDemo> lstExtras, String vendorID) {
    var font = 16.00;
    subTotal = 0.00;
    grandtotal = 0;
    double? discountVal = 0;

    for (int a = 0; a < data.length; a++) {
      CartProduct e = data[a];
      double addOnValDoule = 0;
      for (int i = 0; i < lstExtras.length; i++) {
        AddAddonsDemo addAddonsDemo = lstExtras[i];
        if (addAddonsDemo.categoryID == e.id) {
          addOnValDoule = addOnValDoule + double.parse(addAddonsDemo.price!);
        }
      }
      if (e.extras_price != null &&
          e.extras_price != "" &&
          double.parse(e.extras_price!) != 0.0) {
        subTotal += double.parse(e.extras_price!) * e.quantity;
      }
      subTotal += double.parse(e.price) * e.quantity;

      if (deliveryCharges is double) {
        String myString = deliveryCharges.toString();

        grandtotal = subTotal + double.parse(myString);
      }
    }

    if (percentage != null) {
      amount = 0;
      amount = subTotal * percentage! / 100;
      discountVal = subTotal * percentage! / 100;
      grandtotal = grandtotal - amount;
      per = amount.toDouble();
    }
    amount = grandtotal - type!;
    grandtotal = amount;
    if (type != 0) {
      discountVal = type;
    }
    if (vendorModel != null) {
      if (vendorModel!.specialDiscountEnable) {
        final now = DateTime.now();
        var day = DateFormat('EEEE', 'en_US').format(now);
        var date = DateFormat('dd-MM-yyyy').format(now);
        for (var element in vendorModel!.specialDiscount) {
          if (day == element.day.toString()) {
            if (element.timeslot!.isNotEmpty) {
              for (var element in element.timeslot!) {
                if (element.discountType == "delivery".tr) {
                  var start = DateFormat("dd-MM-yyyy HH:mm")
                      .parse("$date ${element.from}");
                  var end = DateFormat("dd-MM-yyyy HH:mm")
                      .parse("$date ${element.to}");
                  if (isCurrentDateInRange(start, end)) {
                    specialDiscount = double.parse(element.discount.toString());
                    specialType = element.type.toString();
                    if (element.type == "percentage") {
                      specialDiscountAmount = subTotal * specialDiscount / 100;
                    } else {
                      specialDiscountAmount = specialDiscount;
                    }
                    grandtotal = grandtotal - specialDiscountAmount;
                  }
                }
              }
            }
          }
        }
      } else {
        specialDiscount = double.parse("0");
        specialType = "amount";
      }
    }
    double amounts = subTotal - discountVal! - specialDiscountAmount;
    //double amountwithdelivry=  getTaxValue(taxModel, amounts)+double.parse(deliveryCharges).toStringAsFixed(2);

    if (deliveryCharges is double) {
      String myString = deliveryCharges.toString();

      grandtotal = amounts + double.parse(myString);
    } else {
      grandtotal = amounts + double.parse(deliveryCharges);
    }
    // });
    // });
    print("test :${(grandtotal)}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            margin:
                const EdgeInsets.only(left: 13, top: 13, right: 13, bottom: 13),
            decoration: BoxDecoration(
              color: isDarkMode() ? Colors.grey.shade700 : Colors.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Image(
                    image: AssetImage("assets/images/reedem.png"),
                    width: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      children: [
                        Text(
                          "Redeem Coupon".tr,
                          style: const TextStyle(
                            fontFamily: "Poppinsm",
                          ),
                        ),
                        Text("Add coupon code".tr,
                            style: const TextStyle(
                              fontFamily: "Poppinsr",
                            )),
                      ],
                    ),
                  )
                ]),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        isDismissible: true,
                        context: context,
                        backgroundColor: Colors.transparent,
                        enableDrag: true,
                        builder: (BuildContext context) => sheet());
                  },
                  child: const Image(
                      image: AssetImage("assets/images/add.png"), width: 40),
                )
              ],
            )),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode() ? Colors.grey.shade700 : Colors.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Remarks".tr,
                      style: const TextStyle(
                        fontFamily: "Poppinsm",
                      ),
                    ),
                    Text("remarks-restaurant".tr,
                        style: const TextStyle(
                          fontFamily: "Poppinsr",
                        )),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        isDismissible: true,
                        context: context,
                        backgroundColor: Colors.transparent,
                        enableDrag: true,
                        builder: (BuildContext context) => noteSheet());
                  },
                  child: const Image(
                      image: AssetImage("assets/images/add.png"), width: 40),
                )
              ],
            )),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
              borderRadius: BorderRadius.circular(8),
              color: isDarkMode() ? Colors.grey.shade700 : Colors.white,
            ),
            child: DropdownButton(
              style: const TextStyle(fontSize: 16, color: Colors.black),
              iconSize: 24,
              isExpanded: true,
              // Not necessary for Option 1
              value: SelectedDropValue,
              dropdownColor: isDarkMode() ? Colors.black : Colors.white,
              onChanged: (newValue) async {
                setState(() {
                  SelectedDropValue = newValue;
                  selctedOrderTypeValue = newValue;
                  if (selctedOrderTypeValue == 'Takeaway'.tr) {
                    deliveryCharges = '0';
                    tipValue = 0;
                  } else {
                    getDeliveyData();
                  }
                });
              },

              icon: Icon(
                size: 35,
                Icons.keyboard_arrow_down,
                color: Color(
                  COLOR_PRIMARY,
                ),
              ),
              items: [
                'Delivery'.tr,
                'Takeaway'.tr,
              ].map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location,
                      style: TextStyle(
                          color: isDarkMode() ? Colors.white : Colors.black,
                          fontSize: 20)),
                );
              }).toList(),
            ),
          ),
        ),
        Container(
          margin:
              const EdgeInsets.only(left: 13, top: 10, right: 13, bottom: 13),
          decoration: BoxDecoration(
            color: isDarkMode() ? Colors.grey.shade700 : Colors.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 2,
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Delivery Option: ".tr,
                        style:
                            TextStyle(fontFamily: "Poppinsm", fontSize: font),
                      ),
                      Text(
                        selctedOrderTypeValue == "Delivery".tr
                            ? "دليفري (${symbol + double.parse(deliveryCharges).toStringAsFixed(decimal)})"
                            : "${selctedOrderTypeValue!} (مجاني)".tr,
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            color: isDarkMode()
                                ? const Color(0xffFFFFFF)
                                : const Color(0xff333333),
                            fontSize: selctedOrderTypeValue == "Delivery".tr
                                ? font
                                : 15),
                      ),
                    ],
                  )),
              const Divider(
                color: Color(0xffE2E8F0),
                height: 0.1,
              ),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subtotal".tr,
                        style:
                            TextStyle(fontFamily: "Poppinsm", fontSize: font),
                      ),
                      Text(
                        symbol + subTotal.toStringAsFixed(decimal),
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            color: isDarkMode()
                                ? const Color(0xffFFFFFF)
                                : const Color(0xff333333),
                            fontSize: font),
                      ),
                    ],
                  )),
              const Divider(
                color: Color(0xffE2E8F0),
                height: 0.1,
              ),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Discount".tr,
                        style:
                            TextStyle(fontFamily: "Poppinsm", fontSize: font),
                      ),
                      Text(
                        percentage != 0.0
                            ? percentage != null
                                ? "($symbol${per.toDouble().toStringAsFixed(decimal)})"
                                : "($symbol${0.toStringAsFixed(decimal)})"
                            : type != null
                                ? "($symbol${type!.toDouble().toStringAsFixed(decimal)})"
                                : "($symbol${0.toStringAsFixed(decimal)})",
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            color: isDarkMode()
                                ? const Color(0xffFFFFFF)
                                : const Color(0xff333333),
                            fontSize: font),
                      ),
                    ],
                  )),
              const Divider(
                color: Color(0xffE2E8F0),
                height: 0.1,
              ),
              Visibility(
                visible: vendorModel != null
                    ? vendorModel!.specialDiscountEnable
                    : false,
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${"Special Discount".tr}($specialDiscount ${specialType == "amount" ? symbol : "%"})",
                          style:
                              TextStyle(fontFamily: "Poppinsm", fontSize: font),
                        ),
                        Text(
                          symbol +
                              specialDiscountAmount.toStringAsFixed(decimal),
                          style: TextStyle(
                              fontFamily: "Poppinsm",
                              color: isDarkMode()
                                  ? const Color(0xffFFFFFF)
                                  : const Color(0xff333333),
                              fontSize: font),
                        ),
                      ],
                    )),
              ),
              const Divider(
                color: Color(0xffE2E8F0),
                height: 0.1,
              ),
              selctedOrderTypeValue == "Delivery".tr
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Delivery Charges".tr,
                            style: TextStyle(
                                fontFamily: "Poppinsm", fontSize: font),
                          ),
                          Text(
                            symbol +
                                double.parse(deliveryCharges)
                                    .toStringAsFixed(decimal),
                            style: TextStyle(
                                fontFamily: "Poppinsm",
                                color: isDarkMode()
                                    ? const Color(0xffFFFFFF)
                                    : const Color(0xff333333),
                                fontSize: font),
                          ),
                        ],
                      ))
                  : Container(),
              taxModel != null
                  ? const Divider(
                      color: Color(0xffE2E8F0),
                      height: 0.1,
                    )
                  : Container(),
              taxModel != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${(taxModel!.label!.isNotEmpty) ? taxModel!.label.toString() : "Tax"} ${(taxModel!.type == "fix") ? "" : "(${taxModel!.tax} %)"}",
                            style: TextStyle(
                                fontFamily: "Poppinsm", fontSize: font),
                          ),
                          Text(
                            symbol +
                                getTaxValue(
                                        taxModel,
                                        subTotal -
                                            discountVal -
                                            specialDiscountAmount)
                                    .toStringAsFixed(decimal),
                            style: TextStyle(
                                fontFamily: "Poppinsm",
                                color: isDarkMode()
                                    ? const Color(0xffFFFFFF)
                                    : const Color(0xff333333),
                                fontSize: font),
                          ),
                        ],
                      ))
                  : Container(),
              const Divider(
                color: Color(0xffE2E8F0),
                height: 0.1,
              ),
              Visibility(
                  visible: ((tipValue) > 0),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tip amount".tr,
                            style: TextStyle(
                                fontFamily: "Poppinsm",
                                color: isDarkMode()
                                    ? const Color(0xffFFFFFF)
                                    : const Color(0xff333333),
                                fontSize: font),
                          ),
                          Text(
                            '$symbol${tipValue.toStringAsFixed(decimal)}',
                            style: TextStyle(
                                fontFamily: "Poppinsm",
                                color: isDarkMode()
                                    ? const Color(0xffFFFFFF)
                                    : const Color(0xff333333),
                                fontSize: font),
                          ),
                        ],
                      ))),
              const Divider(
                color: Color(0xffE2E8F0),
                height: 0.1,
              ),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order Total".tr,
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            color: isDarkMode()
                                ? const Color(0xffFFFFFF)
                                : const Color(0xff333333),
                            fontSize: font),
                      ),
                      Text(
                        symbol + grandtotal.toDouble().toStringAsFixed(decimal),
                        style: TextStyle(
                            fontFamily: "Poppinsm",
                            color: isDarkMode()
                                ? const Color(0xffFFFFFF)
                                : const Color(0xff333333),
                            fontSize: font),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getDeliveyData();
    cartDatabase = CartDatabase();
    cartFuture = cartDatabase.allCartProducts;
    _fireStoreUtils.getTaxSetting().then((value) {});

    // getPrefData();
    //setPrefData();
  }

  Future<void> fetchCoupons() async {
    try {
      List<DeliveryCouponModel> fetchedCoupons =
          await _fireStoreUtils.getDeliveryCouponFromFirebase();
      setState(() {
        couponsList = fetchedCoupons;
      });
    } catch (e) {
      // Handle the error, show an error message, or perform fallback behavior
      // For example, show a snackbar or an error message dialog
    }
  }

  Future<void> getDeliveyDat(vendorModel) async {
    if (selctedOrderTypeValue == "Delivery".tr) {
      num km = num.parse(getKm(
        vendorModel.latitude,
        vendorModel.longitude,
      ));
      _fireStoreUtils.getDeliveryCharges().then((value) {
        if (value != null) {
          DeliveryChargeModel deliveryChargeModel = value;

          if (!deliveryChargeModel.vendorCanModify) {
            if (km > deliveryChargeModel.minimumDeliveryChargesWithinKm) {
              deliveryCharges = (km * deliveryChargeModel.deliveryChargesPerKm)
                  .toDouble()
                  .toStringAsFixed(decimal);
            } else {
              deliveryCharges = deliveryChargeModel.minimumDeliveryCharges
                  .toDouble()
                  .toStringAsFixed(decimal);
            }
          } else {
            if (vendorModel != null && vendorModel!.deliveryCharge != null) {
              if (km >
                  vendorModel!.deliveryCharge!.minimumDeliveryChargesWithinKm) {
                deliveryCharges =
                    (km * vendorModel!.deliveryCharge!.deliveryChargesPerKm)
                        .toDouble()
                        .toStringAsFixed(decimal);
              } else {
                deliveryCharges = vendorModel!
                    .deliveryCharge!.minimumDeliveryCharges
                    .toDouble()
                    .toStringAsFixed(decimal);
              }
            } else {
              if (km > deliveryChargeModel.minimumDeliveryChargesWithinKm) {
                deliveryCharges =
                    (km * deliveryChargeModel.deliveryChargesPerKm)
                        .toDouble()
                        .toStringAsFixed(decimal);
              } else {
                deliveryCharges = deliveryChargeModel.minimumDeliveryCharges
                    .toDouble()
                    .toStringAsFixed(decimal);
              }
            }
          }
        }
      });
    }
  }

  Future<void> getDeliveyData() async {
    deliveryCharges = homeController.deliveryCharges.value;
    if (!deliveryCharges.isEmpty) {
      print("deliveryChargesSds");

      UserPreference.setdeliveryCharges(deliveryCharges: deliveryCharges);
    } else {
      print("getdeliveryCharges");

      deliveryCharges = UserPreference.getdeliveryCharges();
    }
    print("deliveryCharges");
    print(deliveryCharges);
  }

  @override
  void initState() {
    super.initState();
    getDeliveyData();
    print("deliveryCharges");

    fetchCoupons();
    Future.delayed(Duration.zero, () {
      setState(() {
        deliveryCharges = UserPreference.getdeliveryCharges();
        if (deliveryCharges == "") {
          getDeliveyData();
        }
        cartFuture = cartDatabase.allCartProducts;
      });
    });
    coupon = _fireStoreUtils.getAllCoupons();
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  noteSheet() {
    return Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height / 4.3,
            left: 25,
            right: 25),
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(style: BorderStyle.none)),
        child: Column(children: [
          InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 0.3),
                    color: Colors.transparent,
                    shape: BoxShape.circle),

                // radius: 20,
                child: const Center(
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              )),
          const SizedBox(
            height: 25,
          ),
          Expanded(
              child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDarkMode() ? Colors.grey.shade700 : Colors.white),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Remarks'.tr,
                        style: TextStyle(
                            fontFamily: 'Poppinssb',
                            color: isDarkMode()
                                ? const Color(0XFFD5D5D5)
                                : const Color(0XFF2A2A2A),
                            fontSize: 16),
                      )),
                  Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Write remarks for restaurant',
                        style: TextStyle(
                            fontFamily: 'Poppinsr',
                            color: isDarkMode()
                                ? Colors.white70
                                : const Color(0XFF9091A4),
                            letterSpacing: 0.5,
                            height: 2),
                      )),
                  Container(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 20),
                      // height: 120,
                      child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(12),
                          dashPattern: const [4, 2],
                          color: isDarkMode()
                              ? const Color(0XFF484848)
                              : const Color(0XFFB7B7B7),
                          child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                              child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 20, bottom: 20),
                                  color: isDarkMode()
                                      ? const Color(0XFF0e0b08)
                                      : const Color(0XFFF1F4F7),
                                  // height: 120,
                                  alignment: Alignment.center,
                                  child: TextFormField(
                                    textAlign: TextAlign.center,
                                    controller: noteController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Write Remarks'.tr,
                                      hintStyle: const TextStyle(
                                          color: Color(0XFF9091A4)),
                                      labelStyle: const TextStyle(
                                          color: Color(0XFF333333)),
                                    ),
                                  ))))),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 30),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 15),
                        backgroundColor: Color(COLOR_PRIMARY),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'SUBMIT'.tr,
                        style: TextStyle(
                            color: isDarkMode() ? Colors.white : Colors.black,
                            fontFamily: 'Poppinsm',
                            fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ]));
  }

  removetocard(CartProduct cartProduct, qun) async {
    if (qun >= 1) {
      await cartDatabase.updateProduct(CartProduct(
          id: cartProduct.id,
          category_id: cartProduct.category_id,
          name: cartProduct.name,
          photo: cartProduct.photo,
          price: cartProduct.price,
          vendorID: cartProduct.vendorID,
          quantity: qun,
          discountPrice: cartProduct.discountPrice));
    } else {
      cartDatabase.removeProduct(cartProduct.id);
    }
  }

  Future<void> saveFoodTypeValue() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    sp.setString('foodType', selctedOrderTypeValue!);
  }

  sheet() {
    return Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height / 4.3,
            left: 25,
            right: 25),
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(style: BorderStyle.none)),
        child: FutureBuilder<List<OfferModel>>(
            future: coupon,
            initialData: const [],
            builder: (context, snapshot) {
              snapshot = snapshot;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  ),
                );
              }

              // coupon = snapshot.data as Future<List<CouponModel>> ;
              return Column(children: [
                InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 0.3),
                          color: Colors.transparent,
                          shape: BoxShape.circle),

                      // radius: 20,
                      child: const Center(
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    )),
                const SizedBox(
                  height: 25,
                ),
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.only(top: 30),
                            child: const Image(
                              image:
                                  AssetImage('assets/images/redeem_coupon.png'),
                              width: 100,
                            )),
                        Container(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              'Redeem Your Coupons'.tr,
                              style: const TextStyle(
                                  fontFamily: 'Poppinssb',
                                  color: Color(0XFF2A2A2A),
                                  fontSize: 16),
                            )),
                        Container(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              "Voucher or Coupon code".tr,
                              style: const TextStyle(
                                  fontFamily: 'Poppinsr',
                                  color: Color(0XFF9091A4),
                                  letterSpacing: 0.5,
                                  height: 2),
                            )),
                        Container(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 20),
                            // height: 120,
                            child: DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(12),
                                dashPattern: const [4, 2],
                                color: const Color(0XFFB7B7B7),
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12)),
                                    child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 20,
                                            bottom: 20),
                                        color: const Color(0XFFF1F4F7),
                                        // height: 120,
                                        alignment: Alignment.center,
                                        child: TextFormField(
                                          textAlign: TextAlign.center,
                                          controller: txt,

                                          // textAlignVertical: TextAlignVertical.center,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Write Coupon Code".tr,
                                            hintStyle: const TextStyle(
                                                color: Color(0XFF9091A4)),
                                            labelStyle: const TextStyle(
                                                color: Color(0XFF333333)),
                                            //  hintTextDirection: TextDecoration.lineThrough
                                            // contentPadding: EdgeInsets.only(left: 80,right: 30),
                                          ),
                                        ))))),
                        Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: 30),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 15),
                              backgroundColor: Color(COLOR_PRIMARY),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              percentage = 0.0;
                              type = 0.0;
                              couponId = "";
                              setState(() {
                                for (int a = 0; a < couponsList.length; a++) {
                                  if (txt.text.toString() ==
                                      couponsList[a].code.toString()) {
                                    for (int b = 0;
                                        b < couponsList[a].users!.length;
                                        b++) {
                                      if (MyApp.currentUser!.userID !=
                                          couponsList[a].users![b].toString()) {
                                        deliveryCharges = "0";
                                      }
                                    }
                                  }
                                }

                                for (int a = 0;
                                    a < snapshot.data!.length;
                                    a++) {
                                  OfferModel couponModel = snapshot.data![a];

                                  if (vendorID == couponModel.restaurantId ||
                                      couponModel.restaurantId == "") {
                                    if (txt.text.toString() ==
                                        couponModel.offerCode!.toString()) {
                                      if (couponModel.discountTypeOffer ==
                                              'Percentage' ||
                                          couponModel.discountTypeOffer ==
                                              'Percent') {
                                        percentage = double.parse(
                                            couponModel.discountOffer!);
                                        couponId = couponModel.offerId!;
                                        break;
                                      } else {
                                        type = double.parse(
                                            couponModel.discountOffer!);
                                        couponId = couponModel.offerId!;
                                      }
                                    }
                                  }
                                }
                              });

                              Navigator.pop(context);
                            },
                            child: Text(
                              "REDEEM NOW".tr,
                              style: TextStyle(
                                  color: isDarkMode()
                                      ? Colors.black
                                      : Colors.white,
                                  fontFamily: 'Poppinsm',
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                //buildcouponItem(snapshot)
                //  listData(snapshot)
              ]);
            }));
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Tip your driver partner'.tr),
            content: TextField(
              controller: _textFieldController,
              textInputAction: TextInputAction.go,
              keyboardType: const TextInputType.numberWithOptions(),
              decoration: const InputDecoration(hintText: "Enter your tip"),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(COLOR_PRIMARY),
                    textStyle: const TextStyle(fontWeight: FontWeight.normal)),
                child: const Text('cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(COLOR_PRIMARY),
                    textStyle: const TextStyle(fontWeight: FontWeight.normal)),
                child: const Text('Submit'),
                onPressed: () {
                  setState(() {
                    var value = _textFieldController.text.toString();
                    if (value.isEmpty) {
                      isTipSelected3 = false;
                      tipValue = 0;
                    } else {
                      isTipSelected3 = true;
                      tipValue = double.parse(value);
                    }
                    isTipSelected = false;
                    isTipSelected1 = false;
                    isTipSelected2 = false;

                    Navigator.of(context).pop();
                  });
                },
              )
            ],
          );
        });
  }
}
