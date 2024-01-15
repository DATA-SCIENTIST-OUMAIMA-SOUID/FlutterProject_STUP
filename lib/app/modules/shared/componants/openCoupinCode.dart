import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/model/offer_model.dart';
import '../../../utils/constants.dart';

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
                backgroundColor: Colors.black38,
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
                      "${" & get".tr} ${offerModel.discountTypeOffer == "Fix Price" ? symbol : ""}${offerModel.discountOffer}${offerModel.discountTypeOffer == "Percentage" ? "% off" : " off"} ",
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
