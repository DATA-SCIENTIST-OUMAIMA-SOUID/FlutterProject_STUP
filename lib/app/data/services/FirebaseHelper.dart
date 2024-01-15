import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../main.dart';
import '../../modules/reauth_user_screen.dart';
import '../../userPrefrence.dart';
import '../../utils/constants.dart';
import '../model/AddressModel.dart';
import '../model/AttributesModel.dart';
import '../model/BannerModel.dart';
import '../model/ChatVideoContainer.dart';
import '../model/CodModel.dart';
import '../model/CurrencyModel.dart';
import '../model/DeliveryChargeModel.dart';
import '../model/OrderModel.dart';
import '../model/ProductModel.dart';
import '../model/Ratingmodel.dart';
import '../model/ReviewAttributeModel.dart';
import '../model/TaxModel.dart';
import '../model/User.dart';
import '../model/VendorCategoryModel.dart';
import '../model/VendorModel.dart';
import '../model/conversation_model.dart';
import '../model/deliveryCouponModel.dart';
import '../model/inbox_model.dart';
import '../model/offer_model.dart';
import 'helper.dart';

class FireStoreUtils {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static Reference storage = FirebaseStorage.instance.ref();

  late StreamController<User> driverStreamController;
  late StreamSubscription driverStreamSub;

  late StreamController<OrderModel> ordersByIdStreamController;

  late StreamSubscription ordersByIdStreamSub;

  dynamic currentUser;

  StreamController<List<VendorModel>>? vendorStreamController;

  StreamSubscription? ordersStreamSub;
  StreamController<List<OrderModel>>? ordersStreamController;

  StreamController<List<VendorModel>>? allResaturantStreamController;

  StreamController<List<VendorModel>>? allCategoryResaturantStreamController;

  final geo = GeoFlutterFire();

  late StreamController<List<VendorModel>> cusionStreamController;

