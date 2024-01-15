import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/model/ProductModel.dart';
import '../../../utils/constants.dart';
import '../AppGlobal.dart';

Padding buildfood_item(ProductModel productModel) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: CachedNetworkImage(
          imageUrl: getImageVAlidUrl(productModel.photo),
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          placeholder: (context, url) => Center(
              child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
          )),
          errorWidget: (context, url, error) => ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              AppGlobal.placeHolderImage!,
              width: MediaQuery.of(context).size.width * 0.75,
              fit: BoxFit.fitHeight,
            ),
          ),
          fit: BoxFit.cover,
        )),
        const SizedBox(height: 8),
        Text(productModel.name,
            maxLines: 1,
            style: const TextStyle(
              fontFamily: "Poppinsm",
              letterSpacing: 0.5,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(
          height: 5,
        ),
        productModel.disPrice == "" || productModel.disPrice == "0"
            ? Text(
                "$symbol${double.parse(productModel.price).toStringAsFixed(decimal)}",
                style: TextStyle(
                    fontFamily: "Poppinsm",
                    letterSpacing: 0.5,
                    color: Color(COLOR_PRIMARY)),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$symbol${double.parse(productModel.disPrice.toString()).toStringAsFixed(decimal)}",
                    style: TextStyle(
                      fontFamily: "Poppinsm",
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(COLOR_PRIMARY),
                    ),
                  ),
                  Text(
                    '$symbol${double.parse(productModel.price).toStringAsFixed(decimal)}',
                    style: const TextStyle(
                        fontFamily: "Poppinsm",
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough),
                  ),
                ],
              ),
      ],
    ),
  );
}
