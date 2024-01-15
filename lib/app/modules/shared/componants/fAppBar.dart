import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../../main.dart';
import '../../../data/model/VendorCategoryModel.dart';
import '../../../data/model/VendorModel.dart';
import '../../../data/model/WorkingHoursModel.dart';
import '../../../data/model/offer_model.dart';
import '../../../data/services/helper.dart';
import '../../../utils/constants.dart';
import 'FIconButton.dart';
import 'helper.dart';

class FAppBar extends SliverAppBar {
  final deliveryPrice;

  final VendorModel vendorModel;
  final List<VendorCategoryModel> vendorCateoryModel;
  final List<OfferModel> offerList;
  final BuildContext context;
  final bool isOpen;
  final bool isCollapsed;
  @override
  final double expandedHeight;
  @override
  final double collapsedHeight;
  final AutoScrollController scrollController;
  final TabController tabController;
  final void Function(bool isCollapsed) onCollapsed;
  final void Function(int index) onTap;

  const FAppBar({
    super.key,
    required this.deliveryPrice,
    required this.vendorModel,
    required this.vendorCateoryModel,
    required this.offerList,
    required this.context,
    required this.isOpen,
    required this.isCollapsed,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.scrollController,
    required this.onCollapsed,
    required this.onTap,
    required this.tabController,
  }) : super(elevation: 4.0, pinned: true, forceElevated: true);

  @override
  Color? get backgroundColor => isDarkMode() ? Colors.black : Colors.white;

