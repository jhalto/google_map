import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController extends GetxController{

   @override
     void onInit(){
    
    super.onInit();
    marker.addAll(list);
    determinePosition();
   }
   Position? position;

  List<Marker> marker = [];
  List<Marker> list = [
    Marker(markerId: MarkerId('1'),
    position:LatLng(23.7619, 90.4331),
    infoWindow: InfoWindow(
      title: "loaction position 1",
      snippet: "sdf"
    )
    ),
    Marker(markerId: MarkerId('2'),
    position:LatLng(24.7619, 90.4331),
    infoWindow: InfoWindow(
      title: "loaction position 2",
      snippet: "sdfer"
    )
    )
  ];
  Completer<GoogleMapController> controller = Completer();

   final CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(24.7619, 90.4331),
    zoom: 12.23,
    );


    //current position
   
   Future<void> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  position = await Geolocator.getCurrentPosition();
  print("lat = ${position!.latitude.toString()} and longitude is ${position!.latitude.toString()}");
}
}  