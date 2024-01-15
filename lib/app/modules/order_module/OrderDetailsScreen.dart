// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart' as lottie;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/model/OrderModel.dart';
import '../../data/model/User.dart';
import '../../data/model/variant_info.dart';
import '../../data/provider/localDatabase.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../chat/chat_screen.dart';
import '../review/reviewScreen.dart';
import '../shared/AppGlobal.dart';

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

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel orderModel;

  const OrderDetailsScreen({Key? key, required this.orderModel})
      : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class slidercolor extends StatelessWidget {
  var color;

  slidercolor({
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.13,
      height: 3,
      color: color,
    );
  }
}

class SliderIcon extends StatelessWidget {
  IconData? icon;

  var color;

  SliderIcon({
    required this.icon,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late CartDatabase cartDatabase;

  FireStoreUtils fireStoreUtils = FireStoreUtils();

  int estimatedSecondsFromDriverToStore = 900;
  late String orderStatus;
  bool isTakeAway = false;
  late String storeName;
  late String phoneNumberStore;
  String currentEvent = '';
  int estimatedTime = 0;
  Timer? timerCountDown;
  double total = 0.0;
  var discount;
  GoogleMapController? _mapController;
  StreamController<String> arrivalTimeStreamController = StreamController();
  var tipAmount = "0.0";
  //latlng of the vendor
  LatLng? vendorLocation;

  //latlng of the user
  LatLng? userLocation;

  List<LatLng> polylineCoordinates = [];

  // Future<PolylineResult>? polyLinesFuture;
  late bool orderDelivered;

  late bool orderRejected;
  List<Polyline> polylines = [];

  List<Marker> mapMarkers = [];
  final bool _isOrderLate = false;

  int _remainingTimeInSeconds =
      0; // Initialize to 0, the timer will be set based on the createdAt time.

  late Timer _timer;
  List availableBluetoothDevices = [];
  // Widget buildOrderSummaryCard() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //     child: Card(
  //       color: isDarkMode() ? Colors.grey.shade900 : Colors.white,
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Order Summary'.tr,
  //               style: TextStyle(
  //                   fontWeight: FontWeight.w700,
  //                   fontSize: 20,
  //                   color: isDarkMode(context)
  //                       ? Colors.grey.shade200
  //                       : Colors.grey.shade700),
  //             ),
  //             SizedBox(height: 16),
  //             Text(
  //               '${widget.orderModel.vendor.title}',
  //               style: TextStyle(
  //                   fontWeight: FontWeight.w400,
  //                    fontSize: 16,
  //                   color: isDarkMode(context)
  //                       ? Colors.grey.shade200
  //                       : Colors.grey.shade700),
  //             ),
  //             SizedBox(height: 16),
  //             ListView.builder(
  //               physics: NeverScrollableScrollPhysics(),
  //               shrinkWrap: true,
  //               itemCount: widget.orderModel.products.length,
  //               itemBuilder: (context, index) => Padding(
  //                 padding: EdgeInsets.symmetric(vertical: 12),
  //                 child: Row(
  //                   children: [
  //                     Container(
  //                       color: isDarkMode(context)
  //                           ? Colors.grey.shade700
  //                           : Colors.grey.shade200,
  //                       padding: EdgeInsets.all(6),
  //                       child: Text(
  //                         '${widget.orderModel.products[index]['quantity']}',
  //                         style: TextStyle(
  //                             fontSize: 18, fontWeight: FontWeight.bold),
  //                       ),
  //                     ),
  //                     SizedBox(width: 16),
  //                     Text(
  //                       '${widget.orderModel.products[index]['name']}',
  //                       style: TextStyle(
  //                           color: isDarkMode(context)
  //                               ? Colors.grey.shade300
  //                               : Colors.grey.shade800,
  //                           fontWeight: FontWeight.w500,
  //                           fontSize: 18),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 16),
  //             ListTile(
  //               title: Text(
  //                 'Total'.tr,
  //                 style: TextStyle(
  //                   fontSize: 25,
  //                   fontWeight: FontWeight.w700,
  //                   color: isDarkMode(context)
  //                       ? Colors.grey.shade300
  //                       : Colors.grey.shade700,
  //                 ),
  //               ),
  //               trailing: Text(
  //                 '\$${total.toStringAsFixed(decimal)}',
  //                 style: TextStyle(
  //                   fontSize: 25,
  //                   fontWeight: FontWeight.w400,
  //                   color: isDarkMode(context)
  //                       ? Colors.grey.shade300
  //                       : Colors.grey.shade700,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  BitmapDescriptor? departureIcon;

  BitmapDescriptor? destinationIcon;

  BitmapDescriptor? taxiIcon;

  Map<PolylineId, Polyline> polyLines = {};

  final Map<String, Marker> _markers = {};

  late Stream<User> driverStream;

  User? _driverModel = User();

  late Stream<OrderModel?> ordersFuture;

  OrderModel? currentOrder;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            isDarkMode() ? const Color(DARK_BG_COLOR) : Colors.white,
        appBar: AppGlobal.buildSimpleAppBar(context, 'Your Order'.tr),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: fireStoreUtils.watchOrderStatus(widget.orderModel.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                OrderModel orderModel =
                    OrderModel.fromJson(snapshot.data!.data()!);
                orderStatus = orderModel.status;
                storeName = orderModel.vendor.title;
                phoneNumberStore = orderModel.vendor.phonenumber;

                switch (orderStatus) {
                  case ORDER_STATUS_PLACED:
                    currentEvent =
                        "${'Wesentyourorderto'.tr} (${orderModel.vendor.title})";
                    break;
                  case ORDER_STATUS_ACCEPTED:
                    currentEvent = 'preparingYourOrder'.tr;
                    break;
                  case ORDER_STATUS_REJECTED:
                    orderRejected = true;
                    break;
                  case ORDER_STATUS_DRIVER_PENDING:
                    currentEvent = 'Looking for a driver...'.tr;
                    break;
                  case ORDER_STATUS_DRIVER_REJECTED:
                    currentEvent = 'Looking for a driver...'.tr;
                    break;
                  case ORDER_STATUS_SHIPPED:
                    currentEvent = 'has picked up your order.'.tr;
                    break;
                  case ORDER_STATUS_IN_TRANSIT:
                    currentEvent = 'Your order is on the way'.tr;
                    break;
                  case ORDER_STATUS_COMPLETED:
                    orderDelivered = true;
                    timerCountDown?.cancel();
                    break;
                }
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 12),
                        child: Card(
                          color: isDarkMode()
                              ? const Color(DARK_BG_COLOR)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    StreamBuilder<String>(
                                        stream:
                                            arrivalTimeStreamController.stream,
                                        initialData: '',
                                        builder: (context, snapshot) {
                                          return Text(
                                            orderDelivered || orderRejected
                                                ? orderDelivered
                                                    ? 'Order Delivered'.tr
                                                    : 'Order Rejected'.tr
                                                : '${snapshot.data}',
                                            style: TextStyle(
                                                fontSize: 20,
                                                letterSpacing: 0.5,
                                                color: isDarkMode()
                                                    ? Colors.grey.shade200
                                                    : const Color(0XFF000000),
                                                fontFamily: "Poppinsb"),
                                          );
                                        }),
                                    // if (estimatedTime != 0 ||
                                    //     !orderDelivered ||
                                    //     !orderRejected)
                                    estimatedTime == 0 ||
                                            orderDelivered ||
                                            orderRejected
                                        ? Container()
                                        : Text(
                                            'Estimated Arrival'.tr,
                                            style: TextStyle(
                                                // fontSize: 20,
                                                letterSpacing: 0.5,
                                                color: isDarkMode()
                                                    ? Colors.grey.shade200
                                                    : const Color(0XFF000000),
                                                fontFamily: "Poppinsm"),
                                          )
                                  ],
                                ),

                                // estimatedTime == 0 || orderDelivered || orderRejected
                                estimatedTime == 0 ||
                                        orderDelivered ||
                                        orderRejected
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        child: LinearPercentIndicator(
                                          animation: true,
                                          lineHeight: 8.0,
                                          animationDuration:
                                              estimatedTime * 1000,
                                          percent: 1,
                                          linearStrokeCap:
                                              LinearStrokeCap.roundAll,
                                          progressColor: Colors.green,
                                        ),
                                      ),
                                if (!orderRejected && !orderDelivered)
                                  ListTile(
                                    title: Text(
                                      'ORDER ID'.tr,
                                      style: TextStyle(
                                        fontFamily: 'Poppinsm',
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                        color: isDarkMode()
                                            ? Colors.grey.shade300
                                            : const Color(0xff9091A4),
                                      ),
                                    ),
                                    trailing: Text(
                                      widget.orderModel.id,
                                      style: TextStyle(
                                        fontFamily: 'Poppinsm',
                                        letterSpacing: 0.5,
                                        fontSize: 16,
                                        color: isDarkMode()
                                            ? Colors.grey.shade300
                                            : const Color(0xff333333),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 0.0,
                                      left: 0.0,
                                      top: 6,
                                      bottom: 12),
                                  child: RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: currentEvent,
                                        style: TextStyle(
                                          letterSpacing: 0.5,
                                          color: isDarkMode()
                                              ? Colors.grey.shade200
                                              : const Color(0XFF2A2A2A),
                                          fontFamily: "Poppinsm",
                                          // fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !isTakeAway,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SliderIcon(
                                icon: Icons.check_circle,
                                color: orderStatus == ORDER_STATUS_ACCEPTED ||
                                        orderStatus ==
                                            ORDER_STATUS_DRIVER_PENDING ||
                                        orderStatus == ORDER_STATUS_SHIPPED ||
                                        orderStatus == ORDER_STATUS_IN_TRANSIT ||orderStatus == ORDER_STATUS_COMPLETED
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              slidercolor(
                                color: orderStatus ==
                                            ORDER_STATUS_DRIVER_PENDING ||
                                        orderStatus ==
                                            ORDER_STATUS_DRIVER_REJECTED ||
                                        orderStatus == ORDER_STATUS_SHIPPED ||
                                        orderStatus == ORDER_STATUS_IN_TRANSIT ||orderStatus == ORDER_STATUS_COMPLETED
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              SliderIcon(
                                icon: Icons.restaurant_menu,
                                color: orderStatus ==
                                            ORDER_STATUS_DRIVER_PENDING ||
                                        orderStatus ==
                                            ORDER_STATUS_DRIVER_REJECTED ||
                                        orderStatus == ORDER_STATUS_SHIPPED ||
                                        orderStatus == ORDER_STATUS_IN_TRANSIT ||orderStatus == ORDER_STATUS_COMPLETED
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              slidercolor(
                                color: orderStatus == ORDER_STATUS_SHIPPED ||
                                        orderStatus ==
                                            ORDER_STATUS_DRIVER_PENDING ||
                                        orderStatus ==
                                            ORDER_STATUS_DRIVER_REJECTED ||
                                    orderStatus == ORDER_STATUS_COMPLETED
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              SliderIcon(
                                icon: Icons.moped,
                                color: orderStatus == ORDER_STATUS_SHIPPED ||
                                        orderStatus == ORDER_STATUS_IN_TRANSIT ||orderStatus == ORDER_STATUS_COMPLETED
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              slidercolor(
                                color: orderStatus == ORDER_STATUS_COMPLETED
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              SliderIcon(
                                icon: Icons.home,
                                color: orderStatus == ORDER_STATUS_COMPLETED
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: ((orderStatus == ORDER_STATUS_PLACED ||
                                orderStatus == ORDER_STATUS_ACCEPTED ||
                                orderStatus == ORDER_STATUS_DRIVER_PENDING ||
                                orderStatus == ORDER_STATUS_DRIVER_REJECTED) &&
                            !isTakeAway),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 14),
                          child: lottie.Lottie.asset(
                            isDarkMode()
                                ? 'assets/images/chef_dark_bg.json'
                                : 'assets/images/chef_light_bg.json',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Visibility(
                          visible: (orderStatus == ORDER_STATUS_SHIPPED ||
                              orderStatus == ORDER_STATUS_IN_TRANSIT),
                          child: buildDriverCard(orderModel)),
                      const SizedBox(height: 16),
                      Visibility(
                        visible: orderStatus != 'order cancelled',
                        child: isOrderLate(widget.orderModel.createdAt)
                            ? Container()
                            : InkWell(
                          onTap: (){
                            Get.dialog(AlertDialog(
                              title: Text('Cancel Order'.tr),
                              content: Text(
                                  'Are you sure you want to cancel this order?'
                                      .tr),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text(
                                    'No'.tr,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Poppinsm',
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    fireStoreUtils
                                        .updateOrderStatus(
                                        widget.orderModel.id,
                                        "order cancelled");
                                    Get.back();
                                  },
                                  child: Text(
                                    'Yes'.tr,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontFamily: 'Poppinsm',
                                    ),
                                  ),
                                ),
                              ],
                            ));
                          },
                              child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.red,
                                    ),
                                    color: isDarkMode()
                                        ? const Color(DARK_BG_COLOR)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        ' ${_remainingTimeInSeconds ~/ 60}:${(_remainingTimeInSeconds % 60).toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.timer,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Get.dialog(AlertDialog(
                                            title: Text('Cancel Order'.tr),
                                            content: Text(
                                                'Are you sure you want to cancel this order?'
                                                    .tr),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Get.back();
                                                },
                                                child: Text(
                                                  'No'.tr,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontFamily: 'Poppinsm',
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  fireStoreUtils
                                                      .updateOrderStatus(
                                                          widget.orderModel.id,
                                                          "order cancelled");
                                                  Get.back();
                                                },
                                                child: Text(
                                                  'Yes'.tr,
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 16,
                                                    fontFamily: 'Poppinsm',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ));
                                        },
                                        child: Text(
                                          'Cancel Order'.tr,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 16,
                                            fontFamily: 'Poppinsm',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ),
                      ),
                      buildDeliveryDetailsCard(),
                      const SizedBox(height: 16),
                      buildOrderSummaryCard(orderModel),
                    ],
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                  ),
                );
              } else {
                return Center(
                  child: showEmptyState('Order Not Found'.tr, context),
                );
              }
            }),
      ),
    );
  }

  Widget buildDeliveryDetailsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        color: isDarkMode() ? const Color(DARK_BG_COLOR) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.orderModel.takeAway == false
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Details'.tr,
                          style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 0.5,
                              color: isDarkMode()
                                  ? Colors.grey.shade200
                                  : const Color(0XFF000000),
                              fontFamily: "Poppinsb"),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Address'.tr,
                          style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 0.5,
                              color: isDarkMode()
                                  ? Colors.grey.shade200
                                  : Color(COLOR_PRIMARY),
                              fontFamily: "Poppinsm"),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.orderModel.address.line1} ${widget.orderModel.address.line2}, ${widget.orderModel.address.city}, ${widget.orderModel.address.country}',
                          style: TextStyle(
                              fontFamily: "Poppinss",
                              fontSize: 18,
                              letterSpacing: 0.5,
                              color: isDarkMode()
                                  ? Colors.grey.shade200
                                  : Colors.grey.shade700),
                        ),
                        const Divider(height: 40),
                      ],
                    )
                  : Container(),
              Text(
                'Type'.tr,
                style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 0.5,
                    color: isDarkMode()
                        ? Colors.grey.shade200
                        : Color(COLOR_PRIMARY),
                    fontFamily: "Poppinsm"),
              ),
              const SizedBox(height: 8),
              widget.orderModel.takeAway == false
                  ? Text(
                      'Deliver to door'.tr,
                      style: TextStyle(
                          fontFamily: "Poppinss",
                          fontSize: 18,
                          letterSpacing: 0.5,
                          color: isDarkMode()
                              ? Colors.grey.shade200
                              : Colors.grey.shade700),
                    )
                  : Text(
                      'Takeaway'.tr,
                      style: TextStyle(
                          fontFamily: "Poppinss",
                          fontSize: 18,
                          letterSpacing: 0.5,
                          color: isDarkMode()
                              ? Colors.grey.shade200
                              : Colors.grey.shade700),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDriverCard(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        color: isDarkMode() ? const Color(DARK_BG_COLOR) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: order.driver?.firstName ?? 'Our driver'.tr,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDarkMode()
                                ? Colors.grey.shade200
                                : Colors.grey.shade600,
                            fontSize: 17)),
                    TextSpan(
                      text:
                          '\n${order.driver?.carNumber ?? 'No car number provided'.tr}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: isDarkMode()
                              ? Colors.grey.shade200
                              : Colors.grey.shade800),
                    ),
                  ]),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    displayCircleImage(
                        order.driver?.carPictureURL ??
                            'https://firebasestorage.googleapis.com/v0/b/gromart-5dd93.appspot.com/o/images%2Fcar_default_image.png?alt=media&token=503e1888-2231-4621-a2d0-51f9bb7e7208',
                        80,
                        true),
                    Positioned.directional(
                        textDirection: Directionality.of(context),
                        start: -65,
                        child: displayCircleImage(
                            order.author.profilePictureURL, 80, true))
                  ],
                ),
              ]),
              const SizedBox(height: 16),
              Text(
                order.driver?.phoneNumber ?? 'No phone number provided'.tr,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: isDarkMode()
                        ? Colors.grey.shade200
                        : Colors.grey.shade800),
              ),

              ListTile(
                leading: FloatingActionButton(
                  onPressed: order.driver == null
                      ? null
                      : () {
                          String url = 'tel:${order.driver!.phoneNumber}';
                          launch(url);
                        },
                  mini: true,
                  tooltip: 'Call {}'.tr,
                  backgroundColor:
                      // isDarkMode() ? Colors.grey.shade700 :
                      Colors.green,
                  elevation: 0,
                  child: const Icon(Icons.phone, color: Color(0xFFFFFFFF)),
                ),
                title: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode() ? Colors.grey.shade700 : Colors.grey.shade300,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(360),
                      ),
                    ),
                    child: Text(
                      'Send a message'.tr,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  onTap: order.driver == null
                      ? null
                      : () async {
                          Get.dialog(
                            Center(
                              child: const CircularProgressIndicator(),
                          ),);
                          User? customer = await FireStoreUtils.getCurrentUser(widget.orderModel.authorID);

                          User? driver = await FireStoreUtils.getCurrentUser(widget.orderModel.driverID.toString());

                          Get.back();
                          push(
                              context,
                              ChatScreens(
                                customerName: customer!.firstName + " " + customer.lastName,
                                restaurantName: order.driver!.firstName + " " + order.driver!.lastName,
                                orderId: widget.orderModel.id,
                                restaurantId: order.driver!.userID,
                                customerId: customer.userID,
                                customerProfileImage: customer.profilePictureURL,
                                restaurantProfileImage: order.driver!.profilePictureURL,
                                token: order.driver?.fcmToken,
                                chatType: 'Driver',
                              ));
                        },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOrderSummaryCard(OrderModel orderModel) {
    double tipValue = widget.orderModel.tipValue!.isEmpty
        ? 0.0
        : double.parse(widget.orderModel.tipValue!);
    double specialDiscountAmount = 0.0;
    if (widget.orderModel.specialDiscount!.isNotEmpty) {
      specialDiscountAmount = double.parse(
          widget.orderModel.specialDiscount!['special_discount'].toString());
    }

    var taxAmount = (widget.orderModel.taxModel == null)
        ? 0
        : getTaxValue(widget.orderModel.taxModel,
            total - discount - specialDiscountAmount);

    var totalamount = 0.0;

    if (widget.orderModel.deliveryCharge == null ||
        widget.orderModel.deliveryCharge!.isEmpty) {
      if (widget.orderModel.discount == null) {
        totalamount = total + taxAmount - specialDiscountAmount;
      } else {
        totalamount = total + taxAmount - discount - specialDiscountAmount;
      }
    } else {
      if (discount == null) {
        totalamount = total +
            taxAmount +
            double.parse(widget.orderModel.deliveryCharge!) +
            tipValue -
            specialDiscountAmount;
      } else {
        double.parse(widget.orderModel.deliveryCharge!);
        totalamount = total +
            taxAmount +
            double.parse(widget.orderModel.deliveryCharge!) +
            tipValue -
            discount -
            specialDiscountAmount;
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        color: isDarkMode() ? const Color(DARK_BG_COLOR) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 14, right: 14, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary'.tr,
                style: TextStyle(
                  fontFamily: 'Poppinsm',
                  fontSize: 18,
                  letterSpacing: 0.5,
                  color: isDarkMode() ? Colors.white : const Color(0XFF000000),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.orderModel.products.length,
                  itemBuilder: (context, index) {
                    VariantInfo? variantIno;
                    if (widget.orderModel.products[index]['variant_info'] !=
                        null) {
                      VariantInfo? variantIno = VariantInfo.fromMap(
                          widget.orderModel.products[index]['variant_info']);
                    }

                    List<dynamic>? addon =
                        widget.orderModel.products[index]['extras'];
                    String extrasDisVal = '';
                    for (int i = 0; i < addon!.length; i++) {
                      extrasDisVal +=
                          '${addon[i].toString().replaceAll("\"", "")} ${(i == addon.length - 1) ? "" : ","}';
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CachedNetworkImage(
                                height: 55,
                                width: 55,
                                // width: 50,
                                imageUrl: getImageVAlidUrl(
                                    widget.orderModel.products[index]['photo']),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          )),
                                    ),
                                errorWidget: (context, url, error) => ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      AppGlobal.placeHolderImage!,
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                    ))),
                            const SizedBox(height: 5),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Text(
                                        widget.orderModel.products[index]
                                            ['name'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontFamily: 'Poppinsr',
                                            fontSize: 18,
                                            letterSpacing: 0.5,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode()
                                                ? Colors.grey.shade200
                                                : const Color(0xff333333)),
                                      ),
                                    ),
                                    Text(
                                      ' x ${widget.orderModel.products[index]['quantity']}',
                                      style: TextStyle(
                                          fontFamily: 'Poppinsr',
                                          letterSpacing: 0.5,
                                          color: isDarkMode()
                                              ? Colors.grey.shade200
                                              : Colors.black.withOpacity(0.60)),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        variantIno == null || variantIno.variantOptions!.isEmpty
                            ? Container()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Wrap(
                                  spacing: 6.0,
                                  runSpacing: 6.0,
                                  children: List.generate(
                                    variantIno.variantOptions!.length,
                                    (i) {
                                      return _buildChip(
                                          "${variantIno.variantOptions!.keys.elementAt(i)} : ${variantIno.variantOptions![variantIno.variantOptions!.keys.elementAt(i)]}",
                                          i);
                                    },
                                  ).toList(),
                                ),
                              ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 10),
                          child: extrasDisVal.isEmpty
                              ? Container()
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    extrasDisVal,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontFamily: 'Poppinsr'),
                                  ),
                                ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Divider(
                            thickness: 1.5,
                            color:
                                isDarkMode() ? const Color(0Xff35363A) : null,
                          ),
                        ),
                      ],
                    );
                  }),
              Visibility(
                visible: widget.orderModel.status == ORDER_STATUS_COMPLETED,
                child: InkWell(
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              width: 0.8, color: const Color(0XFF82807F))),
                      child: Center(
                        child: Text(
                          'RATE Product'.tr,
                          style: const TextStyle(
                              color: Colors.red,
                              fontFamily: "Poppinsm",
                              fontSize: 15),
                        ),
                      )),
                  onTap: () {
                    push(
                        context,
                        ReviewScreen(
                          product: CartProduct.fromJson(widget
                              .orderModel.products[0] as Map<String, dynamic>),
                          orderId: widget.orderModel.id,
                        ));
                  },
                ),
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                title: Text(
                  'Subtotal'.tr,
                  style: TextStyle(
                    fontFamily: 'Poppinsm',
                    fontSize: 16,
                    letterSpacing: 0.5,
                    color: isDarkMode()
                        ? Colors.grey.shade300
                        : const Color(0xff9091A4),
                  ),
                ),
                trailing: Text(
                  symbol + widget.orderModel.subtotal!.toStringAsFixed(decimal),
                  style: TextStyle(
                    fontFamily: 'Poppinssm',
                    letterSpacing: 0.5,
                    fontSize: 16,
                    color: isDarkMode()
                        ? Colors.grey.shade300
                        : const Color(0xff333333),
                  ),
                ),
              ),
              Visibility(
                visible: orderModel.vendor.specialDiscountEnable,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  title: Text(
                    "${'Special Discount'.tr}(${widget.orderModel.specialDiscount!['special_discount_label']}${widget.orderModel.specialDiscount!['specialType'] == "amount" ? symbol : "%"})",
                    style: TextStyle(
                      fontFamily: 'Poppinsm',
                      fontSize: 16,
                      letterSpacing: 0.5,
                      color: isDarkMode()
                          ? Colors.grey.shade300
                          : const Color(0xff9091A4),
                    ),
                  ),
                  trailing: Text(
                    "$symbol${specialDiscountAmount.toStringAsFixed(decimal)}",
                    style: TextStyle(
                      fontFamily: 'Poppinsm',
                      letterSpacing: 0.5,
                      fontSize: 16,
                      color: isDarkMode()
                          ? Colors.grey.shade300
                          : const Color(0xff333333),
                    ),
                  ),
                ),
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                title: Text(
                  'Discount'.tr,
                  style: TextStyle(
                    fontFamily: 'Poppinsm',
                    fontSize: 16,
                    letterSpacing: 0.5,
                    color: isDarkMode()
                        ? Colors.grey.shade300
                        : const Color(0xff9091A4),
                  ),
                ),
                trailing: Text(
                  widget.orderModel.discount == null
                      ? "${symbol}0.0"
                      : symbol + widget.orderModel.discount.toString(),
                  style: TextStyle(
                    fontFamily: 'Poppinssm',
                    letterSpacing: 0.5,
                    fontSize: 16,
                    color: isDarkMode()
                        ? Colors.grey.shade300
                        : const Color(0xff333333),
                  ),
                ),
              ),
              widget.orderModel.takeAway == false
                  ? ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      title: Text(
                        'Delivery Charges'.tr,
                        style: TextStyle(
                          fontFamily: 'Poppinsm',
                          fontSize: 16,
                          letterSpacing: 0.5,
                          color: isDarkMode()
                              ? Colors.grey.shade300
                              : const Color(0xff9091A4),
                        ),
                      ),
                      trailing: Text(
                        widget.orderModel.deliveryCharge == null
                            ? "${symbol}0.0"
                            : symbol +
                                double.parse(widget.orderModel.deliveryCharge!)
                                    .toStringAsFixed(decimal),
                        style: TextStyle(
                          fontFamily: 'Poppinssm',
                          letterSpacing: 0.5,
                          fontSize: 16,
                          color: isDarkMode()
                              ? Colors.grey.shade300
                              : const Color(0xff333333),
                        ),
                      ),
                    )
                  : Container(),

              (widget.orderModel.taxModel != null && taxAmount > 0)
                  ? ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      title: Text(
                        widget.orderModel.taxModel!.label!,
                        style: TextStyle(
                          fontFamily: 'Poppinsm',
                          fontSize: 17,
                          letterSpacing: 0.5,
                          color: isDarkMode()
                              ? Colors.grey.shade300
                              : const Color(0xff9091A4),
                        ),
                      ),
                      trailing: Text(
                        symbol + taxAmount.toStringAsFixed(decimal),
                        style: TextStyle(
                          fontFamily: 'Poppinssm',
                          letterSpacing: 0.5,
                          fontSize: 17,
                          color: isDarkMode()
                              ? Colors.grey.shade300
                              : const Color(0xff333333),
                        ),
                      ),
                    )
                  : Container(),
              (widget.orderModel.notes != null &&
                      widget.orderModel.notes!.isNotEmpty)
                  ? ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      title: Text(
                        "Remarks".tr,
                        style: TextStyle(
                          fontFamily: 'Poppinsm',
                          fontSize: 17,
                          letterSpacing: 0.5,
                          color: isDarkMode()
                              ? Colors.grey.shade300
                              : const Color(0xff9091A4),
                        ),
                      ),
                      trailing: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              isScrollControlled: true,
                              isDismissible: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              enableDrag: true,
                              builder: (BuildContext context) =>
                                  viewNotesheet(widget.orderModel.notes!));
                        },
                        child: Text(
                          "View".tr,
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(COLOR_PRIMARY),
                              letterSpacing: 0.5,
                              fontFamily: 'Poppinsm'),
                        ),
                      ),
                    )
                  : Container(),
              widget.orderModel.couponCode!.trim().isNotEmpty
                  ? ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      title: Text(
                        'Coupon Code'.tr,
                        style: TextStyle(
                          fontFamily: 'Poppinsm',
                          fontSize: 16,
                          letterSpacing: 0.5,
                          color: isDarkMode()
                              ? Colors.grey.shade300
                              : const Color(0xff9091A4),
                        ),
                      ),
                      trailing: Text(
                        widget.orderModel.couponCode!,
                        style: TextStyle(
                          fontFamily: 'Poppinsm',
                          letterSpacing: 0.5,
                          fontSize: 16,
                          color: isDarkMode()
                              ? Colors.grey.shade300
                              : const Color(0xff333333),
                        ),
                      ),
                    )
                  : Container(),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                title: Text(
                  'Order Total'.tr,
                  style: TextStyle(
                    fontFamily: 'Poppinsm',
                    fontSize: 16,
                    letterSpacing: 0.5,
                    color: isDarkMode()
                        ? Colors.grey.shade300
                        : const Color(0xff333333),
                  ),
                ),
                trailing: Text(
                  symbol + widget.orderModel.total!.toStringAsFixed(decimal),
                  style: TextStyle(
                    fontFamily: 'Poppinssm',
                    letterSpacing: 0.5,
                    fontSize: 16,
                    color: isDarkMode()
                        ? Colors.grey.shade300
                        : const Color(0xff333333),
                  ),
                ),
              ),
              //   Visibility(
              //     visible: orderModel.status == ORDER_STATUS_ACCEPTED ||
              //         orderModel.status == ORDER_STATUS_SHIPPED ||
              //         orderModel.status == ORDER_STATUS_DRIVER_PENDING ||
              //         orderModel.status == ORDER_STATUS_DRIVER_REJECTED ||
              //         orderModel.status == ORDER_STATUS_SHIPPED ||
              //         orderModel.status == ORDER_STATUS_IN_TRANSIT,
              //     child: Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              //       child: InkWell(
              //         child: Container(
              //             padding: const EdgeInsets.only(top: 8, bottom: 8),
              //             decoration: BoxDecoration(color: Color(COLOR_PRIMARY), borderRadius: BorderRadius.circular(5), border: Border.all(width: 0.8, color: Color(COLOR_PRIMARY))),
              //             child: Center(
              //               child: Text(
              //                 'Send Message to Restaurant'.tr,
              //                 style: TextStyle(color: isDarkMode() ? const Color(0xffFFFFFF) : Colors.white, fontFamily: "Poppinsm", fontSize: 15
              //                     // fontWeight: FontWeight.bold,
              //                     ),
              //               ),
              //             )),
              //         onTap: () async {
              // Get.dialog(
              //   Center(
              //     child: CircularProgressIndicator(
              //       valueColor: AlwaysStoppedAnimation<Color>(Color(COLOR_PRIMARY)),
              //     ),
              //   ),
              // );
              //           User? customer = await FireStoreUtils.getCurrentUser(widget.orderModel.authorID);
              //           User? restaurantUser = await FireStoreUtils.getCurrentUser(widget.orderModel.vendor.author);
              //           VendorModel? vendorModel = await FireStoreUtils.getVendor(restaurantUser!.vendorID.toString());
              //
              //           hideProgress();
              //           push(
              //               context,
              //               ChatScreens(
              //                 customerName: '${customer!.firstName + " " + customer.lastName}',
              //                 restaurantName: vendorModel!.title,
              //                 orderId: widget.orderModel.id,
              //                 restaurantId: restaurantUser.userID,
              //                 customerId: customer.userID,
              //                 customerProfileImage: customer.profilePictureURL,
              //                 restaurantProfileImage: vendorModel.photo,
              //                 token: restaurantUser.fcmToken,
              //                 chatType: 'Restaurant',
              //               ));
              //           // FirebaseFirestore.instance.collection(USERS).doc(widget.orderModel.vendor.author).get().then((user) async {
              //           //   try {
              //           //     User userModel = User.fromJson(user.data() ?? {});
              //           //
              //           //
              //           //
              //           //
              //           //     String channelID;
              //           //     if (userModel.userID.compareTo(widget.orderModel.author.userID) < 0) {
              //           //       channelID = userModel.userID + widget.orderModel.author.userID;
              //           //     } else {
              //           //       channelID = widget.orderModel.author.userID + userModel.userID;
              //           //     }
              //           //
              //           //     ConversationModel? conversationModel = await fireStoreUtils.getChannelByIdOrNull(channelID);
              //           //     push(
              //           //       context,
              //           //       ChatScreen(
              //           //         homeConversationModel: HomeConversationModel(members: [userModel], conversationModel: conversationModel),
              //           //       ),
              //           //     );
              //           //   } catch (e) {
              //           //
              //           //   }
              //           // });
              //         },
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    cartDatabase = Provider.of<CartDatabase>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    timerCountDown?.cancel();
    arrivalTimeStreamController.close();
    _timer.cancel();

    super.dispose();
  }

  estimateTime() async {
    double originLat, originLong, destLat, destLong;
    originLat = widget.orderModel.vendor.latitude;
    originLong = widget.orderModel.vendor.longitude;
    destLat = widget.orderModel.author.location.latitude;
    destLong = widget.orderModel.author.location.longitude;

    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
    http.Response storeToCustomerTime =
        await http.get(Uri.parse('$url?units=metric&origins=$originLat,'
            '$originLong&destinations=$destLat,$destLong&key=$GOOGLE_API_KEY'));

    var decodedResponse = jsonDecode(storeToCustomerTime.body);
    if (decodedResponse['status'] == 'OK' &&
        decodedResponse['rows'].first['elements'].first['status'] == 'OK') {
      int secondsFromStoreToClient =
          decodedResponse['rows'].first['elements'].first['duration']['value'];
      if (orderStatus == ORDER_STATUS_SHIPPED) {
        http.Response driverToStoreTime = await http.get(Uri.parse(
            '$url?units=metric&origins=$originLat,'
            '$originLong&destinations=$destLat,$destLong&key=$GOOGLE_API_KEY'));
        var decodedDriverToStoreTimeResponse =
            jsonDecode(driverToStoreTime.body);
        if (decodedDriverToStoreTimeResponse['status'] == 'OK' &&
            decodedDriverToStoreTimeResponse['rows']
                    .first['elements']
                    .first['status'] ==
                'OK') {
          int secondsFromDriverToStore =
              decodedDriverToStoreTimeResponse['rows']
                  .first['elements']
                  .first['duration']['value'];
          estimatedTime = secondsFromStoreToClient + secondsFromDriverToStore;
        } else {
          estimatedTime =
              secondsFromStoreToClient + estimatedSecondsFromDriverToStore;
        }
      } else if (orderStatus == ORDER_STATUS_IN_TRANSIT) {
        estimatedTime = secondsFromStoreToClient;
      } else {
        estimatedTime =
            secondsFromStoreToClient + estimatedSecondsFromDriverToStore;
      }
      setState(() {});
      timerCountDown = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          if (estimatedTime == 0) {
            arrivalTimeStreamController.sink.add('');
            timer.cancel();
            setState(() {});
          } else {
            estimatedTime--;
            arrivalTimeStreamController.sink.add(
              _formatArrivalTimeDuration(
                Duration(seconds: estimatedTime),
              ),
            );
          }
        },
      );
    }
  }

  getCurrentOrder() async {
    ordersFuture = FireStoreUtils().getOrderByID(widget.orderModel.id);
    ordersFuture.listen((event) {
      setState(() {
        currentOrder = event;
        if (event!.driverID != null) {
          getDriver();
        }
      });
    });
  }

  getDriver() async {
    driverStream =
        FireStoreUtils().getDriver(currentOrder!.driverID.toString());
    driverStream.listen((event) {
      _driverModel = event;
      setState(() {});
    });
  }

  @override
  void initState() {
    setMarkerIcon();
    _startTimerFromCreatedAt();
    getCurrentOrder();
    orderStatus = widget.orderModel.status;
    isTakeAway = widget.orderModel.takeAway!;
    orderRejected = orderStatus == ORDER_STATUS_REJECTED;
    orderDelivered = orderStatus == ORDER_STATUS_COMPLETED;
    if (!orderDelivered && !orderRejected) {
      vendorLocation = LatLng(widget.orderModel.vendor.latitude,
          widget.orderModel.vendor.longitude);
      userLocation = LatLng(widget.orderModel.author.location.latitude,
          widget.orderModel.author.location.longitude);
      estimateTime();
    }

    for (var element in widget.orderModel.products) {
      if (element['extras_price'] != null &&
          element['extras_price']!.isNotEmpty &&
          double.parse(element['extras_price']!) != 0.0) {
        total += element['quantity'] * double.parse(element['extras_price']!);
      }

      var price = (element['extras_price'] == null ||
              element['extras_price'] == "" ||
              element['extras_price'] == "0.0")
          ? ((element['discountPrice'] == "" ||
                  element['discountPrice'] == "0" ||
                  element['discountPrice'] == null)
              ? element['price']
              : element['discountPrice'])
          : element['extras_price'];
      total += element['quantity'] * double.parse(price!);

      discount = widget.orderModel.discount;
    }
    widget.orderModel.deliverycharge = 5;
    super.initState();
  }

  bool isOrderLate(Timestamp createdAt) {
    // Get the current time as a timestamp
    Timestamp currentTime = Timestamp.now();

    // Calculate the time difference in seconds
    int differenceInSeconds =
        currentTime.millisecondsSinceEpoch - createdAt.millisecondsSinceEpoch;

    // Check if the order is more than 3 minutes late
    return differenceInSeconds > (3 * 60 * 1000); // 3 minutes in milliseconds
  }

  void setMarkerIcon() async {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/images/pickup.png")
        .then((value) {
      departureIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/images/dropoff.png")
        .then((value) {
      destinationIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(
              size: Size(10, 10),
            ),
            "assets/images/ic_taxi.png")
        .then((value) {
      taxiIcon = value;
    });
  }

  viewNotesheet(String notes) {
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height / 4.3,
          left: 25,
          right: 25),
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(style: BorderStyle.none)),
      child: Column(
        children: [
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
                color: isDarkMode() ? const Color(0XFF2A2A2A) : Colors.white),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Remark'.tr,
                        style: TextStyle(
                            fontFamily: 'Poppinssb',
                            color: isDarkMode() ? Colors.white70 : Colors.black,
                            fontSize: 16),
                      )),
                  Container(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 20),
                    // height: 120,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 20),
                        color: isDarkMode()
                            ? const Color(DARK_BG_COLOR)
                            : const Color(0XFFF1F4F7),
                        // height: 120,
                        alignment: Alignment.center,
                        child: Text(
                          notes,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDarkMode() ? Colors.white70 : Colors.black,
                            fontFamily: 'Poppinsm',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  String _formatArrivalTimeDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String formattedTime =
        '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds'
            .replaceAll('00:', '');
    return formattedTime.length == 2 ? '$formattedTime Seconds' : formattedTime;
  }

  void _startTimerFromCreatedAt() {
    // Calculate the remaining time in seconds based on the difference between current time and createdAt time
    Timestamp currentTime = Timestamp.now();
    int differenceInSeconds = (currentTime.millisecondsSinceEpoch -
            widget.orderModel.createdAt.millisecondsSinceEpoch) ~/
        1000;

    // Calculate the remaining time based on 3 minutes (180 seconds) and the time already passed.
    _remainingTimeInSeconds = 180 - differenceInSeconds;

    // Start the timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTimeInSeconds > 0) {
          _remainingTimeInSeconds--;
        } else {
          _timer.cancel(); // Stop the timer when it reaches 0.
        }
      });
    });
  }
}
