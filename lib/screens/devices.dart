// // lib/screens/devices.dart

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class DevicesScreen extends StatefulWidget {
//   const DevicesScreen({super.key});

//   @override
//   State<DevicesScreen> createState() => _DevicesScreenState();
// }

// class _DevicesScreenState extends State<DevicesScreen> {
//   // Initial location (e.g., user's current location)
//   static const LatLng _initialPosition = LatLng(37.42796133580664, -122.085749655962);
  
//   // Example device locations
//   final List<LatLng> _deviceLocations = [
//     LatLng(37.42796133580664, -122.085749655962),
//     LatLng(37.42496133180663, -122.081743655960),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return GoogleMap(
//       initialCameraPosition: const CameraPosition(
//         target: _initialPosition,
//         zoom: 14.0,
//       ),
//       markers: _deviceLocations
//           .map((location) => Marker(
//                 markerId: MarkerId(location.toString()),
//                 position: location,
//                 infoWindow: const InfoWindow(title: 'Device Location'),
//               ))
//           .toSet(),
//       myLocationEnabled: true,
//       myLocationButtonEnabled: true,
//       zoomControlsEnabled: false,
//     );
//   }
// }


// lib/screens/devices.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  GoogleMapController? _mapController;

  // Initial location (e.g., user's current location)
  static const LatLng _initialPosition = LatLng(37.42796133580664, -122.085749655962);

  // Example device locations
  final List<LatLng> _deviceLocations = [
    const LatLng(37.42796133580664, -122.085749655962),
    const LatLng(37.42496133180663, -122.081743655960),
  ];

  // Example device names
  final List<String> _deviceNames = [
    'iPhone 12',
    'iPad Pro',
  ];

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) => _mapController = controller,
      initialCameraPosition: const CameraPosition(
        target: _initialPosition,
        zoom: 14.0,
      ),
      markers: _createMarkers(),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    );
  }

  Set<Marker> _createMarkers() {
    Set<Marker> markers = {};

    for (int i = 0; i < _deviceLocations.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('device_$i'),
          position: _deviceLocations[i],
          infoWindow: InfoWindow(
            title: _deviceNames[i],
            snippet: 'Last seen: ${_deviceLocations[i]}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    return markers;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
