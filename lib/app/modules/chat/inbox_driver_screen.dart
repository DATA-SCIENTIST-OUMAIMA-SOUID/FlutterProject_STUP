import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_paginate_firestore/paginate_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../main.dart';
import '../../data/model/User.dart';
import '../../data/model/inbox_model.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../shared/AppGlobal.dart';
import 'chat_screen.dart';

class InboxDriverScreen extends StatefulWidget {
  const InboxDriverScreen({Key? key}) : super(key: key);

  @override
  State<InboxDriverScreen> createState() => _InboxDriverScreenState();
}

class _InboxDriverScreenState extends State<InboxDriverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode() ? Colors.black : Colors.grey.shade100,
      appBar: AppGlobal.buildSimpleAppBar(context, "Inbox".tr),
      body: PaginateFirestore(
        //item builder type is compulsory.
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, documentSnapshots, index) {
          final data = documentSnapshots[index].data() as Map<String, dynamic>?;
          InboxModel inboxModel = InboxModel.fromJson(data!);
          print("image ${inboxModel.restaurantProfileImage}");
          return InkWell(
            onTap: () async {
              await showProgress(context, "Please wait".tr, false);

              User? customer = await FireStoreUtils.getCurrentUser(
                  inboxModel.customerId.toString());
              User? restaurantUser = await FireStoreUtils.getCurrentUser(
                  inboxModel.restaurantId.toString());
              hideProgress();
              push(
                  context,
                  ChatScreens(
                    customerName:
                        '${customer!.firstName + " " + customer.lastName}',
                    restaurantName:
                        '${restaurantUser!.firstName + " " + restaurantUser.lastName}',
                    orderId: inboxModel.orderId,
                    restaurantId: restaurantUser.userID,
                    customerId: customer.userID,
                    customerProfileImage: customer.profilePictureURL,
                    restaurantProfileImage: restaurantUser.profilePictureURL,
                    token: restaurantUser.fcmToken,
                    chatType: inboxModel.chatType,
                  ));
            },
            child: ListTile(
              leading: ClipOval(
                child: inboxModel.restaurantProfileImage != ""
                    ? CachedNetworkImage(
                        width: 50,
                        height: 50,
                        imageUrl: inboxModel.restaurantProfileImage != ""
                            ? inboxModel.restaurantProfileImage.toString()
                            : "", // Check if it's not null before using
                        imageBuilder: (context, imageProvider) => Container(
                              width: 50,
                              height: 50,
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
                            )))
                    : SizedBox(),
              ),
              title: Row(
                children: [
                  Expanded(child: Text(inboxModel.restaurantName.toString())),
                  Text(
                      DateFormat('MMM d, yyyy').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              inboxModel.createdAt!.millisecondsSinceEpoch)),
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              subtitle: Text("Order Id : #" + inboxModel.orderId.toString()),
            ),
          );
        },
        shrinkWrap: true,
        onEmpty: Center(child: Text("No Conversion found".tr)),
        // orderBy is compulsory to enable pagination
        query: FirebaseFirestore.instance
            .collection('chat_driver')
            .where("customerId", isEqualTo: MyApp.currentUser!.userID)
            .orderBy('createdAt', descending: true),
        //Change types customerId
        itemBuilderType: PaginateBuilderType.listView,
        initialLoader: CircularProgressIndicator(),
        // to fetch real-time data
        isLive: true,
      ),
    );
  }
}
