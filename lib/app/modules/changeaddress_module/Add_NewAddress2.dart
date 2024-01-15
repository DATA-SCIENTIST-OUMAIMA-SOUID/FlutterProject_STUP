import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:super_talab_user/app/modules/shared/componants/custom_Button.dart';
import '../../../main.dart';
import '../../data/model/AddressModel.dart';
import '../../data/model/User.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../shared/componants/Custom_State_Text.dart';
import 'add_address2.dart';
import 'changeaddress_controller.dart';
import 'other_screen2.dart';

changeaddressController ChangeaddressController() => Get.find();

class Add_NewAddress2 extends StatefulWidget {
  const Add_NewAddress2({super.key});

  @override
  State<Add_NewAddress2> createState() => _Add_NewAddress2State();
}

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  String city = '';

  MapScreen(
      {super.key,
      required this.city,
      required this.latitude,
      required this.longitude});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _Add_NewAddress2State extends State<Add_NewAddress2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode() ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          "Choose your state".tr,
          style: TextStyle(
            color: isDarkMode() ? Colors.white : Colors.black,
          ),
        ),
        leading: IconButton(
          color: isDarkMode() ? Colors.black : Color(COLOR_PRIMARY),
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            Custom_State_Text(
              text: "Tubas State".tr,
              onPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                        city: "Tubas State",
                        latitude: 32.32091,
                        longitude: 35.36989),
                  ),
                );
                // openMapScreen(context, 32.32091, 35.36989);
              },
            ),
            Custom_State_Text(
              text: "Tammun State".tr,
              onPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                        city: "Tammun State",
                        latitude: 32.28311055258108,
                        longitude: 35.38576907157771),
                  ),
                );
                // openMapScreen(context, 32.28311055258108, 35.38576907157771);
              },
            ),
            Custom_State_Text(
              text: "Aqqaba State".tr,
              onPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapScreen(
                          city: "Aqqaba State",
                          latitude: 32.33775,
                          longitude: 35.416778)),
                );
                // openMapScreen(context, 29.52667, 29.52667);
              },
            ),
            Custom_State_Text(
              text: "Wadi al-Far'a State".tr,
              onPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                        city: "Wadi al-Far'a State",
                        latitude: 32.1840,
                        longitude: 35.4025),
                  ),
                );
              },
            ),
            Custom_State_Text(
              text: "Tayasir State".tr,
              onPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                        city: "Tayasir State".tr,
                        latitude: 32.339507727247096,
                        longitude: 35.39629914664163),
                  ),
                );
              },
            ),
            Custom_State_Text(
              text: "Others".tr,
              onPress: () async {
                try {
                  Position position = await getCurrentLocation();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Other2Screen(
                        initialPosition:
                            LatLng(position.latitude, position.longitude),
                      ),
                    ),
                  );
                } catch (e) {
                  // Handle errors here
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late Marker marker;
  late LatLng currentPosition;
  String streetName = '';
  String country = '';
  String addressname = '';
  String postalCode = '';
  String email = "";
  String type = "";

  User user = User();

  @override
  Widget build(BuildContext context) {
    if (country.isEmpty) {
      country = 'Palestine';
    }
    return Scaffold(
      backgroundColor: isDarkMode() ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          "Choose your state".tr,
          style: TextStyle(
            color: isDarkMode() ? Colors.white : Colors.black,
          ),
        ),
        leading: IconButton(
          color: isDarkMode() ? Colors.black : Color(COLOR_PRIMARY),
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            initialCameraPosition: CameraPosition(
              target: currentPosition,
              zoom: 18.0,
            ),
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
              });
            },
            markers: {marker},
            onTap: (position) {
              setState(() {
                currentPosition = position;
                marker = marker.copyWith(
                  positionParam: position,
                );
                updateStreetName();
              });
            },
            onCameraMove: (CameraPosition position) {
              setState(() {
                currentPosition = position.target;
                marker = marker.copyWith(
                  positionParam: position.target,
                );
                updateStreetName();
              });
            },
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () async {
                final PermissionStatus status =
                await Permission.location.request();
                if (status.isGranted) {
                  LatLng currentLocation = await getCurrentLocation();
                  setState(() {
                    currentPosition = currentLocation;
                    mapController.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: currentPosition,
                        zoom: 18.0,
                      ),
                    ));
                    updateStreetName();
                  });
                } else if (status.isDenied) {
                  // Location permission is denied by the user
                  // Handle the scenario when the user denies the location permission.
                  // You can show a message or disable location-related functionality.
                  // For example:
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Location Permission Denied'.tr),
                      content: Text('Please enable location access in app settings to use this feature.'.tr),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'.tr),
                        ),
                      ],
                    ),
                  );
                } else if (status.isPermanentlyDenied) {
                  // Location permission is permanently denied by the user
                  // Show a dialog to guide the user to app settings to enable location permission.
                  // For example:
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Location Permission Denied'),
                      content: Text('Location permission is permanently denied. Please enable it in app settings.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                        TextButton(
                          onPressed: () => openAppSettings(),
                          child: Text('Open Settings'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 100.0, right: 100, bottom: 20),
              child: CustomButton(
                  text: 'Done'.tr,
                  onPress: () async {
                    if (MyApp.currentUser!.userID != '') {
                      await uploadDataToFirebase();
                    }
                    saveAddress();
                    const CircularProgressIndicator();
                    Get.off(() => addAddressScreen2(
                        latitude2: widget.latitude,
                        longitude2: widget.longitude,
                        city2: widget.city,
                        country2: country,
                        addressname2: addressname));
                  },
                  color: Color(COLOR_PRIMARY)),
            ),
          ),
        ],
      ),
    );
  }

  Future<LatLng> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }

  @override
  void initState() {
    super.initState();
    currentPosition = LatLng(widget.latitude, widget.longitude);
    marker = Marker(
      markerId: const MarkerId('locationMarker'),
      position: currentPosition,
      draggable: true,
      onDragEnd: (newPosition) {
        setState(() {
          currentPosition = newPosition;
          updateStreetName();
        });
      },
    );
    updateStreetName();
  }

  Future<void> requestLocationPermission() async {
    final PermissionStatus status = await Permission.location.request();
    if (status.isDenied) {
      // Permission was denied, handle it accordingly (show a message, etc.).
      // You may also consider disabling location-related functionality in the app.
    } else if (status.isPermanentlyDenied) {
      // Permission is permanently denied, show a dialog or redirect the user to the app settings to grant permission manually.
    } else if (status.isGranted) {
      // Permission granted, proceed to get the current location.
    }
  }

  saveAddress() {
    String countryValue = country ?? 'Palestine';
    if (countryValue.isEmpty) {
      countryValue = 'Palestine';
    }
    AddressModel userAddress = AddressModel(
        name: type,
        city: widget.city,
        country: countryValue,
        addressname: addressname,
        postalCode: postalCode,
        email: MyApp.currentUser!.email,
        location: MyApp.currentUser!.location = UserLocation(
          latitude: widget.latitude,
          longitude: widget.longitude,
        ));

    changeaddressController.saveAddressToSharedPreferences2(userAddress);
  }

  Future<void> updateStreetName() async {
    String countryValue = country ?? 'Palestine';
    if (countryValue.isEmpty) {
      countryValue = 'Palestine';
    }
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        if (mounted) {
          setState(() {
            streetName = placemark.street ?? '';
            country = placemark.country ?? countryValue;
            addressname = placemark.name ?? '';
            postalCode = placemark.postalCode ?? '';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            streetName = '';
            country = ' ';
            addressname = '';
            postalCode = '';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          streetName = '';
          country = ' ';
          addressname = '';
          postalCode = '';
        });
      }
    }
  }

  Future<void> uploadDataToFirebase() async {
    String countryValue = country ?? 'Palestine';
    if (countryValue.isEmpty) {
      countryValue = 'Palestine';
    }
    AddressModel userAddress = AddressModel(
        name: type,
        city: widget.city,
        country: countryValue,
        addressname: addressname,
        postalCode: postalCode,
        email: MyApp.currentUser!.email,
        location: MyApp.currentUser!.location = UserLocation(
          latitude: widget.latitude,
          longitude: widget.longitude,
        ));
    await FireStoreUtils.updateCurrentUserAddress2(userAddress);
  }
}