  @override
  PreferredSizeWidget? get bottom {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Container(
        color: isDarkMode() ? const Color(DarkContainerColor) : Colors.white,
        alignment: Alignment.centerLeft,
        child: TabBar(
          isScrollable: true,
          controller: tabController,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 12.0),
          indicatorColor: Color(COLOR_PRIMARY),
          labelColor: Color(COLOR_PRIMARY),
          unselectedLabelColor:
              isDarkMode() ? Colors.white : Colors.black.withOpacity(0.60),
          indicatorWeight: 3.0,
          tabs: vendorCateoryModel.map((e) {
            return Tab(text: e.title);
          }).toList(),
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget? get flexibleSpace {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final top = constraints.constrainHeight();
        final collapsedHight =
            MediaQuery.of(context).viewPadding.top + kToolbarHeight + 48;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          onCollapsed(collapsedHight != top);
        });
        var width = MediaQuery.of(context).size.width;
        var height = MediaQuery.of(context).size.height;

        double distanceInMeters = Geolocator.distanceBetween(
            vendorModel.latitude,
            vendorModel.longitude,
            MyApp.selectedPosotion.latitude,
            MyApp.selectedPosotion.longitude);
        double kilometer = distanceInMeters / 1000;

        double minutes = 1.2;
        double value = minutes * kilometer;
        final int hour = value ~/ 60;

        return FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: height * 0.30,
                    decoration: const BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.white38,
                            blurRadius: 25.0,
                            offset: Offset(0.0, 0.75))
                      ],
                    ),
                    width: width * 1,
                    child: CachedNetworkImage(
                      imageUrl: getImageVAlidUrl(vendorModel.photo),
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator.adaptive(
                        valueColor:
                            AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                      )),
                      errorWidget: (context, url, error) => Image.network(
                        placeholderImage,
                        fit: BoxFit.fitWidth,
                      ),
                      fit: BoxFit.fitWidth,
                    )),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          constraints: const BoxConstraints(maxWidth: 250),
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 15),
                          child: Text(vendorModel.title,
                              maxLines: 2,
                              style: TextStyle(
                                  fontFamily: "Poppinsm",
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                  color: isDarkMode()
                                      ? const Color(0xffFFFFFF)
                                      : const Color(0xff2A2A2A)))),
                      resttiming()
                    ]),
                const SizedBox(
                  height: 10,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(children: [
                            const ImageIcon(
                              AssetImage('assets/images/location3x.png'),
                              size: 18,
                              color: Color(0xff9091A4),
                            ),
                            const SizedBox(width: 5),
                            Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 200),
                                child: Text(
                                  vendorModel.location,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontFamily: "Poppinsr",
                                      letterSpacing: 0.5,
                                      color: Color(0xFF9091A4)),
                                ))
                          ])),
                      InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              isDismissible: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              enableDrag: true,
                              builder: (context) => showTiming(context),
                            );
                          },
                          child: Container(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: Text(
                                "View Timing".tr,
                                style: TextStyle(
                                  color: Color(COLOR_PRIMARY),
                                  fontFamily: "Poppinsr",
                                  letterSpacing: 0.5,
                                ),
                              ))),
                    ]),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Details".tr,
                        style: TextStyle(
                            color: isDarkMode() ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        vendorModel.description,
                        style: TextStyle(
                            fontFamily: "Poppinsl",
                            color: isDarkMode()
                                ? const Color(0xffC6C4C4)
                                : const Color(0xff5E5C5C)),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: width * 0.5,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, ),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Color(COLOR_PRIMARY),
                            width: 0.8,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "delivery price".tr,
                            style: TextStyle(
                                color: Color(COLOR_PRIMARY),
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            deliveryPrice == null
                                ? "Free".tr
                                : "$deliveryPrice $symbol",
                            style: TextStyle(
                                fontFamily: "Poppinsl",
                                color: isDarkMode()
                                    ? const Color(0xffC6C4C4)
                                    : const Color(0xff5E5C5C),
                                fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: width * 0.5,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, ),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Color(COLOR_PRIMARY),
                            width: 0.8,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "delivery time".tr,
                            style: TextStyle(
                                color: Color(COLOR_PRIMARY),
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            vendorModel.deliveryTime == null
                                ? "0".tr
                                : "${vendorModel.deliveryTime} min",
                            style: TextStyle(
                                fontFamily: "Poppinsl",
                                color: isDarkMode()
                                    ? const Color(0xffC6C4C4)
                                    : const Color(0xff5E5C5C),
                                fontSize: 18),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                offerList.isEmpty
                    ? showEmptyState('Offer is not available'.tr, context)
                    : SizedBox(
                        height: 70,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ListView.builder(
                              itemCount: offerList.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    FlutterClipboard.copy(
                                            offerList[index].offerCode!)
                                        .then((value) => 

                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      isDismissible: true,
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      backgroundColor: Colors.transparent,
                                      enableDrag: true,
                                      builder: (context) => openCouponCode(
                                          context, offerList[index]),
                                    ));
                                  },
                                  child: buildOfferItem(index),
                                );
                              }),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget? get leading {
    return Center(
      child: FIconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: backgroundColor,
        icon: Icon(
          Icons.arrow_back,
          color: Color(COLOR_PRIMARY),
        ),
      ),
    );
  }

  @override
  Widget? get title {
    var textTheme = Theme.of(context).textTheme;
    return AnimatedOpacity(
      opacity: isCollapsed ? 0 : 1,
      duration: const Duration(milliseconds: 250),
      child: Text(
        vendorModel.title,
        style: textTheme.titleMedium?.copyWith(color: Colors.black),
        strutStyle: Helper.buildStrutStyle(textTheme.titleMedium),
      ),
    );
  }

  Widget buildOfferItem(int index) {
    return Container(
      margin: const EdgeInsets.fromLTRB(7, 0, 7, 7),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(2),
        color: const Color(COUPON_DASH_COLOR),
        strokeWidth: 2,
        dashPattern: const [5],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Image(
                        image: AssetImage('assets/images/offer_icon.png'),
                        height: 25,
                        width: 25,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        child: Text(
                          "${offerList[index].discountTypeOffer == "Fix Price" ? symbol : ""}${offerList[index].discountOffer}${offerList[index].discountTypeOffer == "Percentage" ? "% OFF" : " OFF"}",
                          style: const TextStyle(
                              color: Color(GREY_TEXT_COLOR),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        offerList[index].offerCode!,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontSize: 16,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.5,
                            color: Color(GREY_TEXT_COLOR)),
                      ),
                      Container(
                        margin:
                            const EdgeInsets.only(left: 15, right: 15, top: 3),
                        width: 1,
                        color: const Color(COUPON_DASH_COLOR),
                      ),
                      Text(
                          "valid till ".tr +
                              getDate(offerList[index]
                                  .expireOfferDate!
                                  .toDate()
                                  .toString())!,
                          style: const TextStyle(
                              fontFamily: "Poppins",
                              letterSpacing: 0.5,
                              color: Color(0Xff696A75)))
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }

  buildTimeCard({required Timeslot timeslot}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: isDarkMode()
                  ? const Color(0XFF3c3a2e)
                  : const Color(0XFFC3C5D1),
              width: 1,
            ),
          ),
          child: Padding(
              padding:
                  const EdgeInsets.only(top: 7, bottom: 7, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("From ".tr,
                      style: TextStyle(
                          fontFamily: "Poppinsr",
                          color: isDarkMode()
                              ? const Color(0XFFa5a292)
                              : const Color(0xff5A5D6D))),
                  //  SizedBox(height: 5,),
                  Text(timeslot.from.toString(),
                      style: TextStyle(
                          fontFamily: "Poppinsm",
                          color: isDarkMode()
                              ? const Color(0XFFa5a292)
                              : const Color(0XFF5A5D6D)))
                ],
              )),
        ),
        const SizedBox(
          width: 20,
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: isDarkMode()
                  ? const Color(0XFF3c3a2e)
                  : const Color(0XFFC3C5D1),
              width: 1,
            ),
          ),
          child: Padding(
              padding:
                  const EdgeInsets.only(top: 7, bottom: 7, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("To ".tr,
                      style: TextStyle(
                          fontFamily: "Poppinsr",
                          color: isDarkMode()
                              ? const Color(0XFFa5a292)
                              : const Color(0xff5A5D6D))),
                  //  SizedBox(height: 5,),
                  Text(timeslot.to.toString(),
                      style: TextStyle(
                          fontFamily: "Poppinsm",
                          color: isDarkMode()
                              ? const Color(0XFFa5a292)
                              : const Color(0XFF5A5D6D)))
                ],
              )),
        ),
      ],
    );
  }

  String? getDate(String date) {
    final format = DateFormat("MMM dd, yyyy");
    String formattedDate = format.format(DateTime.parse(date));
    return formattedDate;
  }

  openCouponCode(
    BuildContext context,
    OfferModel offerModel,
  ) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: const EdgeInsets.only(
                left: 40,
                right: 40,
              ),
              padding: const EdgeInsets.only(
                left: 50,
                right: 50,
              ),
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/offer_code_bg.png"))),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  offerModel.offerCode!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.9),
                ),
              )),
          GestureDetector(
            onTap: () {
              FlutterClipboard.copy(offerModel.offerCode!).then((value) {
                SnackBar snackBar = SnackBar(
                  content: Text(
                    "Coupon code copied".tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return Navigator.pop(context);
              });
            },
            child: Container(
              margin: const EdgeInsets.only(top: 30, bottom: 30),
              child: Text(
                "COPY CODE".tr,
                style: TextStyle(
                    color: Color(COLOR_PRIMARY),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: RichText(
              text: TextSpan(
                text: "Use code ".tr,
                style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                    fontWeight: FontWeight.w700),
                children: <TextSpan>[
                  TextSpan(
                    text: offerModel.offerCode,
                    style: TextStyle(
                        color: Color(COLOR_PRIMARY),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1),
                  ),
                  TextSpan(
                    text:
                        " & get ${offerModel.discountTypeOffer == "Fix Price" ? symbol : ""}${offerModel.discountOffer}${offerModel.discountTypeOffer == "Percentage" ? "% off" : " off"} ",
                    style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  resttiming() {
    if (isOpen == true) {
      return Container(
          height: 35,
          decoration: const BoxDecoration(
              color: Color(0XFFF1F4F7),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10))),
          padding: const EdgeInsets.only(right: 40, left: 10),
          child: Row(children: [
            const Icon(
              Icons.circle,
              color: Color(0XFF3dae7d),
              size: 13,
            ),
            const SizedBox(
              width: 10,
            ),
            Text("Open".tr,
                style: const TextStyle(
                    fontFamily: "Poppinsm",
                    fontSize: 16,
                    color: Color(0XFF3dae7d)))
          ]));
    } else {
      return Container(
          height: 35,
          decoration: const BoxDecoration(
              color: Color(0XFFF1F4F7),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10))),
          padding: const EdgeInsets.only(right: 40, left: 10),
          child: Row(children: [
            const Icon(
              Icons.circle,
              color: Colors.redAccent,
              size: 13,
            ),
            const SizedBox(
              width: 10,
            ),
            Text("Close".tr,
                style: const TextStyle(
                    fontFamily: "Poppinsm",
                    fontSize: 16,
                    letterSpacing: 0.5,
                    color: Colors.redAccent))
          ]));
    }
  }

  showTiming(BuildContext context) {
    List<WorkingHoursModel> workingHours = vendorModel.workingHours;
    return Container(
        decoration: BoxDecoration(
            color: isDarkMode() ? const Color(DARK_BG_COLOR) : Colors.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Stack(children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                      Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                            'Store Timing'.tr,
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: "Poppinsm",
                                color: isDarkMode()
                                    ? const Color(0XFFdadada)
                                    : const Color(0XFF252525)),
                          )),
                    ])),
                const SizedBox(
                  height: 10,
                ),
                ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: workingHours.length,
                    itemBuilder: (context, dayIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            color: isDarkMode()
                                ? const Color(0XFFdadada).withOpacity(0.1)
                                : Colors.grey.shade100,
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Text(
                                          workingHours[dayIndex].day.toString().tr,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: "Poppinsm",
                                              color: isDarkMode()
                                                  ? const Color(0XFFdadada)
                                                  : const Color(0XFF252525)),
                                        ),
                                      ),
                                      Visibility(
                                        visible: workingHours[dayIndex]
                                            .timeslot!
                                            .isEmpty,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Container(
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1.5),
                                                  color: isDarkMode()
                                                      ? Colors.white
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              padding: const EdgeInsets.only(
                                                  right: 15, left: 10),
                                              child: Row(children: [
                                                const Icon(
                                                  Icons.circle,
                                                  color: Colors.redAccent,
                                                  size: 11,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text("Closed".tr,
                                                    style: const TextStyle(
                                                        fontFamily: "Poppinsm",
                                                        color:
                                                            Colors.redAccent))
                                              ])),
                                        ),
                                      )
                                    ],
                                  ),
                                  Visibility(
                                    visible: workingHours[dayIndex]
                                        .timeslot!
                                        .isNotEmpty,
                                    child: ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: workingHours[dayIndex]
                                            .timeslot!
                                            .length,
                                        itemBuilder: (context, slotIndex) {
                                          return buildTimeCard(
                                              timeslot: workingHours[dayIndex]
                                                  .timeslot![slotIndex]);
                                        }),
                                  ),
                                ],
                              ),
                            )),
                      );
                    }),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          Positioned(
              right: 10,
              top: 5,
              child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child:
                      // Padding(padding: EdgeInsets.only(right: 5,top: 5,left: 15,bottom: 20),
                      // child:
                      const CircleAvatar(
                          radius: 17,
                          backgroundColor: Color(0XFFF1F4F7),
                          child: Image(
                            image: AssetImage("assets/images/cancel.png"),
                            height: 35,
                          ))))
        ]));
  }
}
