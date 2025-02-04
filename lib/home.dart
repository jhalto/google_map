import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
   
  Completer<GoogleMapController> _controller = Completer();

   static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(23.7619, 90.4331),
    zoom: 12.23,
    );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          
        },
        myLocationEnabled: true,
        mapType: MapType.hybrid,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        ),
    );
  }
} 