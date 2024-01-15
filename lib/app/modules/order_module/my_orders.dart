// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../data/model/OrderModel.dart';
import '../../data/provider/localDatabase.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../shared/AppGlobal.dart';
import 'OrderDetailsScreen.dart';

// ignore_for_file: must_be_immutable

class OrdersScreen extends StatefulWidget {
  bool? isAnimation = true;

  OrdersScreen({super.key, this.isAnimation});
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Stream<List<OrderModel>> ordersFuture;
  final FireStoreUtils _fireStoreUtils = FireStoreUtils();
  List<OrderModel> ordersList = [];
  late CartDatabase cartDatabase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppGlobal.buildSimpleAppBar(Get.context!, "Your orders".tr),
      backgroundColor:
          isDarkMode() ? const Color(DARK_COLOR) : const Color(0xffFFFFFF),
      body: widget.isAnimation == true
          ? Center(
              child: Image.asset(
                'assets/order_place_gif.gif',
              ),
            )
          : StreamBuilder<List<OrderModel>>(
              stream: ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor:
                            AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                  return Center(
                    child: showEmptyState('No Previous Orders'.tr, context,
                        description: "orders-food".tr),
                  );
                } else {
                  // ordersList = snapshot.data!;
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (context, index) =>
                          buildOrderItem(snapshot.data![index]));
                }
              }),
    );
  }

  Widget buildOrderItem(OrderModel orderModel) {
    double total = 0.0;
    for (var element in orderModel.products) {
      try {
        if (element.extras_price!.isNotEmpty &&
            double.parse(element.extras_price!) != 0.0) {
          total += element.quantity * double.parse(element.extras_price!);
        }
        total += element.quantity * double.parse(element.price);
      } catch (ex) {}
    }
    total = total - orderModel.discount!;

    return Card(
        color: isDarkMode()
            ? const Color(DARK_CARD_BG_COLOR)
            : const Color(0xffFFFFFF),
        margin: const EdgeInsets.only(bottom: 30, right: 5, left: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 5, bottom: 15, right: 10, left: 10),
          child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => push(
                  context,
                  OrderDetailsScreen(
                    orderModel: orderModel,
                  )),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(
                            (orderModel.products.first['photo'].isNotEmpty)
                                ? orderModel.products.first['photo']
                                : placeholderImage),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.5), BlendMode.darken),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orderModel.products.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Text(
                              orderModel.products[index]['name'],
                              style: TextStyle(
                                  fontSize: 18,
                                  color: isDarkMode()
                                      ? Colors.grey.shade200
                                      : const Color(0XFF000000),
                                  fontFamily: "Poppinsm"),
                            );
                          }),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,

                              child: Text(orderModel.status.tr,
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis, // Choose appropriate overflow behavior
                                      color: isDarkMode()
                                          ? Colors.grey.shade200
                                          : const Color(0XFF555353),
                                      fontFamily: "Poppinsr")),
                            ),
                            const SizedBox(width: 3),
                            const Image(
                              image:
                                  AssetImage("assets/images/verti_divider.png"),
                              height: 10,
                              width: 10,
                              color: Color(0XFF555353),
                            ),
                            Text(orderDate(orderModel.createdAt),
                                style: TextStyle(
                                    color: isDarkMode()
                                        ? Colors.grey.shade200
                                        : const Color(0XFF555353),
                                    fontFamily: "Poppinsr")),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text("Total ${orderModel.total.toString()}".tr,
                          style: TextStyle(
                              color: isDarkMode()
                                  ? Colors.grey.shade200
                                  : const Color(0XFF555353),
                              fontFamily: "Poppinsr")),
                    ],
                  )),
                ],
              )),
        ));
  }

  @override
  void didChangeDependencies() {
    cartDatabase = Provider.of<CartDatabase>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    FireStoreUtils().closeOrdersStream();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ordersFuture = _fireStoreUtils.getOrders(MyApp.currentUser!.userID);

    Future.delayed(const Duration(seconds: 7), () {
      widget.isAnimation = false;
    });
  }
}
