import 'dart:async';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController extends GetxController{

   @override
     void onInit(){
    
    super.onInit();
    marker.addAll(list);
  

   }
  List<Marker> marker = [];
  List<Marker> list = [
    Marker(markerId: MarkerId('1'),
    position:LatLng(23.7619, 90.4331),
    ),
    Marker(markerId: MarkerId('2'),
    position:LatLng(24.7619, 90.4331),
    )
  ];
  Completer<GoogleMapController> controller = Completer();

   final CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(24.7619, 90.4331),
    zoom: 12.23,
    );


}  