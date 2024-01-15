import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/model/VendorModel.dart';
import '../../../data/services/helper.dart';
import '../../../utils/constants.dart';
import '../AppGlobal.dart';

buildVendorItem(VendorModel vendorModel) {
  return GestureDetector(
    onTap: () {
      // push(
      //   context,
      //   NewVendorProductsScreen(vendorModel: vendorModel),
      // );
    },
    child: Card(
      elevation: 0.5,
      color: isDarkMode() ? Colors.grey.shade900 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 200,

        // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          // mainAxisSize: MainAxisSize.max,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: getImageVAlidUrl(vendorModel.photo),
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover)),
                ),
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                )),
                errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      AppGlobal.placeHolderImage!,
                      fit: BoxFit.fitWidth,
                      width: MediaQuery.of(context).size.width,
                    )),
                fit: BoxFit.cover,
              ),
            ),
            // SizedBox(height: 8),
            ListTile(
              title: Text(vendorModel.title,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode()
                        ? Colors.grey.shade400
                        : Colors.grey.shade800,
                    fontFamily: 'Poppinssb',
                  )),
              subtitle: Text(vendorModel.location,
                  maxLines: 1,

                  // filters.keys
                  //     .where(
                  //         (element) => vendorModel.filters[element] == 'Yes')
                  //     .take(2)
                  //     .join(', '),

                  style: const TextStyle(
                    fontFamily: 'Poppinssm',
                  )),
              trailing: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.star,
                            size: 20,
                            color: Color(COLOR_PRIMARY),
                          ),
                          Text(
                            (vendorModel.reviewsCount != 0)
                                ? (vendorModel.reviewsSum /
                                        vendorModel.reviewsCount)
                                    .toStringAsFixed(1)
                                : "0",
                            style: const TextStyle(
                              fontFamily: 'Poppinssb',
                            ),
                          ),
                          Visibility(
                              visible: vendorModel.reviewsCount != 0,
                              child: Text(
                                  "(${vendorModel.reviewsCount.toStringAsFixed(1)})")),
                        ]),
                  ],
                ),
              ),
            ),
            // SizedBox(height: 4),

            // SizedBox(height: 4),
            // Visibility(
            //   visible: vendorModel.reviewsCount != 0,
            //   child: RichText(
            //     text: TextSpan(
            //       style: TextStyle(
            //           color: isDarkMode(context)
            //               ? Colors.grey.shade200
            //               : Colors.black),
            //       children: [
            //         TextSpan(
            //             text:
            //                 '${double.parse((vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(2))} '),
            //         WidgetSpan(
            //           child: Icon(
            //             Icons.star,
            //             size: 20,
            //             color: Color(COLOR_PRIMARY),
            //           ),
            //         ),
            //         TextSpan(text: ' (${vendorModel.reviewsCount})'),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    ),
  );
}
