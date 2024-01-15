import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:place_picker/place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_talab_user/app/modules/changeaddress_module/changeaddress_controller.dart';

import '../../../main.dart';
import '../../data/model/AddressModel.dart';
import '../../data/model/User.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../home_module/hoome__page.dart';
import 'changeaddress_page.dart';

class addAddressScreen2 extends StatefulWidget {
  static const kInitialPosition = LatLng(-33.8567844, 151.213108);

  final double latitude2;
  final double longitude2;
  final String city2;
  final String country2;
  final String addressname2;

  const addAddressScreen2({
    Key? key,
    required this.latitude2,
    required this.longitude2,
    required this.city2,
    required this.country2,
    required this.addressname2,
  }) : super(key: key);

  @override
  _addAddressScreen2State createState() => _addAddressScreen2State();
}

class _addAddressScreen2State extends State<addAddressScreen2> {
  final _formKey = GlobalKey<FormState>();

  // String? line1, line2, zipCode, city;
  String? country;
  var street = TextEditingController();
  final TextEditingController type2Controller = TextEditingController();

  var street1 = TextEditingController();
  var landmark = TextEditingController();
  var landmark1 = TextEditingController();
  var zipcode = TextEditingController();
  var zipcode1 = TextEditingController();
  TextEditingController city2Controller = TextEditingController();
  var addressname = TextEditingController();
  var addressname1 = TextEditingController();
  var city1 = TextEditingController();
  var cutries = TextEditingController();
  var lat2 = 0.0;
  var long2 = 0.0;

  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    if (MyApp.currentUser != null) {
      if (MyApp.currentUser!.shippingAddress.country != '') {
        country = country;
      }
      addressname.text = ChangeaddressController().address2.value.addressname;
      street.text = ChangeaddressController().address2.value.line1;
      landmark.text = ChangeaddressController().address2.value.line2;
      zipcode.text = ChangeaddressController().address2.value.postalCode;
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Change Address'.tr,
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
              child: Column(children: [
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
                            controller: type2Controller,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.next,
                            validator: validateEmptyField,
                            // onSaved: (text) => line1 = text,
                            onSaved: (text) => addressname.text = text!,
                            style: const TextStyle(fontSize: 18.0),
                            keyboardType: TextInputType.streetAddress,
                            cursorColor: Color(COLOR_PRIMARY),
                            // initialValue:
                            //     MyApp.currentUser!.shippingAddress.line1,
                            decoration: InputDecoration(
                              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                              labelText: "Type".tr,
                              hintText: "Home / University / Work",
                              labelStyle: const TextStyle(
                                  color: Color(0Xff696A75),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                              hintStyle: TextStyle(color: Colors.grey.shade400),
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
                                borderSide:
                                    BorderSide(color: Color(0XFFB1BCCA)),
                                // borderRadius: BorderRadius.circular(8.0),
                              ),
                            )),
                      ),
                      Container(
                        padding: const EdgeInsetsDirectional.only(
                            start: 20, end: 20, bottom: 10),
                        child: TextFormField(
                            // controller: street,
                            controller: city2Controller,
                            enabled: city2Controller.text.isEmpty,
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.next,
                            validator: validateEmptyField,
                            // onSaved: (text) => line1 = text,
                            onSaved: (text) => city2Controller.text = text!,
                            style: const TextStyle(fontSize: 18.0),
                            keyboardType: TextInputType.streetAddress,
                            cursorColor: Color(COLOR_PRIMARY),
                            // initialValue:
                            //     MyApp.currentUser!.shippingAddress.line1,
                            decoration: InputDecoration(
                              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                              labelText: 'City'.tr,
                              labelStyle: const TextStyle(
                                  color: Color(0Xff696A75),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                              hintStyle: TextStyle(color: Colors.grey.shade400),
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
                                borderSide:
                                    BorderSide(color: Color(0XFFB1BCCA)),
                                // borderRadius: BorderRadius.circular(8.0),
                              ),
                            )),
                      ),
                      Container(
                        padding: const EdgeInsetsDirectional.only(
                            start: 20, end: 20, bottom: 10),
                        child: TextFormField(
                          // controller: _controller,
                          controller: landmark1,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.next,
                          validator: validateEmptyField,
                          onSaved: (text) => landmark1.text = text!,
                          style: const TextStyle(fontSize: 18.0),
                          keyboardType: TextInputType.streetAddress,
                          cursorColor: Color(COLOR_PRIMARY),
                          // initialValue:
                          //     MyApp.currentUser!.shippingAddress.line2,
                          decoration: InputDecoration(
                            // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                            labelText: 'Description'.tr,
                            labelStyle: const TextStyle(
                                color: Color(0Xff696A75),
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            hintStyle: TextStyle(color: Colors.grey.shade400),
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
                        ),
                      ),
                      const SizedBox(height: 50)
                    ],
                  ),
                ),
              ]))),
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
                    name: type2Controller.text,
                    city: widget.city2,
                    country: widget.country2,
                    email: MyApp.currentUser!.email,
                    line2: landmark1.text,
                    addressname: widget.addressname2,
                    location: MyApp.currentUser!.location = UserLocation(
                      latitude: widget.latitude2,
                      longitude: widget.longitude2,
                    ));


                changeaddressController.address2.value=userAddress;

                MyApp.currentUser!.shippingAddress=changeaddressController.address2.value;
                changeaddressController.homecontroller
                    .updatecurrentLocation(addressname.text);

                changeaddressController.changeSelectedValue(1);
                changeaddressController.selectedAddressIndex.value = 1;
                changeaddressController.update();
                changeaddressController.homecontroller
                    .updatecurrentLocation(type2Controller.text);
                changeaddressController.getAddressFromSharedPreferencese();
                const CircularProgressIndicator();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setInt('myIntKey', 1);
                Get.off(home_Page());
              } else {
                _autoValidateMode = AutovalidateMode.onUserInteraction;
              }
            },
            child: Text(
              'DONE'.tr,
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
    city2Controller.text = widget.city2;
  }

  saveAddress() {
    AddressModel userAddress = AddressModel(
        name: type2Controller.text,
        city: widget.city2,
        country: widget.country2,
        email: MyApp.currentUser!.email,
        line2: landmark1.text,
        addressname: widget.addressname2,
        location: MyApp.currentUser!.location = UserLocation(
          latitude: widget.latitude2,
          longitude: widget.longitude2,
        ));

    changeaddressController.saveAddressToSharedPreferences2(userAddress);
  }

  Future<void> uploadDataToFirebase() async {
    AddressModel userAddress = AddressModel(
        name: type2Controller.text,
        city: widget.city2,
        country: widget.country2,
        email: MyApp.currentUser!.email,
        line2: landmark1.text,
        addressname: widget.addressname2,
        location: MyApp.currentUser!.location = UserLocation(
          latitude: widget.latitude2,
          longitude: widget.longitude2,
        ));
    await FireStoreUtils.updateCurrentUserAddress2(userAddress);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isDarkMode() ? Colors.black : Colors.white,
        content:
            Text("The Second address data has been uploaded successfully.".tr),
      ),
    );
  }
