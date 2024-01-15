import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_talab_user/app/modules/home_module/home_controller.dart';
import 'package:super_talab_user/app/modules/shared/AppGlobal.dart';
import 'package:super_talab_user/app/modules/vendor_module/vendor_page.dart';

import '../data/model/AttributesModel.dart';
import '../data/model/ItemAttributes.dart';
import '../data/model/ProductModel.dart';
import '../data/model/ReviewAttributeModel.dart';
import '../data/model/VendorModel.dart';
import '../data/model/variant_info.dart';
import '../data/provider/localDatabase.dart';
import '../data/services/FirebaseHelper.dart';
import '../data/services/Indicator.dart';
import '../data/services/helper.dart';
import '../utils/constants.dart';
import 'cart_module/cart_page.dart';

class AddAddonsDemo {
  String? name;
  int? index;
  String? price;
  bool isCheck;
  String? categoryID;

  AddAddonsDemo(
      {this.name,
        this.index,
        this.price,
        this.isCheck = false,
        this.categoryID});

  factory AddAddonsDemo.fromJson(Map<String, dynamic> jsonData) {
    return AddAddonsDemo(
        index: jsonData['index'],
        name: jsonData['name'],
        price: jsonData['price'],
        isCheck: jsonData['isCheck'],
        categoryID: jsonData["categoryID"]);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'index': index,
      'price': price,
      'isCheck': isCheck,
      'categoryID': categoryID
    };
  }

  @override
  String toString() {
    return '{name: $name, index: $index, price: $price, isCheck: $isCheck, categoryID: $categoryID}';
  }

  static List<AddAddonsDemo> decode(String item) =>
      (json.decode(item) as List<dynamic>)
          .map<AddAddonsDemo>((item) => AddAddonsDemo.fromJson(item))
          .toList();

  static String encode(List<AddAddonsDemo> item) => json.encode(
    item
        .map<Map<String, dynamic>>((item) => AddAddonsDemo.toMap(item))
        .toList(),
  );

  static Map<String, dynamic> toMap(AddAddonsDemo music) => {
    'index': music.index,
    'name': music.name,
    'price': music.price,
    'isCheck': music.isCheck,
    "categoryID": music.categoryID
  };
}

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel productModel;
  final VendorModel vendorModel;

  const ProductDetailsScreen(
      {Key? key, required this.productModel, required this.vendorModel})
      : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late CartDatabase cartDatabase;
  HomeController homeController = Get.find();
  String radioItem = '';
  int id = -1;
  List<AddAddonsDemo> lstAddAddonsCustom = [];
  List<AddAddonsDemo> lstTemp = [];
  double priceTemp = 0.0, lastPrice = 0.0;
  int productQnt = 0;
  List<String> productImage = [];

  List<Attributes>? attributes = [];
  List<Variants>? variants = [];

  List<String> selectedVariants = [];
  List<String> selectedIndexVariants = [];
  List<String> selectedIndexArray = [];
  Map<String, dynamic> map = <String, dynamic>{};
  final cartProvider = Provider.of<CartDatabase>(Get.context!);

  bool isOpen = false;

  List<ReviewAttributeModel> reviewAttributeList = [];

  List<ProductModel> productList = [];

  List<ProductModel> storeProductList = [];

  bool showLoader = true;


  List<AttributesModel> attributesList = [];
  final PageController _controller =
  PageController(viewportFraction: 1, keepPage: true);

  addtocard(ProductModel productModel, bool isIncerementQuantity) async {
    bool isAddOnApplied = false;
    double addOnVal = 0;
    for (int i = 0; i < lstTemp.length; i++) {
      AddAddonsDemo addAddonsDemo = lstTemp[i];
      if (addAddonsDemo.categoryID == widget.productModel.id) {
        isAddOnApplied = true;
        addOnVal = addOnVal + double.parse(addAddonsDemo.price!);
      }
    }
    List<CartProduct> cartProducts = await cartDatabase.allCartProducts;
    if (productQnt > 1) {
      var joinTitleString = "";
      String mainPrice = "";
      List<AddAddonsDemo> lstAddOns = [];
      List<String> lstAddOnsTemp = [];
      double extrasPrice = 0.0;

      SharedPreferences sp = await SharedPreferences.getInstance();
      String addOns =
      sp.getString("musics_key") != null ? sp.getString('musics_key')! : "";

      bool isAddSame = false;
      if (!isAddSame) {
        if (productModel.disPrice != null &&
            productModel.disPrice!.isNotEmpty &&
            double.parse(productModel.disPrice!) != 0) {
          mainPrice = productModel.disPrice!;
        } else {
          mainPrice = productModel.price;
        }
      }

      if (addOns.isNotEmpty) {
        lstAddOns = AddAddonsDemo.decode(addOns);
        for (int a = 0; a < lstAddOns.length; a++) {
          AddAddonsDemo newAddonsObject = lstAddOns[a];
          if (newAddonsObject.categoryID == widget.productModel.id) {
            if (newAddonsObject.isCheck == true) {
              lstAddOnsTemp.add(newAddonsObject.name!);
              extrasPrice += (double.parse(newAddonsObject.price!));
            }
          }
        }

        joinTitleString = lstAddOnsTemp.join(",");
      }

      final bool productIsInList = cartProducts.any((product) =>
      product.id ==
          "${productModel.id}~${productModel.variantInfo != null ? productModel.variantInfo!.variantId.toString() : ""}");
      if (productIsInList) {
        CartProduct element = cartProducts.firstWhere((product) =>
        product.id ==
            "${productModel.id}~${productModel.variantInfo != null ? productModel.variantInfo!.variantId.toString() : ""}");

        await cartDatabase.updateProduct(CartProduct(
            id: element.id,
            name: element.name,
            photo: element.photo,
            price: element.price,
            vendorID: element.vendorID,
            quantity:
            isIncerementQuantity ? element.quantity + 1 : element.quantity,
            category_id: element.category_id,
            extras_price: extrasPrice.toString(),
            extras: joinTitleString,
            discountPrice: element.discountPrice!));
      } else {
        await cartDatabase.updateProduct(CartProduct(
            id: "${productModel.id}~${productModel.variantInfo != null ? productModel.variantInfo!.variantId.toString() : ""}",

            name: productModel.name,
            photo: productModel.photo,
            price: mainPrice,
            discountPrice: productModel.disPrice,
            vendorID: productModel.vendorID,
            quantity: productQnt,
            extras_price: extrasPrice.toString(),
            extras: joinTitleString,
            category_id: productModel.categoryID,
            variant_info: productModel.variantInfo));
      }
      //  });
      setState(() {});
    } else {
      if (cartProducts.isEmpty) {
        cartDatabase.addProduct(
            productModel, cartDatabase, isIncerementQuantity);
      } else {
        if (cartProducts[0].vendorID == widget.vendorModel.id) {
          cartDatabase.addProduct(
              productModel, cartDatabase, isIncerementQuantity);
        } else {
          cartDatabase.deleteAllProducts();
          cartDatabase.addProduct(
              productModel, cartDatabase, isIncerementQuantity);

          if (isAddOnApplied && addOnVal > 0) {
            priceTemp += (addOnVal * productQnt);
          }
        }
      }
    }
    updatePrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode() ? Colors.black : Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [
          Stack(children: [
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.54,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.50,
                      child: PageView.builder(
                          itemCount: productImage.length,
                          scrollDirection: Axis.horizontal,
                          controller: _controller,
                          onPageChanged: (value) {
                            setState(() {});
                          },
                          allowImplicitScrolling: true,
                          itemBuilder: (context, index) => CachedNetworkImage(
                            imageUrl: getImageVAlidUrl(productImage[index]),
                            imageBuilder: (context, imageProvider) =>
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                            placeholder: (context, url) => Center(
                                child: CircularProgressIndicator.adaptive(
                                  valueColor: AlwaysStoppedAnimation(
                                      Color(COLOR_PRIMARY)),
                                )),
                            errorWidget: (context, url, error) =>
                                Image.network(
                                  AppGlobal.placeHolderImage!,
                                  fit: BoxFit.fitWidth,
                                ),
                            fit: BoxFit.contain,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Indicator(
                        controller: _controller,
                        itemCount: productImage.length,
                      ),
                    ),
                  ],
                )),
            Positioned(
                top: MediaQuery.of(context).size.height * 0.033,
                left: MediaQuery.of(context).size.width * 0.03,
                child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 20,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 25,
                      ),
                    ))),
          ]),
          Container(
            color: isDarkMode() ? Colors.black : const Color(0xFFFFFFFF),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.productModel.name,
                                style: const TextStyle(
                                    fontFamily: "Poppinsm",
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            widget.productModel.disPrice == "" ||
                                widget.productModel.disPrice == "0"
                                ? Text(
                              "$symbol${double.parse(widget.productModel.price).toStringAsFixed(decimal)}",
                              style: TextStyle(
                                  fontFamily: "Poppinsm",
                                  letterSpacing: 0.5,
                                  color: Color(COLOR_PRIMARY),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            )
                                : Row(
                              children: [
                                Text(
                                  "$symbol${double.parse(widget.productModel.disPrice.toString()).toStringAsFixed(decimal)}",
                                  style: TextStyle(
                                    fontFamily: "Poppinsm",
                                    fontWeight: FontWeight.bold,
                                    color: Color(COLOR_PRIMARY),
                                  ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  '$symbol${double.parse(widget.productModel.price).toStringAsFixed(decimal)}',
                                  style: const TextStyle(
                                      fontFamily: "Poppinsm",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      decoration:
                                      TextDecoration.lineThrough),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: CachedNetworkImage(
                                      height: 70,
                                      width: 70,
                                      imageUrl: getImageVAlidUrl(
                                          widget.vendorModel.photo),
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                      placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator
                                              .adaptive(
                                            valueColor: AlwaysStoppedAnimation(
                                                Color(COLOR_PRIMARY)),
                                          )),
                                      errorWidget: (context, url, error) =>
                                          ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(15),
                                              child: Image.network(
                                                placeholderImage,
                                                fit: BoxFit.cover,
                                              )),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    child: InkWell(
                                        onTap: () async {
                                          push(
                                            context,
                                            NewVendorProductsScreen(
                                              vendorModel: widget.vendorModel,
                                              deliveryPrice: homeController
                                                  .deliveryCharges,
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(widget.vendorModel.title,
                                                style: TextStyle(
                                                    color: Color(COLOR_PRIMARY),
                                                    fontSize: 16,
                                                    fontWeight:
                                                    FontWeight.bold)),
                                            Text(
                                                isOpen == true
                                                    ? "Open"
                                                    : "Close",
                                                style: TextStyle(
                                                    color: isOpen == true
                                                        ? Colors.green
                                                        : Colors.red)),
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  productQnt == 0
                                      ? isOpen == false
                                      ? const Center()
                                      : TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        if (variants!
                                            .where((element) =>
                                        element.variantSku ==
                                            selectedVariants
                                                .join('-'))
                                            .isNotEmpty) {
                                          if (int.parse(variants!
                                              .where((element) =>
                                          element
                                              .variantSku ==
                                              selectedVariants
                                                  .join(
                                                  '-'))
                                              .first
                                              .variantQuantity
                                              .toString()) >=
                                              1 ||
                                              int.parse(variants!
                                                  .where((element) =>
                                              element
                                                  .variantSku ==
                                                  selectedVariants
                                                      .join(
                                                      '-'))
                                                  .first
                                                  .variantQuantity
                                                  .toString()) ==
                                                  -1) {
                                            VariantInfo? variantInfo =
                                            VariantInfo();
                                            widget.productModel
                                                .price = variants!
                                                .where((element) =>
                                            element
                                                .variantSku ==
                                                selectedVariants
                                                    .join(
                                                    '-'))
                                                .first
                                                .variantPrice ??
                                                '0';
                                            widget.productModel
                                                .disPrice = '0';

                                            Map<String, String>
                                            mapData = {};
                                            for (var element
                                            in attributes!) {
                                              mapData.addEntries([
                                                MapEntry(
                                                    attributesList
                                                        .where((element1) =>
                                                    element
                                                        .attributesId ==
                                                        element1
                                                            .id)
                                                        .toString(),
                                                    selectedVariants[
                                                    attributes!
                                                        .indexOf(
                                                        element)])
                                              ]);
                                              setState(() {});
                                            }

                                            variantInfo = VariantInfo(
                                                variantPrice: variants!
                                                    .where((element) =>
                                                element.variantSku ==
                                                    selectedVariants.join(
                                                        '-'))
                                                    .first
                                                    .variantPrice ??
                                                    '0',
                                                variantSku:
                                                selectedVariants
                                                    .join('-'),
                                                variantOptions:
                                                mapData,
                                                variantImage: variants!
                                                    .where((element) =>
                                                element.variantSku ==
                                                    selectedVariants
                                                        .join(
                                                        '-'))
                                                    .first
                                                    .variantImage ??
                                                    '',
                                                variantId: variants!
                                                    .where((element) => element.variantSku == selectedVariants.join('-'))
                                                    .first
                                                    .variantId ??
                                                    '0');

                                            widget.productModel
                                                .variantInfo =
                                                variantInfo;

                                            setState(() {
                                              productQnt = 1;
                                            });
                                            addtocard(
                                                widget.productModel,
                                                true);
                                          } else {
                                            ScaffoldMessenger
                                                .of(context)
                                                .showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.white,
                                                  content: Text(
                                                    "Food out of stock".tr,style: TextStyle(color: Colors.black),),
                                                ));
                                          }
                                        } else {
                                          if (widget.productModel
                                              .quantity >
                                              productQnt ||
                                              widget.productModel
                                                  .quantity ==
                                                  -1) {
                                            setState(() {
                                              productQnt = 1;
                                            });
                                            addtocard(
                                                widget.productModel,
                                                true);
                                          } else {
                                            ScaffoldMessenger
                                                .of(context)
                                                .showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.white,
                                                  content: Text(
                                                    "Food out of stock".tr,style: TextStyle(color: Colors.black),),
                                                ));
                                          }
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: Color(COLOR_PRIMARY),
                                      size: 18,
                                    ),
                                    label: Text(
                                      'ADD'.tr,
                                      style: TextStyle(
                                          fontFamily: "Poppinsm",
                                          color:
                                          Color(COLOR_PRIMARY)),
                                    ),
                                    style: TextButton.styleFrom(
                                      side: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 2),
                                    ),
                                  )
                                      : isOpen == false
                                      ? Container()
                                      : Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (productQnt != 0) {
                                                productQnt--;
                                              }
                                              if (productQnt >= 0) {
                                                removetocard(
                                                    widget
                                                        .productModel,
                                                    true);
                                              }
                                            });
                                          },
                                          icon: Image(
                                            image: const AssetImage(
                                                "assets/images/minus.png"),
                                            color:
                                            Color(COLOR_PRIMARY),
                                            height: 26,
                                          )),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        productQnt.toString(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: "Poppinsm",
                                            color:
                                            Color(COLOR_PRIMARY)),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (variants!
                                                  .where((element) =>
                                              element
                                                  .variantSku ==
                                                  selectedVariants
                                                      .join('-'))
                                                  .isNotEmpty) {
                                                if (int.parse(variants!
                                                    .where((element) =>
                                                element
                                                    .variantSku ==
                                                    selectedVariants.join(
                                                        '-'))
                                                    .first
                                                    .variantQuantity
                                                    .toString()) >
                                                    productQnt ||
                                                    int.parse(variants!
                                                        .where((element) =>
                                                    element
                                                        .variantSku ==
                                                        selectedVariants
                                                            .join('-'))
                                                        .first
                                                        .variantQuantity
                                                        .toString()) ==
                                                        -1) {
                                                  VariantInfo?
                                                  variantInfo =
                                                  VariantInfo();
                                                  Map<String, String>
                                                  mapData = {};
                                                  for (var element
                                                  in attributes!) {
                                                    mapData
                                                        .addEntries([
                                                      MapEntry(
                                                          attributesList
                                                              .where((element1) =>
                                                          element.attributesId ==
                                                              element1
                                                                  .id)
                                                              .toString(),
                                                          selectedVariants[
                                                          attributes!
                                                              .indexOf(element)])
                                                    ]);
                                                    setState(() {});
                                                  }

                                                  variantInfo = VariantInfo(
                                                      variantPrice: variants!
                                                          .where((element) =>
                                                      element.variantSku ==
                                                          selectedVariants.join(
                                                              '-'))
                                                          .first
                                                          .variantPrice ??
                                                          '0',
                                                      variantSku: selectedVariants
                                                          .join('-'),
                                                      variantOptions:
                                                      mapData,
                                                      variantImage: variants!
                                                          .where((element) =>
                                                      element.variantSku ==
                                                          selectedVariants.join(
                                                              '-'))
                                                          .first
                                                          .variantImage ??
                                                          '',
                                                      variantId: variants!
                                                          .where((element) => element.variantSku == selectedVariants.join('-'))
                                                          .first
                                                          .variantId ??
                                                          '0');

                                                  widget.productModel
                                                      .variantInfo =
                                                      variantInfo;
                                                  if (productQnt !=
                                                      0) {
                                                    productQnt++;
                                                  }
                                                  // widget.productModel.price = widget.productModel.disPrice == "" || widget.productModel.disPrice == "0" ? (widget.productModel.price) : (widget.productModel.disPrice!);
                                                  addtocard(
                                                      widget
                                                          .productModel,
                                                      true);
                                                } else {

                                                  ScaffoldMessenger
                                                      .of(context)
                                                      .showSnackBar(
                                                      SnackBar(
                                                        backgroundColor: Colors.white,
                                                        content: Text(
                                                          "Food out of stock".tr,style: TextStyle(color: Colors.black),),
                                                      ));
                                                }
                                              } else {
                                                if (widget.productModel
                                                    .quantity >
                                                    productQnt ||
                                                    widget.productModel
                                                        .quantity ==
                                                        -1) {
                                                  if (productQnt !=
                                                      0) {
                                                    productQnt++;
                                                  }
                                                  // widget.productModel.price = widget.productModel.disPrice == "" || widget.productModel.disPrice == "0" ? (widget.productModel.price) : (widget.productModel.disPrice!);
                                                  addtocard(
                                                      widget
                                                          .productModel,
                                                      true);
                                                } else {
                                                  ScaffoldMessenger
                                                      .of(context)
                                                      .showSnackBar(
                                                      SnackBar(
                                                        backgroundColor: Colors.white,
                                                        content: Text(
                                                          "Food out of stock".tr,style: TextStyle(color: Colors.black),),
                                                      ));
                                                }
                                              }
                                            });
                                          },
                                          icon: Image(
                                            image: const AssetImage(
                                                "assets/images/plus.png"),
                                            color:
                                            Color(COLOR_PRIMARY),
                                            height: 26,
                                          ))
                                    ],
                                  ),
                                ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Details".tr,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.productModel.description,
                          maxLines: 4,
                          style: TextStyle(
                              fontFamily: "Poppinsl",
                              color: isDarkMode()
                                  ? const Color(0xffC6C4C4)
                                  : const Color(0xff5E5C5C)),
                        ),
                      ],
                    ),
                  ),
                  attributes!.isEmpty
                      ? Container()
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        itemCount: attributes!.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          String title = "";
                          for (var element in attributesList) {
                            if (attributes![index].attributesId ==
                                element.id) {
                              title = element.title.toString();
                            }
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15),
                                child: Wrap(
                                  spacing: 9.0,
                                  runSpacing: 9.0,
                                  children: List.generate(
                                    attributes![index]
                                        .attributeOptions!
                                        .length,
                                        (i) {
                                      return InkWell(
                                          onTap: () async {
                                            setState(() {
                                              if (selectedIndexVariants
                                                  .where((element) =>
                                                  element.contains(
                                                      '$index _'))
                                                  .isEmpty) {
                                                selectedVariants.insert(
                                                    index,
                                                    attributes![index]
                                                        .attributeOptions![
                                                    i]
                                                        .toString());
                                                selectedIndexVariants.add(
                                                    '$index _${attributes![index].attributeOptions![i].toString()}');
                                                selectedIndexArray
                                                    .add('${index}_$i');
                                              } else {
                                                selectedIndexArray.remove(
                                                    '${index}_${attributes![index].attributeOptions?.indexOf(selectedIndexVariants.where((element) => element.contains('$index _')).first.replaceAll('$index _', ''))}');
                                                selectedVariants
                                                    .removeAt(index);
                                                selectedIndexVariants.remove(
                                                    selectedIndexVariants
                                                        .where((element) =>
                                                        element.contains(
                                                            '$index _'))
                                                        .first);
                                                selectedVariants.insert(
                                                    index,
                                                    attributes![index]
                                                        .attributeOptions![
                                                    i]
                                                        .toString());
                                                selectedIndexVariants.add(
                                                    '$index _${attributes![index].attributeOptions![i].toString()}');
                                                selectedIndexArray
                                                    .add('${index}_$i');
                                              }
                                            });

                                            await cartDatabase
                                                .allCartProducts
                                                .then((value) {
                                              final bool productIsInList =
                                              value.any((product) =>
                                              product.id ==
                                                  "${widget.productModel.id}~${variants!.where((element) => element.variantSku == selectedVariants.join('-')).isNotEmpty ? variants!.where((element) => element.variantSku == selectedVariants.join('-')).first.variantId.toString() : ""}");
                                              if (productIsInList) {
                                                CartProduct element = value
                                                    .firstWhere((product) =>
                                                product.id ==
                                                    "${widget.productModel.id}~${variants!.where((element) => element.variantSku == selectedVariants.join('-')).isNotEmpty ? variants!.where((element) => element.variantSku == selectedVariants.join('-')).first.variantId.toString() : ""}");

                                                setState(() {
                                                  productQnt =
                                                      element.quantity;
                                                });
                                              } else {
                                                setState(() {
                                                  productQnt = 0;
                                                });
                                              }
                                            });

                                            if (variants!
                                                .where((element) =>
                                            element.variantSku ==
                                                selectedVariants
                                                    .join('-'))
                                                .isNotEmpty) {
                                              widget.productModel
                                                  .price = variants!
                                                  .where((element) =>
                                              element
                                                  .variantSku ==
                                                  selectedVariants
                                                      .join('-'))
                                                  .first
                                                  .variantPrice ??
                                                  '0';
                                              widget.productModel
                                                  .disPrice = '0';
                                            }
                                          },
                                          child: _build(
                                              attributes![index]
                                                  .attributeOptions![i],
                                              Get.context!,
                                              widget.productModel,
                                              attributes![index]
                                                  .attributeOptions![i]
                                                  .toString(),
                                              i,
                                              selectedVariants.contains(
                                                  attributes![index]
                                                      .attributeOptions![
                                                  i]
                                                      .toString())
                                                  ? true
                                                  : false));
                                    },
                                  ).toList(),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  lstAddAddonsCustom.isEmpty
                      ? Container()
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "Add Ons (Optional)".tr,
                          style: TextStyle(
                              fontFamily: "Poppinsm",
                              fontSize: 16,
                              color: isDarkMode()
                                  ? const Color(0xffffffff)
                                  : const Color(0xff000000)),
                        ),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 15),
                        child: ListView.builder(
                            itemCount: lstAddAddonsCustom.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(
                                    top: 15, bottom: 15),
                                child: Row(
                                  children: [
                                    Text(
                                      lstAddAddonsCustom[index].name!,
                                      style: TextStyle(
                                          fontFamily: "Poppinsl",
                                          color: isDarkMode()
                                              ? const Color(0xffC6C4C4)
                                              : const Color(0xff5E5C5C)),
                                    ),
                                    const Expanded(child: SizedBox()),
                                    Text(
                                      symbol +
                                          double.parse(lstAddAddonsCustom[
                                          index]
                                              .price!)
                                              .toStringAsFixed(decimal),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Poppinsm",
                                          color: Color(COLOR_PRIMARY)),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          lstAddAddonsCustom[index]
                                              .isCheck =
                                          !lstAddAddonsCustom[index]
                                              .isCheck;
                                          if (variants!
                                              .where((element) =>
                                          element.variantSku ==
                                              selectedVariants
                                                  .join('-'))
                                              .isNotEmpty) {
                                            VariantInfo? variantInfo =
                                            VariantInfo();
                                            Map<String, String> mapData =
                                            {};
                                            for (var element
                                            in attributes!) {
                                              mapData.addEntries([
                                                MapEntry(
                                                    attributesList
                                                        .where((element1) =>
                                                    element
                                                        .attributesId ==
                                                        element1.id)
                                                        .toString(),
                                                    selectedVariants[
                                                    attributes!
                                                        .indexOf(
                                                        element)])
                                              ]);
                                              setState(() {});
                                            }

                                            variantInfo = VariantInfo(
                                                variantPrice: variants!
                                                    .where((element) =>
                                                element.variantSku ==
                                                    selectedVariants.join(
                                                        '-'))
                                                    .first
                                                    .variantPrice ??
                                                    '0',
                                                variantSku:
                                                selectedVariants
                                                    .join('-'),
                                                variantOptions: mapData,
                                                variantImage: variants!
                                                    .where((element) =>
                                                element.variantSku ==
                                                    selectedVariants
                                                        .join(
                                                        '-'))
                                                    .first
                                                    .variantImage ??
                                                    '',
                                                variantId: variants!
                                                    .where((element) => element.variantSku == selectedVariants.join('-'))
                                                    .first
                                                    .variantId ??
                                                    '0');

                                            widget.productModel
                                                .variantInfo =
                                                variantInfo;
                                          }

                                          if (lstAddAddonsCustom[index]
                                              .isCheck ==
                                              true) {
                                            AddAddonsDemo addAddonsDemo =
                                            AddAddonsDemo(
                                                name: widget
                                                    .productModel
                                                    .addOnsTitle[
                                                index],
                                                index: index,
                                                isCheck: true,
                                                categoryID: widget
                                                    .productModel.id,
                                                price:
                                                lstAddAddonsCustom[
                                                index]
                                                    .price);
                                            lstTemp.add(addAddonsDemo);
                                            saveAddOns(lstTemp);
                                            addtocard(widget.productModel,
                                                false);
                                          } else {
                                            var removeIndex = -1;
                                            for (int a = 0;
                                            a < lstTemp.length;
                                            a++) {
                                              if (lstTemp[a].index ==
                                                  index &&
                                                  lstTemp[a].categoryID ==
                                                      lstAddAddonsCustom[
                                                      index]
                                                          .categoryID) {
                                                removeIndex = a;
                                                break;
                                              }
                                            }
                                            lstTemp.removeAt(removeIndex);
                                            saveAddOns(lstTemp);
                                            //widget.productModel.price = widget.productModel.disPrice==""||widget.productModel.disPrice=="0"? (widget.productModel.price) :(widget.productModel.disPrice!);
                                            addtocard(widget.productModel,
                                                false);
                                          }
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Icon(
                                          !lstAddAddonsCustom[index]
                                              .isCheck
                                              ? Icons
                                              .check_box_outline_blank
                                              : Icons.check_box,
                                          color: isDarkMode()
                                              ? null
                                              : Colors.grey,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: widget.productModel.specification.isNotEmpty,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Specification".tr,
                            style: TextStyle(
                                fontFamily: "Poppinsm",
                                fontSize: 20,
                                color: isDarkMode()
                                    ? const Color(0xffffffff)
                                    : const Color(0xff000000)),
                          ),
                        ),
                        widget.productModel.specification.isNotEmpty
                            ? ListView.builder(
                          itemCount:
                          widget.productModel.specification.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Text(
                                      "${widget.productModel.specification.keys.elementAt(index)} : ",
                                      style: TextStyle(
                                          color: Colors.black
                                              .withOpacity(0.60),
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                          fontSize: 14)),
                                  Text(
                                      widget.productModel.specification
                                          .values
                                          .elementAt(index),
                                      style: TextStyle(
                                          color: Colors.black
                                              .withOpacity(0.90),
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                          fontSize: 14)),
                                ],
                              ),
                            );
                          },
                        )
                            : Container(),
                      ],
                    ),
                  ),
                  Visibility(
                      visible: storeProductList.isNotEmpty,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "More from the Restaurants".tr,
                                    style: TextStyle(
                                        fontFamily: "Poppinsm",
                                        fontSize: 16,
                                        color: isDarkMode()
                                            ? const Color(0xffffffff)
                                            : const Color(0xff000000)),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "See All".tr,
                                    style: TextStyle(
                                        fontFamily: "Poppinsm",
                                        fontSize: 16,
                                        color: isDarkMode()
                                            ? const Color(0xffffffff)
                                            : Color(COLOR_PRIMARY)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.28,
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: storeProductList.length > 6
                                      ? 6
                                      : storeProductList.length,
                                  itemBuilder: (context, index) {
                                    ProductModel productModel =
                                    storeProductList[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      child: GestureDetector(
                                        onTap: () async {
                                          VendorModel? vendorModel =
                                          await FireStoreUtils.getVendor(
                                              storeProductList[index]
                                                  .vendorID);
                                          if (vendorModel != null) {
                                            push(
                                              context,
                                              ProductDetailsScreen(
                                                vendorModel: vendorModel,
                                                productModel: productModel,
                                              ),
                                            );
                                          }
                                        },
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.38,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: isDarkMode()
                                                      ? const Color(
                                                      DarkContainerBorderColor)
                                                      : Colors.grey.shade100,
                                                  width: 1),
                                              color: isDarkMode()
                                                  ? const Color(
                                                  DarkContainerColor)
                                                  : Colors.white,
                                              boxShadow: [
                                                isDarkMode()
                                                    ? const BoxShadow()
                                                    : BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  blurRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                      child: CachedNetworkImage(
                                                        imageUrl: getImageVAlidUrl(
                                                            productModel.photo),
                                                        imageBuilder: (context,
                                                            imageProvider) =>
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(20),
                                                                image: DecorationImage(
                                                                    image:
                                                                    imageProvider,
                                                                    fit:
                                                                    BoxFit.contain),
                                                              ),
                                                            ),
                                                        placeholder: (context,
                                                            url) =>
                                                            Center(
                                                                child:
                                                                CircularProgressIndicator
                                                                    .adaptive(
                                                                  valueColor:
                                                                  AlwaysStoppedAnimation(
                                                                      Color(
                                                                          COLOR_PRIMARY)),
                                                                )),
                                                        errorWidget:
                                                            (context, url, error) =>
                                                            ClipRRect(
                                                              borderRadius:
                                                              BorderRadius.circular(
                                                                  20),
                                                              child: Image.network(
                                                                AppGlobal
                                                                    .placeHolderImage!,
                                                                width: MediaQuery.of(
                                                                    context)
                                                                    .size
                                                                    .width *
                                                                    0.75,
                                                                fit: BoxFit.fitHeight,
                                                              ),
                                                            ),
                                                        fit: BoxFit.contain,
                                                      )),
                                                  const SizedBox(height: 8),
                                                  Text(productModel.name,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        fontFamily: "Poppinsm",
                                                        letterSpacing: 0.5,
                                                        fontSize: 16,
                                                        fontWeight:
                                                        FontWeight.w600,
                                                      )),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  productModel.disPrice ==
                                                      "" ||
                                                      productModel
                                                          .disPrice ==
                                                          "0"
                                                      ? Text(
                                                    "$symbol${double.parse(productModel.price).toStringAsFixed(decimal)}",
                                                    style: TextStyle(
                                                        fontFamily:
                                                        "Poppinsm",
                                                        letterSpacing:
                                                        0.5,
                                                        color: Color(
                                                            COLOR_PRIMARY)),
                                                  )
                                                      : Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .spaceBetween,

                                                    children: [
                                                      Text(
                                                        "$symbol${double.parse(productModel.disPrice.toString()).toStringAsFixed(decimal)}",
                                                        style:
                                                        TextStyle(
                                                          fontFamily:
                                                          "Poppinsm",
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize:
                                                          14,
                                                          color: Color(
                                                              COLOR_PRIMARY),
                                                        ),
                                                      ),
                                                      Text(
                                                        '$symbol${double.parse(productModel.price).toStringAsFixed(decimal)}',
                                                        style: const TextStyle(
                                                            fontFamily:
                                                            "Poppinsm",
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontSize:
                                                            12,
                                                            color: Colors
                                                                .grey,
                                                            decoration:
                                                            TextDecoration
                                                                .lineThrough),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ))
                        ],
                      )),


                ],
              ),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: isOpen
          ?      StreamBuilder<List<CartProduct>>(
          stream: cartProvider.watchProducts,
          builder: (context, snapshot) {
            late List<CartProduct> cartProducts = [];

            cartProvider.allCartProducts.then((value) {
              cartProducts = value;
              priceTemp = 0;
              for (int i = 0; i < cartProducts.length; i++) {
                CartProduct e = cartProducts[i];
                if (e.extras_price != null &&
                    e.extras_price != "" &&
                    double.parse(e.extras_price!) != 0) {
                  priceTemp +=
                      double.parse(e.extras_price!) * e.quantity;
                }
                priceTemp += double.parse(e.price) * e.quantity;
              }
            });
            return Container(
              color: Color(COLOR_PRIMARY),
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 20, top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${"Item Total".tr} $symbol${priceTemp.toStringAsFixed(decimal)}",
                      style: const TextStyle(
                          fontFamily: "Poppinsm",
                          color: Colors.white,
                          fontSize: 18),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.off(() => const cartPage());
                    },
                    child: Text(
                      "VIEW CART".tr,
                      style: const TextStyle(
                          fontFamily: "Poppinsm",
                          color: Colors.white,
                          fontSize: 18),
                    ),
                  )
                ],
              ),
            );
          })
          : null,
    );
  }

  void clearAddOnData() {
    bool isAddOnApplied = false;
    double addOnVal = 0;

    for (int i = 0; i < lstTemp.length; i++) {
      if (lstTemp[i].categoryID == widget.productModel.id) {
        AddAddonsDemo addAddonsDemo = lstTemp[i];
        isAddOnApplied = true;
        addOnVal = addOnVal + double.parse(addAddonsDemo.price!);
      }
    }
    if (isAddOnApplied && addOnVal > 0 && productQnt > 0) {
      priceTemp -= (addOnVal * productQnt);
    }
  }

  @override
  Future<void> didChangeDependencies() async {
    cartDatabase = Provider.of<CartDatabase>(context, listen: true);
    print("dasdasd");
    map.clear();
    cartDatabase.allCartProducts.then((value) {
      final bool productIsInList = value.any((product) =>
      product.id ==
          "${widget.productModel.id}~${variants!.where((element) => element.variantSku == selectedVariants.join('-')).isNotEmpty ? variants!.where((element) => element.variantSku == selectedVariants.join('-')).first.variantId.toString() : ""}");
      if (productIsInList) {
        CartProduct element = value.firstWhere((product) =>
        product.id ==
            "${widget.productModel.id}~${variants!.where((element) => element.variantSku == selectedVariants.join('-')).isNotEmpty ? variants!.where((element) => element.variantSku == selectedVariants.join('-')).first.variantId.toString() : ""}");

        setState(() {
          productQnt = element.quantity;
        });
      } else {
        setState(() {
          productQnt = 0;
        });
      }
    });

    super.didChangeDependencies();
  }

  void getAddOnsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String musicsString = prefs.getString('musics_key') != null
        ? prefs.getString('musics_key')!
        : "";

    if (musicsString.isNotEmpty) {
      setState(() {
        lstTemp = AddAddonsDemo.decode(musicsString);
      });
    }

    if (productQnt > 0) {
      lastPrice = widget.productModel.disPrice == "" ||
          widget.productModel.disPrice == "0"
          ? double.parse(widget.productModel.price)
          : double.parse(widget.productModel.disPrice!) * productQnt;
    }

    if (lstTemp.isEmpty) {
      setState(() {
        if (widget.productModel.addOnsTitle.isNotEmpty) {
          for (int a = 0; a < widget.productModel.addOnsTitle.length; a++) {
            AddAddonsDemo addAddonsDemo = AddAddonsDemo(
                name: widget.productModel.addOnsTitle[a],
                index: a,
                isCheck: false,
                categoryID: widget.productModel.id,
                price: widget.productModel.addOnsPrice[a]);
            lstAddAddonsCustom.add(addAddonsDemo);
            //saveAddonData(lstAddAddonsCustom);
          }
        }
      });
    } else {
      var tempArray = [];

      for (int d = 0; d < lstTemp.length; d++) {
        if (lstTemp[d].categoryID == widget.productModel.id) {
          AddAddonsDemo addAddonsDemo = AddAddonsDemo(
              name: lstTemp[d].name,
              index: lstTemp[d].index,
              isCheck: true,
              categoryID: lstTemp[d].categoryID,
              price: lstTemp[d].price);
          tempArray.add(addAddonsDemo);
        }
      }
      for (int a = 0; a < widget.productModel.addOnsTitle.length; a++) {
        var isAddonSelected = false;

        for (int temp = 0; temp < tempArray.length; temp++) {
          if (tempArray[temp].name == widget.productModel.addOnsTitle[a]) {
            isAddonSelected = true;
          }
        }
        if (isAddonSelected) {
          AddAddonsDemo addAddonsDemo = AddAddonsDemo(
              name: widget.productModel.addOnsTitle[a],
              index: a,
              isCheck: true,
              categoryID: widget.productModel.id,
              price: widget.productModel.addOnsPrice[a]);
          lstAddAddonsCustom.add(addAddonsDemo);
        } else {
          AddAddonsDemo addAddonsDemo = AddAddonsDemo(
              name: widget.productModel.addOnsTitle[a],
              index: a,
              isCheck: false,
              categoryID: widget.productModel.id,
              price: widget.productModel.addOnsPrice[a]);
          lstAddAddonsCustom.add(addAddonsDemo);
        }
      }
    }
    updatePrice();
  }

  getData() async {
    if (widget.productModel.photos.isEmpty) {
      productImage.add(widget.productModel.photo);
    }
    for (var element in widget.productModel.photos) {
      productImage.add(element);
    }

    for (var element in variants!) {
      productImage.add(element.variantImage.toString());
    }
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? foodType = sp.getString("foodType") ?? "Delivery".tr;

    await FireStoreUtils.getStoreProduct(widget.productModel.vendorID.toString()).then((value) {
      if(foodType == "Delivery"){
        for (var element in value) {
          if (element.id != widget.productModel.id && element.takeaway == false) {
            storeProductList.add(element);
          }
        }
      }else{
        for (var element in value) {
          if (element.id != widget.productModel.id) {
            storeProductList.add(element);
          }
        }
      }
      setState(() {});
    });

    await FireStoreUtils.getProductListByCategoryId(
        widget.productModel.categoryID.toString())
        .then((value) {
      for (var element in value) {
        if (element.id != widget.productModel.id) {
          productList.add(element);
        }
      }
    });
  }

  Future<String> getItemCount(isSelected, attributesOptionIndex, index,
      ProductModel productModel) async {
    var Counter = 0;

    await cartDatabase.allCartProducts.then((value) {
      final bool productIsInList = value.any((product) =>
      product.id ==
          "${productModel.id}~${variants!.where((element) => element.variantSku == selectedVariants.join('-')).isNotEmpty ? variants!.where((element) => element.variantSku == selectedVariants.join('-')).first.variantId.toString() : ""}");
      if (productIsInList) {
        CartProduct element = value.firstWhere((product) =>
        product.id ==
            "${productModel.id}~${variants!.where((element) => element.variantSku == selectedVariants.join('-')).isNotEmpty ? variants!.where((element) => element.variantSku == selectedVariants.join('-')).first.variantId.toString() : ""}");

        if (index == attributesOptionIndex) {

        }
        if (isSelected) {
          map[index] = element.quantity;
        }
        Counter = element.quantity;
      } else {
        Counter = 0;
      }
    });

    return Counter.toString(); // Return the desired String value
  }

  Future<Map<String, dynamic>?> getMapFromSharedPrefs() async {
    // Get the JSON string from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(widget.productModel.id.toString());

    if (jsonString != null) {
      // Convert JSON to Map
      Map<String, dynamic> myMap = jsonDecode(jsonString);
      return myMap;
    } else {
      // If the data is not available, return null or handle the case accordingly
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    map = {};

    loadDataFromSharedPrefs();
    print("dasdasd1");
    print(map);

    // productQnt = widget.productModel.quantity;
    getData();
    getAddOnsData();
    statusCheck();

    if (widget.productModel.itemAttributes != null) {
      attributes = widget.productModel.itemAttributes!.attributes;
      variants = widget.productModel.itemAttributes!.variants;

      if (attributes!.isNotEmpty) {
        for (var element in attributes!) {
          if (element.attributeOptions!.isNotEmpty) {
            selectedVariants.add(attributes![attributes!.indexOf(element)]
                .attributeOptions![0]
                .toString());
            selectedIndexVariants.add(
                '${attributes!.indexOf(element)} _${attributes![0].attributeOptions![0].toString()}');
            selectedIndexArray.add('${attributes!.indexOf(element)}_0');
          }
        }
      }

      if (variants!
          .where((element) => element.variantSku == selectedVariants.join('-'))
          .isNotEmpty) {
        widget.productModel.price = variants!
            .where((element) =>
        element.variantSku == selectedVariants.join('-'))
            .first
            .variantPrice ??
            '0';
        widget.productModel.disPrice = '0';
      }
    }
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  void loadDataFromSharedPrefs() async {
    Map<String, dynamic>? data = await getMapFromSharedPrefs();
    if (data != null) {
      // Use the retrieved data
      // For example, update your widget state with the retrieved data
      setState(() {
        map = data;
      });
    } else {
      // Handle the case when there is no data in shared preferences
      // For example, initialize your widget state with default values
      setState(() {
        map = {};
        
      });
    }
    print("map");

    print(map);
  }

  removetocard(ProductModel productModel, bool isIncerementQuantity) async {
    double addOnVal = 0;
    for (int i = 0; i < lstTemp.length; i++) {
      AddAddonsDemo addAddonsDemo = lstTemp[i];
      addOnVal = addOnVal + double.parse(addAddonsDemo.price!);
    }
    List<CartProduct> cartProducts = await cartDatabase.allCartProducts;

    if (productQnt >= 1) {
      //setState(() async {

      var joinTitleString = "";
      String mainPrice = "";
      List<AddAddonsDemo> lstAddOns = [];
      List<String> lstAddOnsTemp = [];
      double extrasPrice = 0.0;

      SharedPreferences sp = await SharedPreferences.getInstance();
      String addOns =
      sp.getString("musics_key") != null ? sp.getString('musics_key')! : "";

      bool isAddSame = false;
      if (!isAddSame) {
        if (productModel.disPrice != null &&
            productModel.disPrice!.isNotEmpty &&
            double.parse(productModel.disPrice!) != 0) {
          mainPrice = productModel.disPrice!;
        } else {
          mainPrice = productModel.price;
        }
      }

      if (addOns.isNotEmpty) {
        lstAddOns = AddAddonsDemo.decode(addOns);
        for (int a = 0; a < lstAddOns.length; a++) {
          AddAddonsDemo newAddonsObject = lstAddOns[a];
          if (newAddonsObject.categoryID == widget.productModel.id) {
            if (newAddonsObject.isCheck == true) {
              lstAddOnsTemp.add(newAddonsObject.name!);
              extrasPrice += (double.parse(newAddonsObject.price!));
            }
          }
        }

        joinTitleString = lstAddOnsTemp.join(",");
      }

      final bool productIsInList = cartProducts.any((product) =>
      product.id ==
          "${productModel.id}~${variants!.where((element) => element.variantSku == selectedVariants.join('-')).isNotEmpty ? variants!.where((element) => element.variantSku == selectedVariants.join('-')).first.variantId.toString() : ""}");
      if (productIsInList) {
        CartProduct element = cartProducts.firstWhere((product) =>
        product.id ==
            "${productModel.id}~${variants!.where((element) => element.variantSku == selectedVariants.join('-')).isNotEmpty ? variants!.where((element) => element.variantSku == selectedVariants.join('-')).first.variantId.toString() : ""}");
        await cartDatabase.updateProduct(CartProduct(
            id: element.id,
            name: element.name,
            photo: element.photo,
            price: element.price,
            vendorID: element.vendorID,
            quantity:
            isIncerementQuantity ? element.quantity - 1 : element.quantity,
            category_id: element.category_id,
            extras_price: extrasPrice.toString(),
            extras: joinTitleString,
            discountPrice: element.discountPrice!));
      } else {
        await cartDatabase.updateProduct(CartProduct(
            id: "${productModel.id}~${variants!.where((element) => element.variantSku == selectedVariants.join('-')).isNotEmpty ? variants!.where((element) => element.variantSku == selectedVariants.join('-')).first.variantId.toString() : ""}",
            name: productModel.name,
            photo: productModel.photo,
            price: mainPrice,
            discountPrice: productModel.disPrice,
            vendorID: productModel.vendorID,
            quantity: productQnt,
            extras_price: extrasPrice.toString(),
            extras: joinTitleString,
            category_id: productModel.categoryID,
            variant_info: productModel.variantInfo));
      }
    } else {
      cartDatabase.removeProduct(
          "${productModel.id}~${variants!.where((element) => element.variantSku == selectedVariants.join('-')).isNotEmpty ? variants!.where((element) => element.variantSku == selectedVariants.join('-')).first.variantId.toString() : ""}");
      setState(() {
        productQnt = 0;
      });
    }
    updatePrice();
  }

  void saveAddOns(List<AddAddonsDemo> lstTempDemo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = AddAddonsDemo.encode(lstTempDemo);
    await prefs.setString('musics_key', encodedData);
  }

  Future<void> saveMapToSharedPrefs(Map<String, dynamic> dataMap) async {
    // Convert the Map to JSON string
    String jsonString = jsonEncode(dataMap);

    // Save the JSON string to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(widget.productModel.id.toString(), jsonString);
  }

  statusCheck() {
    final now = DateTime.now();
    var day = DateFormat('EEEE', 'en_US').format(now);
    var date = DateFormat('dd-MM-yyyy').format(now);
    for (var element in widget.vendorModel.workingHours) {
      if (day == element.day.toString()) {
        if (element.timeslot!.isNotEmpty) {
          for (var element in element.timeslot!) {
            var start =
            DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.from}");
            var end =
            DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.to}");
            if (isCurrentDateInRange(start, end)) {
              setState(() {
                isOpen = true;
              });
            }
          }
        }
      }
    }
  }

  void updatePrice() {
    double addOnVal = 0;
    for (int i = 0; i < lstTemp.length; i++) {
      AddAddonsDemo addAddonsDemo = lstTemp[i];
      if (addAddonsDemo.categoryID == widget.productModel.id) {
        addOnVal = addOnVal + double.parse(addAddonsDemo.price!);
      }
    }
    List<CartProduct> cartProducts = [];
    Future.delayed(const Duration(microseconds: 500), () {
      cartProducts.clear();

      cartDatabase.allCartProducts.then((value) {
        priceTemp = 0;
        cartProducts.addAll(value);
        for (int i = 0; i < cartProducts.length; i++) {
          CartProduct e = cartProducts[i];
          if (e.extras_price != null &&
              e.extras_price != "" &&
              double.parse(e.extras_price!) != 0) {
            priceTemp += double.parse(e.extras_price!) * e.quantity;
          }
          priceTemp += double.parse(e.price) * e.quantity;
        }
        setState(() {});
      });
    });
  }