  Future<void> addUserToCoupon(String code, String userToAdd) async {
    try {
      // Get the reference to the "deliveryCoupon" collection
      CollectionReference deliveryCouponCollection =
          FirebaseFirestore.instance.collection('deliveryCoupon');

      // Query for documents where the field "code" is equal to the provided code
      QuerySnapshot querySnapshot =
          await deliveryCouponCollection.where('code', isEqualTo: code).get();

      // Loop through the documents (should be one in this case) and update each one
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        // Get the current "users" field value from the document
        List<dynamic>? currentUsers =
            documentSnapshot.get('users') as List<dynamic>?;

        // If "users" is null or not a List, initialize it as an empty List
        List<dynamic> updatedUsers = currentUsers ?? [];

        // Check if the userToAdd is already in the List to avoid duplicates
        if (!updatedUsers.contains(userToAdd)) {
          updatedUsers.add(userToAdd);
        }

        // Update the document with the new "users" data
        await documentSnapshot.reference.update({'users': updatedUsers});
      }
    } catch (e) {
      rethrow;
    }
  }

  void closeDineInStream() {
    // allDineInResaturantStreamController.close;
    // popularStreamController.close;
  }
  closeOrdersStream() {
    if (ordersStreamSub != null) {
      ordersStreamSub!.cancel();
    }
    if (ordersStreamController != null) {
      ordersStreamController!.close();
    }
  }

  closeVendorStream() {
    if (vendorStreamController != null) {
      vendorStreamController!.close();
    }
    if (allResaturantStreamController != null) {
      allResaturantStreamController!.close();
    }
    //newArrivalStreamController.close();
    //productStreamController123.close();
    //productStreamController.close();
  }

  Future<AddressModel?> getAddressFromFirebase() async {
    if (MyApp.currentUser != null) {
      var phoneNumber = MyApp.currentUser!.phoneNumber;

      QuerySnapshot<Map<String, dynamic>> userQuery = await firestore
          .collection("users")
          .where("phoneNumber", isEqualTo: phoneNumber)
          .get();
      if (userQuery.docs.isNotEmpty) {
        List<User> users =
            userQuery.docs.map((doc) => User.fromJson(doc.data())).toList();
        User user = users.first;

        return user.shippingAddress;
      } else {
        return null;
      }
    }
    return null;
  }

  Future<AddressModel?> getAddressFromFirebase2() async {
    var phoneNumber = MyApp.currentUser!.phoneNumber;

    QuerySnapshot<Map<String, dynamic>> userQuery = await firestore
        .collection("users")
        .where("phoneNumber", isEqualTo: phoneNumber)
        .get();

    if (userQuery.docs.isNotEmpty) {
      List<User> users =
          userQuery.docs.map((doc) => User.fromJson(doc.data())).toList();
      User user = users.first;

      return user.shippingAddress2;
    } else {
      return null;
    }
  }

  Future<List<OfferModel>> getAllCoupons() async {
    List<OfferModel> coupon = [];

    QuerySnapshot<Map<String, dynamic>> couponsQuery = await firestore
        .collection(COUPON)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .get();
    await Future.forEach(couponsQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        coupon.add(OfferModel.fromJson(document.data()));
      } catch (e) {}
    });
    return coupon;
  }

  Future<List<ProductModel>> getAllDelevryProducts() async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore
        .collection(PRODUCTS)
        .where("takeawayOption", isEqualTo: false)
        .where('publish', isEqualTo: true)
        .get();
    await Future.forEach(productsQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        debugPrint(
            'productspppp**-FireStoreUtils.getAllProducts Parse error $e  ${document.data()['id']}');
      }
    });
    return products;
  }

  Future<List<ProductModel>> getAllProducts() async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery =
        await firestore.collection(PRODUCTS).get();
    await Future.forEach(productsQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        debugPrint(
            'productspppp**-FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return products;
  }

  Stream<List<VendorModel>> getAllRestaurants() async* {
    allResaturantStreamController =
        StreamController<List<VendorModel>>.broadcast();
    List<VendorModel> vendors = [];

    try {} catch (e) {}

    yield* allResaturantStreamController!.stream;
  }

  Future<List<ProductModel>> getAllTakeAWayProducts() async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore
        .collection(PRODUCTS)
        .where('publish', isEqualTo: true)
        .get();
    await Future.forEach(productsQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        debugPrint(
            'productspppp**-123--FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return products;
  }

  Future<List<ProductModel>> getAllVendorProducts(String vendorID) async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore
        .collection(PRODUCTS)
        .where('vendorID', isEqualTo: vendorID)
        .where('publish', isEqualTo: true)
        .get();

    await Future.forEach(productsQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
        //
      } catch (e) {}
    });

    return products;
  }

  Stream<List<VendorModel>> getCategoryRestaurants(String categoryId) async* {
    allCategoryResaturantStreamController =
        StreamController<List<VendorModel>>.broadcast();
    List<VendorModel> vendors = [];
  }

  Future<CodModel?> getCod() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery =
        await firestore.collection(Setting).doc('CODSettings').get();
    if (codQuery.data() != null) {
      return CodModel.fromJson(codQuery.data()!);
    } else {
      return null;
    }
  }

  getContactUs() async {
    Map<String, dynamic> contactData = {};
    await firestore.collection(Setting).doc(CONTACT_US).get().then((value) {
      contactData = value.data()!;
    });

    return contactData;
  }

  Future<List<VendorCategoryModel>> getCuisines() async {
    List<VendorCategoryModel> cuisines = [];
    QuerySnapshot<Map<String, dynamic>> cuisinesQuery = await firestore
        .collection(VENDORS_CATEGORIES)
        .where('publish', isEqualTo: true)
        .get();
    await Future.forEach(cuisinesQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        cuisines.add(VendorCategoryModel.fromJson(document.data()));
      } catch (e) {}
    });
    return cuisines;
  }

  Future<List<CurrencyModel>> getCurrency() async {
    List<CurrencyModel> currency = [];

    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore
        .collection(Currency)
        .where("isActive", isEqualTo: true)
        .get();
    await Future.forEach(currencyQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        currency.add(CurrencyModel.fromJson(document.data()));
      } catch (e) {}
    });

    return currency;
  }

  Future<DeliveryChargeModel?> getDeliveryCharges() async {
    print("deliveryChargesvalue");

    DocumentSnapshot<Map<String, dynamic>> codQuery =
        await firestore.collection(Setting).doc('DeliveryCharge').get();

    if (codQuery.data() != null) {
      print("object");
      return DeliveryChargeModel.fromJson(codQuery.data()!);
    } else {
      print("object");

      return null;
    }
  }

  Future<List<DeliveryCouponModel>> getDeliveryCouponFromFirebase() async {
    try {
      // Get the reference to the "deliveryCoupon" collection
      CollectionReference deliveryCouponCollection =
          FirebaseFirestore.instance.collection('deliveryCoupon');

      // Get the documents from the collection
      QuerySnapshot querySnapshot = await deliveryCouponCollection.get();

      // Convert the documents to a list of DeliveryCouponModel
      List<DeliveryCouponModel> couponsList = querySnapshot.docs
          .map((documentSnapshot) => DeliveryCouponModel.fromJson(
              documentSnapshot.data() as Map<String, dynamic>))
          .toList();

      return couponsList;
    } catch (e) {
      // Handle any errors that may occur during the fetch

      rethrow; // Rethrow the exception to be handled by the caller
    }
  }

  Stream<User> getDriver(String userId) async* {
    driverStreamController = StreamController();
    driverStreamSub = firestore
        .collection(USERS)
        .doc(userId)
        .snapshots()
        .listen((onData) async {
      if (onData.data() != null) {
        User? user = User.fromJson(onData.data()!);
        driverStreamController.sink.add(user);
      }
    });
    yield* driverStreamController.stream;
  }

  Future<List<VendorCategoryModel>> getHomePageShowCategory() async {
    List<VendorCategoryModel> cuisines = [];
    QuerySnapshot<Map<String, dynamic>> cuisinesQuery = await firestore
        .collection(VENDORS_CATEGORIES)
        .where("show_in_homepage", isEqualTo: true)
        .where('publish', isEqualTo: true)
        .get();
    await Future.forEach(cuisinesQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        cuisines.add(VendorCategoryModel.fromJson(document.data()));
      } catch (e) {}
    });
    return cuisines;
  }

  Future<List<BannerModel>> getHomeTopBanner() async {
    List<BannerModel> bannerHome = [];
    QuerySnapshot<Map<String, dynamic>> bannerHomeQuery = await firestore
        .collection(MENU_ITEM)
        .where("is_publish", isEqualTo: true)
        .where("position", isEqualTo: "top")
        .orderBy("set_order", descending: false)
        .get();
    await Future.forEach(bannerHomeQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        bannerHome.add(BannerModel.fromJson(document.data()));
      } catch (e) {}
    });
    return bannerHome;
  }

  Future<List<OfferModel>> getOfferByVendorID(String vendorID) async {
    List<OfferModel> offers = [];
    QuerySnapshot<Map<String, dynamic>> bannerHomeQuery = await firestore
        .collection(COUPON)
        .where("resturant_id", isEqualTo: vendorID)
        .where("isEnabled", isEqualTo: true)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .get();

    await Future.forEach(bannerHomeQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        offers.add(OfferModel.fromJson(document.data()));
      } catch (e) {}
    });
    return offers;
  }

  Stream<OrderModel?> getOrderByID(String inProgressOrderID) async* {
    ordersByIdStreamController = StreamController();
    ordersByIdStreamSub = firestore
        .collection(ORDERS)
        .doc(inProgressOrderID)
        .snapshots()
        .listen((onData) async {
      if (onData.data() != null) {
        OrderModel? orderModel = OrderModel.fromJson(onData.data()!);
        ordersByIdStreamController.sink.add(orderModel);
      }
    });
    yield* ordersByIdStreamController.stream;
  }

  Future<RatingModel?> getOrderReviewsbyID(
      String ordertId, String productId) async {
    RatingModel? ratingproduct;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore
        .collection(Order_Rating)
        .where('orderid', isEqualTo: ordertId)
        .where('productId', isEqualTo: productId)
        .get();
    if (vendorsQuery.docs.isNotEmpty) {
      try {
        if (vendorsQuery.docs.isNotEmpty) {
          ratingproduct = RatingModel.fromJson(vendorsQuery.docs.first.data());
        }
      } catch (e) {}
    }
    return ratingproduct;
  }

  Stream<List<OrderModel>> getOrders(String userID) async* {
    List<OrderModel> orders = [];
    ordersStreamController = StreamController();
    ordersStreamSub = firestore
        .collection(ORDERS)
        .where('authorID', isEqualTo: userID)
        .orderBy('createdAt',
            descending: true) // Order by the 'date' field in descending order
        .snapshots()
        .listen((onData) async {
      orders.clear();
      await Future.forEach(onData.docs,
          (QueryDocumentSnapshot<Map<String, dynamic>> element) {
        try {
          OrderModel orderModel = OrderModel.fromJson(element.data());
          if (!orders.contains(orderModel)) {
            orders.add(orderModel);
          }
        } catch (e, s) {}
      });
      ordersStreamController!.sink.add(orders);
    });
    yield* ordersStreamController!.stream;
  }

  Future<String?> getplaceholderimage() async {
    var collection = FirebaseFirestore.instance.collection(Setting);
    var docSnapshot = await collection.doc('placeHolderImage').get();
    Map<String, dynamic>? data = docSnapshot.data();
    var value = data?['image'];
    placeholderImage = value;
    return placeholderImage;
  }

  Future<ProductModel> getProductByID(String productId) async {
    late ProductModel productModel;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore
        .collection(PRODUCTS)
        .where('id', isEqualTo: productId)
        .get();
    try {
      if (vendorsQuery.docs.isNotEmpty) {
        productModel = ProductModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {}
    return productModel;
  }

  Future<ProductModel> getProductByProductID(String productId) async {
    late ProductModel productModel;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore
        .collection(PRODUCTS)
        .where('id', isEqualTo: productId)
        .where('publish', isEqualTo: true)
        .get();
    try {
      if (vendorsQuery.docs.isNotEmpty) {
        productModel = ProductModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {}
    return productModel;
  }

  Future<String?> getRestaurantNearBy() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery =
        await firestore.collection(Setting).doc('RestaurantNearBy').get();
    if (codQuery.data() != null) {
      radiusValue = double.parse(codQuery["radios"].toString());

      return codQuery["radios"].toString();
    } else {
      return "";
    }
  }

  Future<List<RatingModel>> getReviewsbyVendorID(String vendorId) async {
    List<RatingModel> vendorreview = [];

    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore
        .collection(Order_Rating)
        .where('VendorId', isEqualTo: vendorId)
        // .orderBy('createdAt', descending: true)
        .get();
    await Future.forEach(vendorsQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        vendorreview.add(RatingModel.fromJson(document.data()));
      } catch (e) {}
    });
    return vendorreview;
  }

  Future<TaxModel?> getTaxSetting() async {
    DocumentSnapshot<Map<String, dynamic>> taxQuery =
        await firestore.collection(Setting).doc('taxSetting').get();
    if (taxQuery.data() != null) {
      return TaxModel.fromJson(taxQuery.data()!);
    }

    return null;
  }

  Stream<User> getUserByID(String id) async* {
    StreamController<User> userStreamController = StreamController();
    firestore.collection(USERS).doc(id).snapshots().listen((user) {
      try {
        User userModel = User.fromJson(user.data() ?? {});
        userStreamController.sink.add(userModel);
      } catch (e) {
        debugPrint(
            'FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });
    yield* userStreamController.stream;
  }

  Future<String?> getUserIdByPhone(String phone) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: phone)
        .get();

    if (snapshot.docs.isNotEmpty) {
      currentUser = snapshot.docs.first.data();

      String userId = snapshot.docs.first.id;
      // Assuming there's only one user with the given name
      if (MyApp.currentUser != null) {
        MyApp.currentUser!.userID = userId;
      }

      return userId;
    }

    return null; // User with the given name not found.
  }

  Future<VendorModel> getVendorByVendorID(String vendorID) async {
    late VendorModel vendor;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore
        .collection(VENDORS)
        .where('id', isEqualTo: vendorID)
        .get();
    try {
      if (vendorsQuery.docs.isNotEmpty) {
        vendor = VendorModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {}
    return vendor;
  }

  Future<VendorCategoryModel?> getVendorCategoryByCategoryId(
      String vendorCategoryID) async {
    DocumentSnapshot<Map<String, dynamic>> documentReference = await firestore
        .collection(VENDORS_CATEGORIES)
        .doc(vendorCategoryID)
        .get();
    if (documentReference.data() != null && documentReference.exists) {
      return VendorCategoryModel.fromJson(documentReference.data()!);
    } else {
      return null;
    }
  }

  Future<VendorCategoryModel?> getVendorCategoryById(
      String vendorCategoryID) async {
    VendorCategoryModel? vendorCategoryModel;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore
        .collection(VENDORS_CATEGORIES)
        .where('id', isEqualTo: vendorCategoryID)
        .where('publish', isEqualTo: true)
        .get();
    try {
      if (vendorsQuery.docs.isNotEmpty) {
        vendorCategoryModel =
            VendorCategoryModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {}
    return vendorCategoryModel;
  }

  Future<List> getVendorCusions(String id) async {
    List tagList = [];
    List prodtagList = [];
    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore
        .collection(PRODUCTS)
        .where('vendorID', isEqualTo: id)
        .get();
    await Future.forEach(productsQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      if (document.data().containsKey("categoryID") &&
          document.data()['categoryID'].toString().isNotEmpty) {
        prodtagList.add(document.data()['categoryID']);
      }
    });
    QuerySnapshot<Map<String, dynamic>> catQuery = await firestore
        .collection(VENDORS_CATEGORIES)
        .where('publish', isEqualTo: true)
        .get();
    await Future.forEach(catQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      Map<String, dynamic> catDoc = document.data();
      if (catDoc.containsKey("id") &&
          catDoc['id'].toString().isNotEmpty &&
          catDoc.containsKey("title") &&
          catDoc['title'].toString().isNotEmpty &&
          prodtagList.contains(catDoc['id'])) {
        tagList.add(catDoc['title']);
      }
    });

    return tagList;
  }

  Future<List<ProductModel>> getVendorProductsDelivery(String vendorID) async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore
        .collection(PRODUCTS)
        .where('vendorID', isEqualTo: vendorID)
        .where("takeawayOption", isEqualTo: false)
        .where('publish', isEqualTo: true)
        .get();
    await Future.forEach(productsQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
      } catch (e) {}
    });

    return products;
  }

  Future<ReviewAttributeModel?> getVendorReviewAttribute(
      String attrubuteId) async {
    DocumentSnapshot<Map<String, dynamic>> documentReference =
        await firestore.collection(REVIEW_ATTRIBUTES).doc(attrubuteId).get();
    if (documentReference.data() != null && documentReference.exists) {
      return ReviewAttributeModel.fromJson(documentReference.data()!);
    } else {
      return null;
    }
  }

  Future<List<VendorModel>> getVendors() async {
    List<VendorModel> vendors = [];
    QuerySnapshot<Map<String, dynamic>> vendorsQuery =
        await firestore.collection(VENDORS).get();
    await Future.forEach(vendorsQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        vendors.add(VendorModel.fromJson(document.data()));
      } catch (e) {}
    });
    return vendors;
  }

  Stream<List<VendorModel>> getVendors1({String? path}) async* {
    vendorStreamController = StreamController<List<VendorModel>>.broadcast();
    List<VendorModel> vendors = [];
    var collectionReference = (path == null || path.isEmpty)
        ? firestore.collection(VENDORS)
        : firestore
            .collection(VENDORS)
            .where("enabledDiveInFuture", isEqualTo: true);

    String field = 'g';

    yield* vendorStreamController!.stream;
  }

  Stream<List<VendorModel>> getVendorsByCuisineID(String cuisineID,
      {bool? isDinein}) async* {
    await getRestaurantNearBy();
    cusionStreamController = StreamController<List<VendorModel>>.broadcast();
    List<VendorModel> vendors = [];
    var collectionReference = isDinein!
        ? firestore
            .collection(VENDORS)
            .where('categoryID', isEqualTo: cuisineID)
            .where("enabledDiveInFuture", isEqualTo: true)
        : firestore
            .collection(VENDORS)
            .where('categoryID', isEqualTo: cuisineID);

    GeoFirePoint center = geo.point(
        latitude: MyApp.selectedPosotion.latitude,
        longitude: MyApp.selectedPosotion.longitude);
    String field = 'g';
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(
            center: center,
            radius: radiusValue,
            field: field,
            strictMode: true);
    stream.listen((List<DocumentSnapshot> documentList) {
      Future.forEach(documentList, (DocumentSnapshot element) {
        final data = element.data() as Map<String, dynamic>;
        vendors.add(VendorModel.fromJson(data));
        cusionStreamController.add(vendors);
      });
      cusionStreamController.close();
    });

    yield* cusionStreamController.stream;
  }

  Future<OrderModel> placeOrder(OrderModel orderModel) async {
    DocumentReference documentReference =
        firestore.collection(ORDERS).doc(UserPreference.getOrderId());
    orderModel.id = documentReference.id;
    await documentReference.set(orderModel.toJson());
    return orderModel;
  }

  Future<OrderModel> placeOrderWithTakeAWay(OrderModel orderModel) async {
    DocumentReference documentReference;
    if (orderModel.id.isEmpty) {
      documentReference = firestore.collection(ORDERS).doc();
      orderModel.id = documentReference.id;
    } else {
      documentReference = firestore.collection(ORDERS).doc(orderModel.id);
    }
    await documentReference.set(orderModel.toJson());
    return orderModel;
  }

  void updateOrderStatus(String orderId, String newStatus) {
    // Step 1: Get a reference to the Firestore database
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Step 2: Get a reference to the specific order document
    CollectionReference ordersRef = firestore.collection(ORDERS);
    DocumentReference orderDocRef = ordersRef.doc(orderId);

    // Step 3: Update the order status
    orderDocRef
        .update({'status': newStatus})
        .then((_) {})
        .catchError((error) {});
  }

  Future<Url> uploadChatImageToFireStorage(
      File image, BuildContext context) async {
    showProgress(context, 'Uploading image...', false);
    var uniqueID = const Uuid().v4();
    Reference upload = storage.child('images/$uniqueID.png');
    File compressedImage = await compressImage(image);
    UploadTask uploadTask = upload.putFile(compressedImage);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress(
          'Uploading image ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
          'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {});
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return Url(
        mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  Future<ChatVideoContainer> uploadChatVideoToFireStorage(
      File video, BuildContext context) async {
    showProgress(context, 'Uploading video...', false);
    var uniqueID = const Uuid().v4();
    Reference upload = storage.child('videos/$uniqueID.mp4');
    File compressedVideo = await _compressVideo(video);
    SettableMetadata metadata = SettableMetadata(contentType: 'video');
    UploadTask uploadTask = upload.putFile(compressedVideo, metadata);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress(
          'Uploading video ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
          'KB');
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    final uint8list = await VideoThumbnail.thumbnailFile(
        video: downloadUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG);
    final file = File(uint8list ?? '');
    String thumbnailDownloadUrl = await uploadVideoThumbnailToFireStorage(file);
    hideProgress();
    return ChatVideoContainer(
        videoUrl: Url(
            url: downloadUrl.toString(), mime: metaData.contentType ?? 'video'),
        thumbnailUrl: thumbnailDownloadUrl);
  }

  Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = const Uuid().v4();
    Reference upload = storage.child('thumbnails/$uniqueID.png');
    File compressedImage = await compressImage(file);
    UploadTask uploadTask = upload.putFile(compressedImage);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchOrderStatus(
      String orderID) async* {
    yield* firestore.collection(ORDERS).doc(orderID).snapshots();
  }

  /// compress video file to make it load faster but with lower quality,
  /// change the quality parameter to control the quality of the video after
  /// being compressed
  /// @param file the video file that will be compressed
  /// @return File a new compressed file with smaller size
  Future<File> _compressVideo(File file) async {
    MediaInfo? info = await VideoCompress.compressVideo(file.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 24);
    if (info != null) {
      File compressedVideo = File(info.path!);
      return compressedVideo;
    } else {
      return file;
    }
  }

  static Future addDriverChat(ConversationModel conversationModel) async {
    return await firestore
        .collection("chat_driver")
        .doc(conversationModel.orderId)
        .collection("thread")
        .doc(conversationModel.id)
        .set(conversationModel.toJson())
        .then((document) {
      return conversationModel;
    });
  }

  static Future addDriverInbox(InboxModel inboxModel) async {
    return await firestore
        .collection("chat_driver")
        .doc(inboxModel.orderId)
        .set(inboxModel.toJson())
        .then((document) {
      return inboxModel;
    });
  }

  static Future addRestaurantChat(ConversationModel conversationModel) async {
    return await firestore
        .collection("chat_restaurant")
        .doc(conversationModel.orderId)
        .collection("thread")
        .doc(conversationModel.id)
        .set(conversationModel.toJson())
        .then((document) {
      return conversationModel;
    });
  }

  static Future addRestaurantInbox(InboxModel inboxModel) async {
    return await firestore
        .collection("chat_restaurant")
        .doc(inboxModel.orderId)
        .set(inboxModel.toJson())
        .then((document) {
      return inboxModel;
    });
  }

  static Future<File> compressImage(File file) async {
    File compressedImage = await FlutterNativeImage.compressImage(file.path,
        quality: 25, targetWidth: 600, targetHeight: 300);
    return compressedImage;
  }

  static createOrder() async {
    DocumentReference documentReference = firestore.collection(ORDERS).doc();
    final orderId = documentReference.id;
    UserPreference.setOrderId(orderId: orderId);
  }

/*
  static deleteUser() async {
    try {
      await firestore
          .collection(USERS)
          .doc(auth.FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        print("user id : ${auth.FirebaseAuth.instance.currentUser!.uid}");
      });
      // delete user records from CHANNEL_PARTICIPATION table
      /*await firestore
          .collection(ORDERS)
          .where('authorID', isEqualTo: MyApp.currentUser!.userID)
          .get()
          .then((value) async {
        for (var doc in value.docs) {
          await firestore.doc(doc.reference.path).delete();
        }
      });
      await firestore
          .collection(USERS)
          .doc(auth.FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        print(auth.FirebaseAuth.instance.currentUser!.uid);
      });
      await firestore
          .collection(USERS)
          .doc(auth.FirebaseAuth.instance.currentUser!.uid)
          .delete();

      // delete user  from firebase auth
      await auth.FirebaseAuth.instance.currentUser!.delete();*/
    } catch (e) {
      print("ERR : $e");
    }
  }
*/
  static deleteUser() async {
    try {
      final currentUser = auth.FirebaseAuth.instance.currentUser;

      if (MyApp.currentUser!.userID != "") {
        await firestore
            .collection(USERS)
            .doc(MyApp.currentUser!.userID)
            .get()
            .then((value) {
          print("user id : ${value.id}");
        });
      } else {
        print("L'utilisateur actuel est null.");
      }

      await firestore
          .collection(ORDERS)
          .where('authorID', isEqualTo: MyApp.currentUser!.userID)
          .get()
          .then((value) async {
        for (var doc in value.docs) {
          await firestore.doc(doc.reference.path).delete();
        }
      });
      await firestore.collection(USERS).doc(MyApp.currentUser!.userID).delete();

      // delete user  from firebase auth
      if (currentUser != null) {
        await auth.FirebaseAuth.instance.currentUser!.delete();
      }
    } catch (e) {
      print("ERR : $e");
    }
  }

  static Future<String?> firebaseCreateNewReview(
      RatingModel ratingModel) async {
    try {
      await firestore
          .collection(Order_Rating)
          .doc(ratingModel.id)
          .set(ratingModel.toJson());
    } catch (e, s) {
      return 'Couldn\'t review'.tr;
    }
    return null;
  }

  static Future<String?> firebaseCreateNewUser(User user) async {
    try {
      await firestore.collection(USERS).doc().set(user.toJson());
    } catch (e, s) {
      return "notSignUp".tr;
    }
    return null;
  }

  static firebaseSignUpWithEmailAndPassword(String emailAddress,
      String password, String firstName, String lastName) async {
    try {
      auth.UserCredential result = await auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailAddress, password: password);
      String profilePicUrl = '';

      User user = User(
          email: emailAddress,
          settings: UserSettings(),
          lastOnlineTimestamp: Timestamp.now(),
          active: true,
          phoneNumber: "",
          firstName: firstName,
          role: USER_ROLE_CUSTOMER,
          userID: result.user?.uid ?? '',
          lastName: lastName,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          profilePictureURL: profilePicUrl);
      String? errorMessage = await firebaseCreateNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return 'Couldn\'t sign up for firebase, Please try again.';
      }
    } on auth.FirebaseAuthException catch (error) {
      String message = "notSignUp".tr;
      switch (error.code) {
        case 'email-already-in-use':
          message = 'Email already in use, Please pick another email!';
          break;
        case 'invalid-email':
          message = 'Enter valid e-mail';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          message = 'Password must be more than 5 characters';
          break;
        case 'too-many-requests':
          message = 'Too many requests, Please try again later.';
          break;
      }
      return message;
    } catch (e) {
      return "notSignUp".tr;
    }
  }

  static firebaseSubmitPhoneNumber(
    String phoneNumber,
    auth.PhoneCodeAutoRetrievalTimeout? phoneCodeAutoRetrievalTimeout,
    auth.PhoneCodeSent? phoneCodeSent,
    auth.PhoneVerificationFailed? phoneVerificationFailed,
    auth.PhoneVerificationCompleted? phoneVerificationCompleted,
  ) {
    auth.FirebaseAuth.instance.verifyPhoneNumber(
      timeout: const Duration(minutes: 2),
      phoneNumber: phoneNumber,
      verificationCompleted: phoneVerificationCompleted!,
      verificationFailed: phoneVerificationFailed!,
      codeSent: phoneCodeSent!,
      codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout!,
    );
  }

  static Future<List<AttributesModel>> getAttributes() async {
    List<AttributesModel> attributesList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery =
        await firestore.collection(VENDOR_ATTRIBUTES).get();
    await Future.forEach(currencyQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        attributesList.add(AttributesModel.fromJson(document.data()));
      } catch (e) {}
    });
    return attributesList;
  }

  static Future<User?> getCurrentUser(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await firestore.collection(USERS).doc(uid).get();
    if (userDocument.data() != null && userDocument.exists) {
      return User.fromJson(userDocument.data()!);
    } else {
      return null;
    }
  }

  static Future<void> getCurrerntUserAdress1() async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await firestore.collection(USERS).doc(MyApp.currentUser!.userID).get();
    if (userDocument.data() != null && userDocument.exists) {
      MyApp.currentUser!.shippingAddress =
          AddressModel.fromJson(userDocument.data()!['shippingAddress']);
    }
  }

  static Future<void> getCurrerntUserAdress2() async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await firestore.collection(USERS).doc(MyApp.currentUser!.userID).get();
    if (userDocument.data() != null && userDocument.exists) {
      MyApp.currentUser!.shippingAddress2 =
          AddressModel.fromJson(userDocument.data()!['shippingAddress2']);
    }
  }

  static Future<List<ProductModel>> getProductListByCategoryId(
      String categoryId) async {
    List<ProductModel> productList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore
        .collection(PRODUCTS)
        .where('categoryID', isEqualTo: categoryId)
        .where('publish', isEqualTo: true)
        .get();
    await Future.forEach(currencyQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        productList.add(ProductModel.fromJson(document.data()));
      } catch (e) {}
    });
    return productList;
  }

  static Future<List<ProductModel>> getStoreProduct(String storeId) async {
    List<ProductModel> productList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore
        .collection(PRODUCTS)
        .where('vendorID', isEqualTo: storeId)
        .where('publish', isEqualTo: true)
        .limit(6)
        .get();
    await Future.forEach(currencyQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        productList.add(ProductModel.fromJson(document.data()));
      } catch (e) {}
    });
    return productList;
  }

  static Future<VendorModel?> getVendor(String vid) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await firestore.collection(VENDORS).doc(vid).get();
    if (userDocument.data() != null && userDocument.exists) {
      return VendorModel.fromJson(userDocument.data()!);
    } else {
      return null;
    }
  }

  static Future<dynamic> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      auth.UserCredential result = await auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // result.user.
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await firestore.collection(USERS).doc(result.user?.uid ?? '').get();
      User? user;

      if (documentSnapshot.exists) {
        // if(user!.role != 'vendor'){
        user = User.fromJson(documentSnapshot.data() ?? {});
        // if(  USER_ROLE_CUSTOMER ==user.role)
        // {
        user.fcmToken = await firebaseMessaging.getToken() ?? '';

        //user.active = true;

        //      }
      }
      return user;
    } on auth.FirebaseAuthException catch (exception, s) {
      switch ((exception).code) {
        case 'invalid-email':
          return 'Email address is malformed.';
        case 'wrong-password':
          return 'Wrong password.';
        case 'user-not-found':
          return 'No user corresponding to the given email address.';
        case 'user-disabled':
          return 'This user has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts to sign in as this user.';
      }
      return 'Unexpected firebase error, Please try again.';
    } catch (e, s) {
      return 'Login failed, Please try again.';
    }
  }

  static Future<auth.UserCredential?> reAuthUser(AuthProviders provider,
      {String? email,
      String? password,
      String? smsCode,
      String? verificationId,
      AccessToken? accessToken,
      apple.AuthorizationResult? appleCredential}) async {
    late auth.AuthCredential credential;
    switch (provider) {
      case AuthProviders.PASSWORD:
        credential = auth.EmailAuthProvider.credential(
            email: email!, password: password!);
        break;
      case AuthProviders.PHONE:
        credential = auth.PhoneAuthProvider.credential(
            smsCode: smsCode!, verificationId: verificationId!);
        break;
    }
    return await auth.FirebaseAuth.instance.currentUser!
        .reauthenticateWithCredential(credential);
  }

  static resetPassword(String emailAddress) async =>
      await auth.FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailAddress);

  static Future<bool> sendFcmMessage(
      String title, String message, String token) async {
    try {
      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization": "key=$SERVER_KEY",
      };
      var request = {
        "notification": {
          "title": title,
          "body": message,
          "sound": "default",
          // "color": COLOR_PRIMARY,
        },
        "priority": "high",
        'data': <String, dynamic>{'id': '1', 'status': 'done'},
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "to": token
      };

      var client = http.Client();
      await client.post(Uri.parse(url),
          headers: header, body: json.encode(request));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<User?> updateCurrentUser(User user, {id}) async {
    if (id == null) {
      return await firestore
          .collection(USERS)
          .doc(user.userID)
          .set(user.toJson())
          .then((document) {
        return user;
      });
    } else {
      return await firestore
          .collection(USERS)
          .doc(id)
          .set(user.toJson())
          .then((document) {
        return user;
      });
    }
  }

  static Future<void> updateCurrentUserAddress(AddressModel userAddress) async {
    return await firestore
        .collection(USERS)
        .doc(MyApp.currentUser!.userID)
        .update(
      {"shippingAddress": userAddress.toJson()},
    ).then((document) {});
  }

  static Future<void> updateCurrentUserAddress2(
      AddressModel userAddress) async {
    return await firestore
        .collection(USERS)
        .doc(MyApp.currentUser!.userID)
        .update(
      {"shippingAddress2": userAddress.toJson()},
    ).then((document) {});
  }

  static Future<ProductModel?> updateProduct(ProductModel prodduct) async {
    return await firestore
        .collection(PRODUCTS)
        .doc(prodduct.id)
        .set(prodduct.toJson())
        .then((document) {
      return prodduct;
    });
  }

  static Future<RatingModel?> updateReviewbyId(
      RatingModel ratingproduct) async {
    return await firestore
        .collection(Order_Rating)
        .doc(ratingproduct.id)
        .set(ratingproduct.toJson())
        .then((document) {
      return ratingproduct;
    });
  }

  static Future<VendorModel?> updateVendor(VendorModel vendor) async {
    return await firestore
        .collection(VENDORS)
        .doc(vendor.id)
        .set(vendor.toJson())
        .then((document) {
      return vendor;
    });
  }

  static Future<String> uploadUserImageToFireStorage(
      File image, String userID) async {
    Reference upload = storage.child('images/$userID.png');

    UploadTask uploadTask = upload.putFile(image);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }
}
