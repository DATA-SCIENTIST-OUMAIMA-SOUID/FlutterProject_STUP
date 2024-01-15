import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/model/VendorModel.dart';
import '../../../data/model/offer_model.dart';
import '../../../utils/constants.dart';
import '../../home_module/home_controller.dart';
import '../../vendor_module/vendor_page.dart';
import 'openCoupinCode.dart';

offerItemView(VendorModel? vendorModel, OfferModel offerModel) {
  HomeController homeController = Get.find<HomeController>();

  return Stack(
    alignment: Alignment.bottomLeft,
    children: [
      Container(
        margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: const BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(7, 7, 7, 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: getImageVAlidUrl(offerModel.imageOffer!),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black12,
                      ),
                      child: const Image(
                        image:
                            AssetImage("assets/images/place_holder_offer.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    placeholder: (context, url) => const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
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
                      const SizedBox(
                        height: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Get.to(
                                () => NewVendorProductsScreen(
                                    deliveryPrice:
                                        homeController.deliveryCharges,
                                    vendorModel: vendorModel),
                              );
                            },
                            child: Text(vendorModel!.title.tr,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontFamily: "Poppinsm",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Color(0xff000000),
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const ImageIcon(
                                AssetImage('assets/images/location3x.png'),
                                size: 15,
                                color: Color(0xff9091A4),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(vendorModel.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: "Poppinsm",
                                    letterSpacing: 0.5,
                                    color: Color(0xff555353),
                                  )),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      isDismissible: true,
                                      context: Get.context!,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      backgroundColor: Colors.transparent,
                                      enableDrag: true,
                                      builder: (context) =>
                                          openCouponCode(context, offerModel),
                                    );
                                  },
                                  child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(2),
                                    padding: const EdgeInsets.all(2),
                                    color: const Color(COUPON_DASH_COLOR),
                                    strokeWidth: 2,
                                    dashPattern: const [5],
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Container(
                                          height: 25,
                                          width: MediaQuery.of(Get.context!)
                                              .size
                                              .width,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            color: const Color(COUPON_BG_COLOR),
                                          ),
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            offerModel.offerCode!,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                                color: Color(COLOR_PRIMARY)),
                                          )),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Align(
        alignment: AlignmentDirectional.bottomStart,
        child: Container(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                  width: 75,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: const Image(
                      image: AssetImage("assets/images/offer_badge.png"))),
              Container(
                margin: const EdgeInsets.only(top: 3),
                child: Text(
                  "${offerModel.discountTypeOffer == "Fix Price".tr ? symbol : ""}${offerModel.discountOffer}${offerModel.discountTypeOffer == "Percentage" ? "% Off" : " Off"}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.7),
                ),
              )
            ],
          ),
        ),
      )
    ],
  );
}