// In the widget's build method or any other appropriate place:
  Widget _build(index, BuildContext context, productModel, String label,
      int attributesOptionIndex, bool isSelected) {
    var item = '';
    cartDatabase.allCartProducts.then((value) {
      try {
        CartProduct element = value.firstWhere((product) =>
        product.id ==
            productModel.id +
                "~" +
                (variants!
                    .where((element) =>
                element.variantSku == selectedVariants.join('-'))
                    .isNotEmpty
                    ? variants!
                    .where((element) =>
                element.variantSku == selectedVariants.join('-'))
                    .first
                    .variantId
                    .toString()
                    : ""));

        item = element.id;
        saveMapToSharedPrefs(map);
      } catch (e) {
        if (isSelected) {
          map[index] = 0;
          saveMapToSharedPrefs(map);
        }
      }
    });

    return FutureBuilder<String>(
      future:
      getItemCount(isSelected, attributesOptionIndex, index, productModel),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Stack(children: [
            Chip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              backgroundColor: isSelected ? Color(COLOR_PRIMARY) : Colors.white,
              elevation: 3.0,
              shadowColor: Colors.grey[60],
              padding: const EdgeInsets.all(8.0),
            ),
            Positioned(
                right: -3,
                top: -3,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(COLOR_PRIMARY) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    map[index] == null ? "0" : map[index].toString(),
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                )),
          ]);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // Show a loading indicator while waiting for the future to complete
        return const CircularProgressIndicator();
      },
    );
  }

// In the widget's build method or any other appropriate place:
}