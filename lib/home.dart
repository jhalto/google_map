
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_map/map_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatelessWidget {
  Home({super.key});
  var mapController = Get.put(MapController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: GoogleMap(
        initialCameraPosition: mapController.kGooglePlex,
        onMapCreated: (GoogleMapController locController) {
          mapController.controller.complete(locController);
        },
        myLocationEnabled: true,
        mapType: MapType.hybrid,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        markers: Set.of(mapController.marker),
        ),
    );
  }
} 