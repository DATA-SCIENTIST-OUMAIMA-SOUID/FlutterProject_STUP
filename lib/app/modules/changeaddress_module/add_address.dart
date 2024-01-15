import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:place_picker/place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_talab_user/app/modules/changeaddress_module/changeaddress_controller.dart';
import 'package:super_talab_user/app/modules/profile_module/profile_page.dart';

import '../../../main.dart';
import '../../data/model/AddressModel.dart';
import '../../data/model/User.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../home_module/hoome__page.dart';
import 'changeaddress_page.dart';

class addAddressScreen extends StatefulWidget {
  static const kInitialPosition = LatLng(-33.8567844, 151.213108);
  final double latitude;
  final double longitude;
  final String city;
  final String country;
  final String addressname;

  const addAddressScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    required this.addressname,
  }) : super(key: key);

  @override
  _addAddressScreenState createState() => _addAddressScreenState();
}

class _addAddressScreenState extends State<addAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // String? line1, line2, zipCode, city;
  String? country;

  var street = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  var street1 = TextEditingController();
  var landmark = TextEditingController();
  var landmark1 = TextEditingController();
  var zipcode = TextEditingController();
  var zipcode1 = TextEditingController();
  TextEditingController cityController = TextEditingController();
  var addressname = TextEditingController();
  var addressname1 = TextEditingController();
  var city1 = TextEditingController();
  var cutries = TextEditingController();
  var cutries1 = TextEditingController();
  var lat = 0.0;
  var long = 0.0;

  AutovalidateMode _autoValidateMode = AutovalidateMode.always;

  @override
  Widget build(BuildContext context) {
    Get.put(changeaddressController());

    if (MyApp.currentUser != null) {
      if (MyApp.currentUser!.shippingAddress.country != '') {
        country = country;
      }
      addressname.text = ChangeaddressController().address1.value.name;
      street.text = ChangeaddressController().address1.value.line1;
      landmark.text = ChangeaddressController().address1.value.line2;
      zipcode.text = ChangeaddressController().address1.value.postalCode;
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Address'.tr,
            style: TextStyle(color: isDarkMode() ? Colors.white : Colors.black),
          ),
          leading: GestureDetector(
            onTap: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor:
                      isDarkMode() ? null : const Color(0XFFF1F4F7),
                  content: const Text('Please fill all required fields.'),
                  duration: const Duration(seconds: 2),
                ));
              }
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Color(COLOR_PRIMARY),
            ),
          )),
      body: Container(
        color: isDarkMode() ? null : const Color(0XFFF1F4F7),
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidateMode,
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              Card(
                elevation: 0.5,
                color: isDarkMode()
                    ? const Color(DARK_BG_COLOR)
                    : const Color(0XFFFFFFFF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsetsDirectional.only(
                          start: 20, end: 20, bottom: 10),
                      child: TextFormField(
                          // controller: street,
                          controller: typeController,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.next,
                          validator: validateEmptyField,
                          // onSaved: (text) => line1 = text,
                          onSaved: (text) => addressname.text = text!,
                          style: TextStyle(
                              color: isDarkMode() ? Colors.white : Colors.black,
                              fontSize: 18.0),
                          keyboardType: TextInputType.streetAddress,
                          cursorColor: Color(COLOR_PRIMARY),
                          // initialValue:
                          //     MyApp.currentUser!.shippingAddress.line1,
                          decoration: InputDecoration(
                            // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                            labelText: "Type".tr,
                            hintText: "Home / University / Work".tr,
                            labelStyle: const TextStyle(
                                color: Color(0Xff696A75), fontSize: 17),
                            hintStyle: TextStyle(
                                color:
                                    isDarkMode() ? Colors.white : Colors.grey,
                                fontSize: 17),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(COLOR_PRIMARY)),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                              // borderRadius: BorderRadius.circular(8.0),
                            ),
                          )),
                    ),
                    Container(
                        padding: const EdgeInsetsDirectional.only(
                            start: 20, end: 20, bottom: 10),
                        child: TextFormField(
                          controller: cityController,
                          enabled: cityController.text.isEmpty,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.next,
                          validator: validateEmptyField,
                          onSaved: (text) => cityController.text = text!,
                          style: TextStyle(
                              color: isDarkMode() ? Colors.white : Colors.black,
                              fontSize: 18.0),

                          keyboardType: TextInputType.streetAddress,
                          cursorColor: Color(COLOR_PRIMARY),
                          // initialValue:
                          //     MyApp.currentUser!.shippingAddress.city,
                          decoration: InputDecoration(
                            // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                            labelText: 'City'.tr,
                            labelStyle: const TextStyle(
                                color: Color(0Xff696A75), fontSize: 19),
                            hintStyle: TextStyle(
                              color: isDarkMode() ? Colors.white : Colors.grey,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(COLOR_PRIMARY)),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                              // borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        )),
                    Container(
                      padding: const EdgeInsetsDirectional.only(
                          start: 20, end: 20, bottom: 10),
                      child: TextFormField(
                        // controller: _controller,
                        controller: landmark,
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.next,
                        validator: validateEmptyField,
                        onSaved: (text) => landmark.text = text!,
                        style: TextStyle(
                            color: isDarkMode() ? Colors.white : Colors.black,
                            fontSize: 18.0),

                        keyboardType: TextInputType.streetAddress,
                        cursorColor: Color(COLOR_PRIMARY),
                        // initialValue:
                        //     MyApp.currentUser!.shippingAddress.line2,
                        decoration: InputDecoration(
                          // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                          labelText: 'Description'.tr,
                          labelStyle: const TextStyle(
                              color: Color(0Xff696A75), fontSize: 17),
                          hintStyle: TextStyle(
                            color: isDarkMode() ? Colors.white : Colors.grey,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                            // borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50)
                  ],
                ),
              ),
              //SizedBox(height: double.maxFinite)
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: isDarkMode() ? null : const Color(0XFFF1F4F7),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(15),
              backgroundColor: Color(COLOR_PRIMARY),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                var changeaddressController =
                    Get.put(ChangeaddressController());
                _formKey.currentState!.save();
                if (MyApp.currentUser!.userID != '') {
                  await uploadDataToFirebase();
                }
                saveAddress();
                AddressModel userAddress = AddressModel(
                    name: typeController.text,
                    city: widget.city,
                    country: widget.country,
                    email: MyApp.currentUser!.email,
                    line1: landmark.text,
                    addressname: widget.addressname,
                    location: MyApp.currentUser!.location = UserLocation(
                      latitude: widget.latitude,
                      longitude: widget.longitude,
                    ));

                changeaddressController.address1.value = userAddress;
                changeaddressController.homecontroller.getAddressFromFirebase();

                changeaddressController.changeSelectedValue(0);
                changeaddressController.selectedAddressIndex.value = 0;
                changeaddressController.update();
                print("object");
                print(addressname.text);

                changeaddressController.homecontroller
                    .updatecurrentLocation(typeController.text);
                print("object444");
                print(typeController.text);

                print(changeaddressController.homecontroller.currentLocation);

                const CircularProgressIndicator();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setInt('myIntKey', 0);
                setState(() {});

                Get.off(() => home_Page());
              } else {
                _autoValidateMode = AutovalidateMode.onUserInteraction;
              }
            },
            child: Text(
              'Done'.tr,
              style: TextStyle(
                  color: isDarkMode() ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  changeaddressController ChangeaddressController() => Get.find();

  @override
  void dispose() {
    street.dispose();
    landmark.dispose();
    // cutries.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    cityController.text = widget.city;
  }

  saveAddress() {
    AddressModel userAddress = AddressModel(
        name: typeController.text,
        city: widget.city,
        country: widget.country,
        email: MyApp.currentUser!.email,
        line1: landmark.text,
        addressname: widget.addressname,
        location: MyApp.currentUser!.location = UserLocation(
          latitude: widget.latitude,
          longitude: widget.longitude,
        ));

    changeaddressController.saveAddressToSharedPreferences(userAddress);
  }

  Future<void> uploadDataToFirebase() async {
    AddressModel userAddress = AddressModel(
        name: typeController.text,
        city: widget.city,
        country: widget.country,
        email: MyApp.currentUser!.email,
        line1: landmark.text,
        addressname: widget.addressname,
        location: MyApp.currentUser!.location = UserLocation(
          latitude: widget.latitude,
          longitude: widget.longitude,
        ));

    await FireStoreUtils.updateCurrentUserAddress(userAddress);
  }

// Future<void> uploadDataToFirebase() async {
//   String countryValue = country ?? 'Palestine';
//   if (countryValue.isEmpty) {
//     countryValue = 'Palestine';
//   }
//   // MyApp.currentUser!.location = UserLocation(
//   //   latitude: currentPosition!.latitude,
//   //   longitude:  currentPosition!.longitude,
//   // );
//   AddressModel userAddress = AddressModel(
//     // addressname: addressname.text,
//     name: typeController.text,
//     // postalCode: zipcode.text,
//     // line1: street.text,
//     // line2: landmark.text,
//     // country: cutries.text,
//     // city: city.text,
//     // location: MyApp.currentUser!.location = UserLocation(
//     //   latitude: widget.latitude,
//     //   longitude: widget.longitude,
//     // ),
//     // email: MyApp.currentUser!.email,
//
//   );
//
//
//
//
//
//
//
//
//   await FireStoreUtils.updateCurrentUserAddress(userAddress);
//
//
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       backgroundColor: isDarkMode() ? Colors.black : Colors.white,
//       content: Text('Data uploaded successfully.'),
//     ),
//   );
// }

// validateForm() async {
//   if (_formKey.currentState?.validate() ?? false) {
//     _formKey.currentState!.save();
//     {
//       if (MyApp.currentUser != null) {
//         if (MyApp.currentUser!.shippingAddress.location.latitude == 0 &&
//             MyApp.currentUser!.shippingAddress.location.longitude == 0) {
//           if (lat == 0 && long == 0) {
//             showDialog(
//                 barrierDismissible: false,
//                 context: context,
//                 builder: (_) {
//                   return AlertDialog(
//                     content: Text("selectGPSLocation".tr),
//                     actions: [
//                       TextButton(
//                         onPressed: () {
//                           hideProgress();
//                           Navigator.pop(context, true);
//                         }, // passing true
//                         child: Text('OK'.tr),
//                       ),
//                     ],
//                   );
//                 }).then((exit) {
//               if (exit == null) return;
//
//               if (exit) {
//                 // user pressed Yes button
//               } else {
//                 // user pressed No button
//               }
//             });
//           }
//         } else {
//           if (lat == null || long == null || (lat == 0 && long == 0)) {
//             lat = MyApp.currentUser!.shippingAddress.location.latitude;
//             long = MyApp.currentUser!.shippingAddress.location.longitude;
//           }
//         }
//
//         Get.defaultDialog(
//             title: "Updating Address".tr,
//             content: Column(
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text("Please wait...".tr)
//               ],
//             ));
//         MyApp.currentUser!.location = UserLocation(
//           latitude: lat,
//           longitude: long,
//         );
//         AddressModel userAddress = AddressModel(
//           addressname: addressname.text,
//           name: MyApp.currentUser!.fullName(),
//           // postalCode: zipcode.text,
//           line1: street.text,
//           line2: landmark.text,
//           country: cutries.text,
//           city: city.text,
//           location: MyApp.currentUser!.location,
//           email: MyApp.currentUser!.email,
//         );
//         MyApp.currentUser!.shippingAddress = userAddress;
//         await FireStoreUtils.updateCurrentUserAddress(userAddress);
//         hideProgress();
//         hideProgress();
//       }
//       MyApp.selectedPosotion =
//           Position.fromMap({'latitude': lat, 'longitude': long});
//
//       String passAddress = street.text.toString() +
//           ", " +
//           landmark.text.toString() +
//           ", " +
//           city.text.toString() +
//           ", " +
//           zipcode.text.toString() +
//           ", " +
//           cutries.text.toString();
//       Navigator.pop(context, passAddress);
//     }
//   } else {
//     setState(() {
//       _autoValidateMode = AutovalidateMode.onUserInteraction;
//     });
//   }
// }
}
/*
*
*   // ListTile(
                    //   contentPadding:
                    //       const EdgeInsetsDirectional.only(start: 40, end: 30, top: 24),
                    //   leading: Container(
                    //     // width: 0,
                    //     child: Text(
                    //       'Zip Code'.tr,
                    //       style: TextStyle(fontSize: 16),
                    //     ),
                    //   ),
                    // ),
                    // Container(
                    //   padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10),
                    //   child: TextFormField(
                    //     controller: zipcode1.text.isEmpty ? zipcode : zipcode1,
                    //     textAlignVertical: TextAlignVertical.center,
                    //     textInputAction: TextInputAction.next,
                    //     validator: validateEmptyField,
                    //     onSaved: (text) => zipcode.text = text!,
                    //                                     style: TextStyle(color: isDarkMode()?Colors.white:Colors.black ,fontSize: 18.0),
                    //
                    //     keyboardType: TextInputType.phone,
                    //     cursorColor: Color(COLOR_PRIMARY),
                    //     // initialValue: MyApp
                    //     //     .currentUser!.shippingAddress.postalCode,
                    //     decoration: InputDecoration(
                    //       // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    //       labelText: 'Zip Code'.tr,
                    //       labelStyle: TextStyle(color: Color(0Xff696A75), fontSize: 17),
                    //       hintStyle: TextStyle(color: Colors.grey.shade400),
                    //       focusedBorder: UnderlineInputBorder(
                    //         borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                    //       ),
                    //       errorBorder: UnderlineInputBorder(
                    //         borderSide: BorderSide(color: Theme.of(context).errorColor),
                    //         borderRadius: BorderRadius.circular(8.0),
                    //       ),
                    //       focusedErrorBorder: UnderlineInputBorder(
                    //         borderSide: BorderSide(color: Theme.of(context).errorColor),
                    //         borderRadius: BorderRadius.circular(8.0),
                    //       ),
                    //       enabledBorder: UnderlineInputBorder(
                    //         borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                    //         // borderRadius: BorderRadius.circular(8.0),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // ListTile(
                    //   contentPadding:
                    //       const EdgeInsetsDirectional.only(start: 40, end: 30, top: 24),
                    //   leading: Container(
                    //     // width: 0,
                    //     child: Text(
                    //       'City'.tr,
                    //       style: TextStyle(fontSize: 16),
                    //     ),
                    //   ),
                    // ),

                    // Container(
                    //     padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10),
                    //     child: TextFormField(
                    //       controller: cutries1.text.isEmpty ? cutries : cutries1,
                    //       textAlignVertical: TextAlignVertical.center,
                    //       textInputAction: TextInputAction.next,
                    //       validator: validateEmptyField,
                    //       onSaved: (text) => cutries.text = text!,
                    //                                       style: TextStyle(color: isDarkMode()?Colors.white:Colors.black ,fontSize: 18.0),
                    //
                    //       keyboardType: TextInputType.streetAddress,
                    //       cursorColor: Color(COLOR_PRIMARY),
                    //       // initialValue:
                    //       //     MyApp.currentUser!.shippingAddress.city,
                    //       decoration: InputDecoration(
                    //         // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    //         labelText: 'Country'.tr,
                    //         labelStyle: TextStyle(color: Color(0Xff696A75), fontSize: 17),
                    //         hintStyle: TextStyle(color: Colors.grey.shade400),
                    //         focusedBorder: UnderlineInputBorder(
                    //           borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                    //         ),
                    //         errorBorder: UnderlineInputBorder(
                    //           borderSide: BorderSide(color: Theme.of(context).errorColor),
                    //           borderRadius: BorderRadius.circular(8.0),
                    //         ),
                    //         focusedErrorBorder: UnderlineInputBorder(
                    //           borderSide: BorderSide(color: Theme.of(context).errorColor),
                    //           borderRadius: BorderRadius.circular(8.0),
                    //         ),
                    //         enabledBorder: UnderlineInputBorder(
                    //           borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                    //           // borderRadius: BorderRadius.circular(8.0),
                    //         ),
                    //       ),
                    //     )),

                    // Padding(
                    //   padding: const EdgeInsets.all(12.0),
                    //   child: Card(
                    //       child: ListTile(
                    //           leading: Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               // ImageIcon(
                    //               //   AssetImage('assets/images/current_location1.png'),
                    //               //   size: 23,
                    //               //   color: Color(COLOR_PRIMARY),
                    //               // ),
                    //               Icon(
                    //                 Icons.location_searching_rounded,
                    //                 color: Color(COLOR_PRIMARY),
                    //               ),
                    //             ],
                    //           ),
                    //           title: Text(
                    //             "Current Location".tr,
                    //             style: TextStyle(color: Color(COLOR_PRIMARY)),
                    //           ),
                    //           subtitle: Text(
                    //             "Using GPS".tr,
                    //             style: TextStyle(color: Color(COLOR_PRIMARY)),
                    //           ),
                    //           onTap: () async {
                    //             LocationResult result =
                    //                 await Navigator.of(context).push(
                    //                     MaterialPageRoute(
                    //                         builder: (context) =>
                    //                             PlacePicker(GOOGLE_API_KEY)));
                    //
                    //             street1.text = result.name.toString();
                    //             landmark1.text = result.subLocalityLevel1!.name == null ? result.subLocalityLevel2!.name.toString(): result.subLocalityLevel1!.name.toString();
                    //             city1.text = result.city!.name.toString();
                    //             cutries1.text = result.country!.name.toString();
                    //             zipcode1.text = result.postalCode.toString();
                    //             lat = result.latLng!.latitude;
                    //             long = result.latLng!.longitude;
                    //
                    //             setState(() {});
                    //           })),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.all(20.0),
                    //   child: Center(
                    //     child: Text(
                    //       'or'.tr,
                    //
                    //       style: TextStyle(
                    //           color: Color(COLOR_PRIMARY),
                    //           fontWeight: FontWeight.bold,
                    //           fontSize: 15,
                    //           letterSpacing: 1),
                    //     ),
                    //   ),
                    // ),
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     padding: const EdgeInsets.all(15), backgroundColor: Color(COLOR_PRIMARY),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //
                    //     ),
                    //   ),
                    //   onPressed: () =>  Get.to(Add_NewAddress()),
                    //   child: Text(
                    //     'Choose your state'.tr,
                    //     style: TextStyle(color: isDarkMode() ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    //   ),
                    // ),*/

/*
*                     // Container(
                    //   padding: const EdgeInsetsDirectional.only(
                    //       start: 20, end: 20, bottom: 10),
                    //   child: TextFormField(
                    //       // controller: street,
                    //       controller: street1.text.isEmpty ? street : street1,
                    //       textAlignVertical: TextAlignVertical.center,
                    //       textInputAction: TextInputAction.next,
                    //       // validator: validateEmptyField,
                    //       // onSaved: (text) => line1 = text,
                    //       onSaved: (text) => street.text = text!,
                    //       style: TextStyle(
                    //           color:
                    //               isDarkMode() ? Colors.white : Colors.black,
                    //           fontSize: 18.0),
                    //       keyboardType: TextInputType.streetAddress,
                    //       cursorColor: Color(COLOR_PRIMARY),
                    //       // initialValue:
                    //       //     MyApp.currentUser!.shippingAddress.line1,
                    //       decoration: InputDecoration(
                    //         // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    //         labelText: 'Street 1'.tr,
                    //         labelStyle: TextStyle(
                    //             color: Color(0Xff696A75), fontSize: 17),
                    //         hintStyle: TextStyle(color: Colors.grey.shade400),
                    //         focusedBorder: UnderlineInputBorder(
                    //           borderSide:
                    //               BorderSide(color: Color(COLOR_PRIMARY)),
                    //         ),
                    //         errorBorder: UnderlineInputBorder(
                    //           borderSide: BorderSide(
                    //               color: Theme.of(context).errorColor),
                    //           borderRadius: BorderRadius.circular(8.0),
                    //         ),
                    //         focusedErrorBorder: UnderlineInputBorder(
                    //           borderSide: BorderSide(
                    //               color: Theme.of(context).errorColor),
                    //           borderRadius: BorderRadius.circular(8.0),
                    //         ),
                    //         enabledBorder: UnderlineInputBorder(
                    //           borderSide:
                    //               BorderSide(color: Color(0XFFB1BCCA)),
                    //           // borderRadius: BorderRadius.circular(8.0),
                    //         ),
                    //       )),
                    // ),
                    // ListTile(
                    //   contentPadding:
                    //       const EdgeInsetsDirectional.only(start: 40, end: 30, top: 24),
                    //   leading: Container(
                    //     // width: 0,
                    //     child: Text(
                    //       'Street 2'.tr,
                    //       style: TextStyle(fontSize: 16),
                    //     ),
                    //   ),
                    // ),
*/
