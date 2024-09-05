// import 'package:geolocator/geolocator.dart';

// class LocationService {
//   Future<Position> getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return Future.error('Location permissions are permanently denied, we cannot request permissions.');
//     }

//     return await Geolocator.getCurrentPosition();
//   }
// }

// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class LocationService {
//   static Future<bool> requestPermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return false;
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return false;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return false;
//     }

//     return true;
//   }

//   static Future<Position?> getCurrentLocation() async {
//     try {
//       return await Geolocator.getCurrentPosition();
//     } catch (e) {
//       print("Error getting location: $e");
//       return null;
//     }
//   }

//   static Future<void> sendLocationToServer(Position position, String username) async {
//     const url = 'https://your-server-url.com/update-location';
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'username': username,
//           'latitude': position.latitude,
//           'longitude': position.longitude,
//         }),
//       );
//       if (response.statusCode != 200) {
//         throw Exception('Failed to send location to server');
//       }
//     } catch (e) {
//       print("Error sending location to server: $e");
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Initialize Geolocator and request location permission
  Future<void> initialize() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request user to enable
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw Exception('Location permission is denied.');
      }
    }
  }

  // Get current position and update Firestore
  Future<void> updateLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, // Adjust according to your need
          distanceFilter: 100, // Optional: Minimum distance to trigger updates
        ),
      );

      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isNotEmpty) {
        await _firestore.collection('users').doc(userId).set({
          'latitude': position.latitude,
          'longitude': position.longitude,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating location: $e');
    }
  }
}
