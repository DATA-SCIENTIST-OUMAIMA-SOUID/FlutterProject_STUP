import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:map_location_picker/map_location_picker.dart';

import '../../../main.dart';
import '../../data/model/AddressModel.dart';
import '../../data/model/User.dart';
import '../../data/services/FirebaseHelper.dart';
import '../../data/services/helper.dart';
import '../../utils/constants.dart';
import '../shared/componants/custom_Button.dart';
import 'add_address2.dart';

class Other2Screen extends StatefulWidget {
  // Default location coordinates
  late LatLng initialPosition;

  Other2Screen({super.key, required this.initialPosition});

  @override
  State<Other2Screen> createState() => _OtherScreenState();
}

class _OtherScreenState extends State<Other2Screen> {
  late GoogleMapController mapController;

  late Marker marker;
  late LatLng currentPosition;
  String streetName = '';
  String city = '';
  String country = '';
  String addressname = '';
  String email = "";
  String type = "";
  AddressModel userAddressss = AddressModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose your state"),
        leading: IconButton(
          color: isDarkMode() ? Colors.black : Color(COLOR_PRIMARY),
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Column(children: [
        Expanded(
          child: GoogleMap(
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              initialCameraPosition: CameraPosition(
                target: widget.initialPosition,
                zoom: 18.0,
              ),
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
              }
              // {
              //   Marker(
              //     markerId: MarkerId('currentLocation'),
              //     position: widget.initialPosition,
              //   ),
              // },
              ),
        ),
        Container(
          color: isDarkMode() ? null : const Color(0XFFF1F4F7),
          child: Padding(
            padding: const EdgeInsets.only(right: 100.0, left: 100, bottom: 15),
            child: CustomButton(
                text: 'Done',
                onPress: () async {
                  await uploadDataToFirebase();
                  const CircularProgressIndicator();
                  Get.off(() => addAddressScreen2(
                      latitude2: widget.initialPosition.latitude,
                      longitude2: widget.initialPosition.longitude,
                      city2: city,
                      country2: country,
                      addressname2: addressname));

                  print(
                      " name: $type, city: $city, addressname:$addressname ,email: ${MyApp.currentUser!.email}");
                },
                color: Color(COLOR_PRIMARY)),
          ),
        ),
      ]),
    );
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Location permissions are denied
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the current position of the device
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  void initState() {
    super.initState();
    currentPosition = LatLng(
        widget.initialPosition.latitude, widget.initialPosition.longitude);

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
            city = placemark.locality ?? '';
            country = placemark.country ?? countryValue;
            addressname = placemark.name ?? '';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            streetName = '';
            city = '';
            country = ' ';
            addressname = '';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          streetName = '';
          city = '';
          country = ' ';
          addressname = '';
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
        city: city,
        country: countryValue,
        addressname: addressname,
        email: MyApp.currentUser!.email,
        location: MyApp.currentUser!.location = UserLocation(
          latitude: widget.initialPosition.latitude,
          longitude: widget.initialPosition.longitude,
        ));

    await FireStoreUtils.updateCurrentUserAddress2(userAddress);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isDarkMode() ? Colors.black : Colors.white,
        content: const Text('Data uploaded successfully.'),
      ),
    );
  }
}