// Future<void> uploadDataToFirebase() async {
//   String countryValue = country ?? 'Palestine';
//   if (countryValue.isEmpty) {
//     countryValue = 'Palestine';
//   }
//   MyApp.currentUser!.location = UserLocation(
//     latitude: lat2,
//     longitude: long2,
//   );
//   AddressModel userAddress = AddressModel(
//     addressname: addressname.text,
//     name: MyApp.currentUser!.fullName(),
//     // postalCode: zipcode.text,
//     line1: street.text,
//     line2: landmark.text,
//     country: cutries.text,
//     city: city2Controller.text,
//     location: MyApp.currentUser!.location,
//     email: MyApp.currentUser!.email,
//   );
//
//   await FireStoreUtils.updateCurrentUserAddress(userAddress);
//   hideProgress();
//   hideProgress();
//
//
//   ScaffoldMessenger.of(context).showSnackBar(
//
//     SnackBar(
//       backgroundColor: isDarkMode() ? Colors.black : Colors.white,
//       content: Text('Data uploaded successfully.'),
//     ),
//   );
// }
//
// validateForm() async {
//   if (_formKey.currentState?.validate() ?? false) {
//     _formKey.currentState!.save();
//     {
//       if (MyApp.currentUser != null) {
//         if (MyApp.currentUser!.shippingAddress.location.latitude == 0 && MyApp.currentUser!.shippingAddress.location.longitude == 0) {
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
//             addressname: addressname.text,
//             name: MyApp.currentUser!.fullName(),
//             postalCode: zipcode.text,
//             line1: street.text,
//             line2: landmark.text,
//             country: cutries.text,
//             city: city.text,
//             location: MyApp.currentUser!.location,
//             email: MyApp.currentUser!.email);
//         MyApp.currentUser!.shippingAddress = userAddress;
//         await FireStoreUtils.updateCurrentUserAddress2(userAddress);
//         hideProgress();
//         hideProgress();
//       }
//       MyApp.selectedPosotion = Position.fromMap({'latitude': lat, 'longitude': long});
//
//       String passAddress = street.text.toString() + ", " + landmark.text.toString() + ", " + city.text.toString() + ", " + zipcode.text.toString() + ", " + cutries.text.toString();
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
*             // ListTile(
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
                          //     style: TextStyle(fontSize: 18.0),
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
                          Container(
                              padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10),
                              child: TextFormField(
                                controller: city1.text.isEmpty ? city : city1,
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.next,
                                validator: validateEmptyField,
                                onSaved: (text) => city.text = text!,
                                style: TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.streetAddress,
                                cursorColor: Color(COLOR_PRIMARY),
                                // initialValue:
                                //     MyApp.currentUser!.shippingAddress.city,
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                  labelText: 'City'.tr,
                                  labelStyle: TextStyle(color: Color(0Xff696A75), fontSize: 17),
                                  hintStyle: TextStyle(color: Colors.grey.shade400),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                                  ),
                                  errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).errorColor),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).errorColor),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                                    // borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              )),

                          // Container(
                          //     padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10),
                          //     child: TextFormField(
                          //       controller: cutries1.text.isEmpty ? cutries : cutries1,
                          //       textAlignVertical: TextAlignVertical.center,
                          //       textInputAction: TextInputAction.next,
                          //       validator: validateEmptyField,
                          //       onSaved: (text) => cutries.text = text!,
                          //       style: TextStyle(fontSize: 18.0),
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
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Card(
                                child: ListTile(
                                    leading: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // ImageIcon(
                                        //   AssetImage('assets/images/current_location1.png'),
                                        //   size: 23,
                                        //   color: Color(COLOR_PRIMARY),
                                        // ),
                                        Icon(
                                          Icons.location_searching_rounded,
                                          color: Color(COLOR_PRIMARY),
                                        ),
                                      ],
                                    ),
                                    title: Text(
                                      "Current Location".tr,
                                      style: TextStyle(color: Color(COLOR_PRIMARY)),
                                    ),
                                    subtitle: Text(
                                      "Using GPS".tr,
                                      style: TextStyle(color: Color(COLOR_PRIMARY)),
                                    ),
                                    onTap: () async {
                                      LocationResult result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => PlacePicker(GOOGLE_API_KEY)));

                                      street1.text = result.name.toString();
                                      landmark1.text = result.subLocalityLevel1!.name == null ? result.subLocalityLevel2!.name.toString() : result.subLocalityLevel1!.name.toString();
                                      city1.text = result.city!.name.toString();
                                      cutries1.text = result.country!.name.toString();
                                      zipcode1.text = result.postalCode.toString();
                                      lat = result.latLng!.latitude;
                                      long = result.latLng!.longitude;

                                      setState(() {});
                                    })),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                'or'.tr,

                                style: TextStyle(
                                    color: Color(COLOR_PRIMARY),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    letterSpacing: 1),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(15), backgroundColor: Color(COLOR_PRIMARY),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),

                              ),
                            ),
                            onPressed: () =>  Get.to(Add_NewAddress2()),
                            child: Text(
                              'Choose your state'.tr,
                              style: TextStyle(color: isDarkMode() ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          SizedBox(height: double.maxFinite)*/
