import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:super_talab_user/app/data/model/ItemAttributes.dart';

import '../../data/model/AttributesModel.dart';
import '../../data/model/ProductModel.dart';
import '../../data/model/VendorCategoryModel.dart';
import '../../data/model/VendorModel.dart';
import '../../data/model/offer_model.dart';
import '../../data/provider/localDatabase.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../ProductDetailsScreen.dart';
import '../cart_module/cart_page.dart';
import '../shared/componants/fAppBar.dart';

/// GetX Template Generator - fb.com/htngu.99
///

// class vendorPage extends GetView<vendorController> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('vendor Page')),
//       body: Container(
//         child: Obx(()=>Container(child: Text(controller.obj),)),
//       ),
//     );
//   }
// }

class NewVendorProductsScreen extends StatefulWidget {
  final VendorModel vendorModel;
  final deliveryPrice;

  const NewVendorProductsScreen(
      {Key? key, required this.deliveryPrice, required this.vendorModel})
      : super(key: key);

  @override
  State<NewVendorProductsScreen> createState() =>
      _NewVendorProductsScreenState();
}

class _NewVendorProductsScreenState extends State<NewVendorProductsScreen>
    with SingleTickerProviderStateMixin {
  final FireStoreUtils fireStoreUtils = FireStoreUtils();

  final listViewKey = RectGetter.createGlobalKey();

  bool isCollapsed = false;

  late AutoScrollController scrollController;
  TabController? tabController;

  final double expandedHeight = 590.0;

  // final PageData data = ExampleData.data;
  final double collapsedHeight = kToolbarHeight;

  Map<int, dynamic> itemKeys = {};

  // prevent animate when press on tab bar
  bool pauseRectGetterIndex = false;
  bool vegSwitch = false;
  bool nonVegSwitch = false;

  CartDatabase cartDatabase = CartDatabase();
  late List<CartProduct> cartProducts = [];
  var  cartProvider = Provider.of<CartDatabase>(Get.context!);

  bool isOpen = false;

  var priceTemp = 0.0;

  String? foodType;

  List a = [];

  List<ProductModel> productModel = [];
  List<VendorCategoryModel> vendorCateoryModel = [];

  List<OfferModel> offerList = [];

  var isAnother = 0;
  bool veg = false;

  bool nonveg = false;

  void animateAndScrollTo(int index) {
    pauseRectGetterIndex = true;
    tabController!.animateTo(index);
    scrollController
        .scrollToIndex(index, preferPosition: AutoScrollPosition.begin)
        .then((value) => pauseRectGetterIndex = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode() ? Colors.black : Colors.white,
      extendBodyBehindAppBar: true,
      body: tabController == null
          ? const Center(child: CircularProgressIndicator())
          : RectGetter(
              key: listViewKey,
              child: NotificationListener<ScrollNotification>(
                onNotification: onScrollNotification,
                child: buildSliverScrollView(),
              ),
            ),
      bottomNavigationBar: isOpen
          ? Container(
              color: Color(COLOR_PRIMARY),
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 20, top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: StreamBuilder<List<CartProduct>>(
                        stream: cartProvider.watchProducts,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator(); // Display a loading indicator if data is still loading
                          }

                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          // Assuming snapshot.data is the List<CartProduct> from the stream
                          List<CartProduct> cartProducts = snapshot.data ?? [];

                          double priceTemp = 0;
                          for (int i = 0; i < cartProducts.length; i++) {
                            CartProduct e = cartProducts[i];
                            if (e.extras_price != null && e.extras_price != "" && double.parse(e.extras_price!) != 0) {
                              priceTemp += double.parse(e.extras_price!) * e.quantity;
                            }
                            priceTemp += double.parse(e.price) * e.quantity;
                          }

                          return Text(
                            "${"Item Total".tr} $symbol${priceTemp.toStringAsFixed(decimal)}",
                            style: const TextStyle(
                                fontFamily: "Poppinsm",
                                color: Colors.white,
                                fontSize: 18),
                          );
                        }
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
            )
          : null,
    );
  }

  SliverAppBar buildAppBar() {
    return FAppBar(
      vendorModel: widget.vendorModel,
      vendorCateoryModel: vendorCateoryModel,
      isOpen: isOpen,
      context: context,
      scrollController: scrollController,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      isCollapsed: isCollapsed,
      onCollapsed: onCollapsed,
      tabController: tabController!,
      offerList: offerList,
      onTap: (index) => animateAndScrollTo(index),
      deliveryPrice: widget.deliveryPrice,
    );
  }

  SliverList buildBody() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => buildCategoryItem(index),
        childCount: vendorCateoryModel.length,
      ),
    );
  }

  Widget buildCategoryItem(int index) {
    itemKeys[index] = RectGetter.createGlobalKey();
    VendorCategoryModel category = vendorCateoryModel[index];
    return RectGetter(
      key: itemKeys[index],
      child: AutoScrollTag(
        key: ValueKey(index),
        index: index,
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTileHeader(category),
            _buildFoodTileList(context, category),
          ],
        ),
      ),
    );
  }

  buildRow(ProductModel productModel, veg, nonveg, inx, bool index) {
    if (vegSwitch == true && productModel.veg == true) {
      isAnother++;
      return datarow(productModel);
    } else if (nonVegSwitch == true && productModel.veg == false) {
      isAnother++;
      return datarow(productModel);
    } else if (vegSwitch != true && nonVegSwitch != true) {
      isAnother++;
      return datarow(productModel);
    } else if (nonVegSwitch == true && productModel.nonveg == true) {
      isAnother++;
      return datarow(productModel);
    } else if (inx == productModel.categoryID) {
      return (isAnother == 0 && index)
          ? showEmptyState("No Food are available.", context)
          : Container();
    }
  }

  Widget buildSliverScrollView() {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        buildAppBar(),
        buildBody(),
      ],
    );
  }

  datarow(ProductModel productModel) {
    var price = double.parse(productModel.price);
    var productQnt = 0;
    List<Attributes>? attributes = [];
    List<Variants>? variants = [];
    List<AttributesModel> attributesList = [];

    List<String> selectedVariants = [];
    List<String> selectedIndexVariants = [];
    List<String> selectedIndexArray = [];
    if (productModel.itemAttributes != null) {
      attributes = productModel.itemAttributes!.attributes;
      variants = productModel.itemAttributes!.variants;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
                productModel: productModel, vendorModel: widget.vendorModel)));
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isDarkMode()
                  ? const Color(DarkContainerBorderColor)
                  : Colors.grey.shade100,
              width: 1),
          color: isDarkMode() ? const Color(DarkContainerColor) : Colors.white,
          boxShadow: [
            isDarkMode()
                ? const BoxShadow()
                : BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 5,
                  ),
          ],
        ),
        child: StreamBuilder<List<CartProduct>>(
          stream: cartProvider.watchProducts,
          initialData: const [], // Provide initial data if required
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final cartProducts = snapshot.data; // The list of cart products

              if (cartProducts != null && cartProducts.isNotEmpty) {
                // Your logic to find the matching cart product based on productModel.id + "~"
                // ...

                List count = [];
                print("object");
print( cartProducts.length);
                for (int i = 0; i < cartProducts.length; i++) {
                  count.add(0);
                  if (cartProducts[i].id == "${productModel.id}~") {
                    productQnt = cartProducts[i].quantity;

                    return Row(children: [
                      CachedNetworkImage(
                          height: 80,
                          width: 80,
                          imageUrl: getImageVAlidUrl(productModel.photo),
                          imageBuilder: (context, imageProvider) => Container(
                                // width: 100,
                                // height: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    )),
                              ),
                          errorWidget: (context, url, error) => ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                placeholderImage,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                              ))),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              productModel.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                  fontFamily: "Poppinssb",
                                  letterSpacing: 0.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            attributes!.isEmpty
                                ? Container()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListView.builder(
                                        itemCount: attributes.length,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          String title = "";
                                          for (var element in attributesList) {}
                                          return Wrap(
                                            runAlignment: WrapAlignment.center,
                                            spacing: 20.0,
                                            runSpacing: 0.0,
                                            children: List.generate(
                                              attributes![index]
                                                  .attributeOptions!
                                                  .length,
                                              (i) {
                                                if (attributes!.isNotEmpty) {
                                                  for (var element
                                                      in attributes) {
                                                    if (element
                                                        .attributeOptions!
                                                        .isNotEmpty) {
                                                      selectedVariants.add(
                                                          attributes[attributes
                                                                  .indexOf(
                                                                      element)]
                                                              .attributeOptions![
                                                                  0]
                                                              .toString());
                                                    }
                                                  }
                                                }

                                                return _build(
                                                  attributes[index]
                                                      .attributeOptions![i]
                                                      .toString(),
                                                );

                                                // attributes![index].attributeOptions![i].toString()
                                              },
                                            ).toList(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                            attributes.isEmpty
                                ? Row(
                                    children: <Widget>[
                                      productModel.disPrice == "" ||
                                              productModel.disPrice == "0"
                                          ? Text(
                                              symbol +
                                                  double.parse(
                                                          productModel.price)
                                                      .toStringAsFixed(decimal),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: "Poppinsm",
                                                  letterSpacing: 0.5,
                                                  color: Color(COLOR_PRIMARY)),
                                            )
                                          : Row(
                                              children: [
                                                Text(
                                                  "$symbol${double.parse(productModel.disPrice.toString()).toStringAsFixed(decimal)}",
                                                  style: TextStyle(
                                                    fontFamily: "Poppinsm",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(COLOR_PRIMARY),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  '$symbol${double.parse(productModel.price).toStringAsFixed(decimal)}',
                                                  style: const TextStyle(
                                                      fontFamily: "Poppinsm",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
                                                      decoration: TextDecoration
                                                          .lineThrough),
                                                ),
                                              ],
                                            ),
                                    ],
                                  )
                                : Container(),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: 75,
                        height: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1.5)),
                        child: Text(
                          productQnt.toString(),
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Poppinsm",
                              letterSpacing: 0.5,
                              color: Color(COLOR_PRIMARY)),
                        ),
                      ),
                    ]);
                  } else {
                    if (productModel.itemAttributes != null) {
                      for (int c = 0;
                          c < productModel.itemAttributes!.variants!.length;
                          c++) {
                        if (cartProducts[i].id ==
                            "${productModel.id}~${productModel.itemAttributes!.variants![c].variantId}") {
                          print("cartProducts[i].id ${cartProducts[i].id}");
                          print(
                              "productModel.id +$i");
                          count[i] = cartProducts[i].quantity;
                          productQnt = count.reduce((a, b) => a + b);
                        }
                      }
                    }
                  }
                }

                // Build the widget for the matching cart product
                return Row(children: [
                  CachedNetworkImage(
                      height: 80,
                      width: 80,
                      imageUrl: getImageVAlidUrl(productModel.photo),
                      imageBuilder: (context, imageProvider) => Container(
                            // width: 100,
                            // height: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                )),
                          ),
                      errorWidget: (context, url, error) => ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            placeholderImage,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          ))),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          productModel.name,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontFamily: "Poppinssb",
                              letterSpacing: 0.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        attributes!.isEmpty
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListView.builder(
                                    itemCount: attributes.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      String title = "";
                                      for (var element in attributesList) {}
                                      return Wrap(
                                        runAlignment: WrapAlignment.center,
                                        spacing: 20.0,
                                        runSpacing: 0.0,
                                        children: List.generate(
                                          attributes![index]
                                              .attributeOptions!
                                              .length,
                                          (i) {
                                            if (attributes!.isNotEmpty) {
                                              for (var element in attributes) {
                                                if (element.attributeOptions!
                                                    .isNotEmpty) {
                                                  selectedVariants.add(
                                                      attributes[attributes
                                                              .indexOf(element)]
                                                          .attributeOptions![0]
                                                          .toString());
                                                }
                                              }
                                            }

                                            return _build(
                                              attributes[index]
                                                  .attributeOptions![i]
                                                  .toString(),
                                            );

                                            // attributes![index].attributeOptions![i].toString()
                                          },
                                        ).toList(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                        attributes.isEmpty
                            ? Row(
                                children: <Widget>[
                                  productModel.disPrice == "" ||
                                          productModel.disPrice == "0"
                                      ? Text(
                                          symbol +
                                              double.parse(productModel.price)
                                                  .toStringAsFixed(decimal),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: "Poppinsm",
                                              letterSpacing: 0.5,
                                              color: Color(COLOR_PRIMARY)),
                                        )
                                      : Row(
                                          children: [
                                            Text(
                                              "$symbol${double.parse(productModel.disPrice.toString()).toStringAsFixed(decimal)}",
                                              style: TextStyle(
                                                fontFamily: "Poppinsm",
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(COLOR_PRIMARY),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              '$symbol${double.parse(productModel.price).toStringAsFixed(decimal)}',
                                              style: const TextStyle(
                                                  fontFamily: "Poppinsm",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                            ),
                                          ],
                                        ),
                                ],
                              )
                            : Container(),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                  productQnt == 0
                      ? TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ProductDetailsScreen(
                                    productModel: productModel,
                                    vendorModel: widget.vendorModel)));
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
                                color: Color(COLOR_PRIMARY)),
                          ),
                          style: TextButton.styleFrom(
                            side: BorderSide(
                                color: Colors.grey.shade300, width: 2),
                          ),
                        )
                      : Container(
                          alignment: Alignment.center,
                          width: 75,
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1.5)),
                          child: Text(
                            productQnt.toString(),
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Poppinsm",
                                letterSpacing: 0.5,
                                color: Color(COLOR_PRIMARY)),
                          ),
                        ),
                ]);
              } else {
                // Build the widget when no matching cart product is found
                return Row(children: [
                  CachedNetworkImage(
                      height: 80,
                      width: 80,
                      imageUrl: getImageVAlidUrl(productModel.photo),
                      imageBuilder: (context, imageProvider) => Container(
                            // width: 100,
                            // height: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                )),
                          ),
                      errorWidget: (context, url, error) => ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            placeholderImage,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          ))),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          productModel.name,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontFamily: "Poppinssb",
                              letterSpacing: 0.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        attributes!.isEmpty
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListView.builder(
                                    itemCount: attributes.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      String title = "";
                                      for (var element in attributesList) {}
                                      return Wrap(
                                        runAlignment: WrapAlignment.center,
                                        spacing: 20.0,
                                        runSpacing: 0.0,
                                        children: List.generate(
                                          attributes![index]
                                              .attributeOptions!
                                              .length,
                                          (i) {
                                            if (attributes!.isNotEmpty) {
                                              for (var element in attributes) {
                                                if (element.attributeOptions!
                                                    .isNotEmpty) {
                                                  selectedVariants.add(
                                                      attributes[attributes
                                                              .indexOf(element)]
                                                          .attributeOptions![0]
                                                          .toString());
                                                }
                                              }
                                            }

                                            return _build(
                                              attributes[index]
                                                  .attributeOptions![i]
                                                  .toString(),
                                            );

                                            // attributes![index].attributeOptions![i].toString()
                                          },
                                        ).toList(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                        attributes.isEmpty
                            ? Row(
                                children: <Widget>[
                                  productModel.disPrice == "" ||
                                          productModel.disPrice == "0"
                                      ? Text(
                                          symbol +
                                              double.parse(productModel.price)
                                                  .toStringAsFixed(decimal),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: "Poppinsm",
                                              letterSpacing: 0.5,
                                              color: Color(COLOR_PRIMARY)),
                                        )
                                      : Row(
                                          children: [
                                            Text(
                                              "$symbol${double.parse(productModel.disPrice.toString()).toStringAsFixed(decimal)}",
                                              style: TextStyle(
                                                fontFamily: "Poppinsm",
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(COLOR_PRIMARY),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              '$symbol${double.parse(productModel.price).toStringAsFixed(decimal)}',
                                              style: const TextStyle(
                                                  fontFamily: "Poppinsm",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                            ),
                                          ],
                                        ),
                                ],
                              )
                            : Container(),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(
                              productModel: productModel,
                              vendorModel: widget.vendorModel)));
                    },
                    icon: Icon(
                      Icons.add,
                      color: Color(COLOR_PRIMARY),
                      size: 18,
                    ),
                    label: Text(
                      'ADD'.tr,
                      style: TextStyle(
                          fontFamily: "Poppinsm", color: Color(COLOR_PRIMARY)),
                    ),
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300, width: 2),
                    ),
                  )
                ]);
              }
            }
          },
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {

    cartProvider = Provider.of<CartDatabase>(Get.context!);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  void getFoodType() async {
    await fireStoreUtils
        .getAllVendorProducts(widget.vendorModel.id)
        .then((value) {
      productModel.clear();
      productModel.addAll(value);
      getVendorCategoryById();
    });
  }

  getVendorCategoryById() async {
    vendorCateoryModel.clear();

    for (int i = 0; i < productModel.length; i++) {
      if (a.isNotEmpty && a.contains(productModel[i].categoryID)) {
      } else if (!a.contains(productModel[i].categoryID)) {
        a.add(productModel[i].categoryID);

        await fireStoreUtils
            .getVendorCategoryById(productModel[i].categoryID)
            .then((value) {
          if (value != null) {
            setState(() {
              vendorCateoryModel.add(value);
            });
          }
        });
      }
    }
    setState(() {
      tabController =
          TabController(length: vendorCateoryModel.length, vsync: this);
    });
    await FireStoreUtils()
        .getOfferByVendorID(widget.vendorModel.id)
        .then((value) {
      setState(() {
        offerList = value;
      });
    });
  }

  List<int> getVisibleItemsIndex() {
    Rect? rect = RectGetter.getRectFromKey(listViewKey);
    List<int> items = [];
    if (rect == null) return items;
    itemKeys.forEach((index, key) {
      Rect? itemRect = RectGetter.getRectFromKey(key);
      if (itemRect == null) return;
      if (itemRect.top > rect.bottom) return;
      if (itemRect.bottom < rect.top) return;
      items.add(index);
    });
    return items;
  }

  @override
  void initState() {
    getFoodType();
    statusCheck();
    scrollController = AutoScrollController();
    super.initState();
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  void onCollapsed(bool value) {
    if (isCollapsed == value) return;
    setState(() => isCollapsed = value);
  }

  bool onScrollNotification(ScrollNotification notification) {

    if (pauseRectGetterIndex) return true;
    int lastTabIndex = tabController!.length - 1;
    List<int> visibleItems = getVisibleItemsIndex();

    bool reachLastTabIndex = visibleItems.isNotEmpty &&
        visibleItems.length <= 2 &&
        visibleItems.last == lastTabIndex;
    if (reachLastTabIndex) {
      tabController!.animateTo(lastTabIndex);
    } else if (visibleItems.isNotEmpty) {
      int sumIndex = visibleItems.reduce((value, element) => value + element);
      int middleIndex = sumIndex ~/ visibleItems.length;
      if (tabController!.index != middleIndex) {
        tabController!.animateTo(middleIndex);
      }
    }
    return false;
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

  Widget _build(
    String label,
  ) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 3.0,
      shadowColor: Colors.grey[60],
      padding: const EdgeInsets.all(8.0),
    );
  }

  Widget _buildFoodTileList(
      BuildContext context, VendorCategoryModel category) {
    isAnother = 0;
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: productModel.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, inx) {
            return productModel[inx].categoryID == category.id
                ? buildRow(
                    productModel[inx],
                    veg,
                    nonveg,
                    productModel[inx].categoryID,
                    (inx == (productModel.length - 1)))
                : (isAnother == 0 && (inx == (productModel.length - 1)))
                    ? showEmptyState("No Item are available.".tr, context)
                    : Container();
          },
        ),
      ],
    );
  }

  Widget _buildSectionTileHeader(VendorCategoryModel category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          category.title.toString(),
          style: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
