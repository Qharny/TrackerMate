import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  static late String SERVER_URL;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (!_isInitialized) {
      await initialize();
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await remoteConfig.fetchAndActivate();

      SERVER_URL = remoteConfig.getString('update_location_url');
      if (SERVER_URL.isEmpty) {
        SERVER_URL = 'https://your-default-server-url.com/update-location';
      }

      _isInitialized = true;
    }
  }

  Future<Position> getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    while (true) {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _showLocationServiceDialog(context);
        continue;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          await _showPermissionDeniedDialog(context);
          continue;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        await _showPermissionPermanentlyDeniedDialog(context);
        continue;
      }

      // If we get here, permission is granted
      break;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> startBackgroundLocationUpdates(String username) async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _sendLocationToServer(username, position);
    });
  }

  Future<void> _sendLocationToServer(String username, Position position) async {
    try {
      final response = await http.post(
        Uri.parse(SERVER_URL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to send location to server: ${response.body}');
      }
    } catch (e) {
      print('Error sending location to server: $e');
    }
  }

  Future<void> _showLocationServiceDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text('Please enable location services to use this app.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Geolocator.openLocationSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text('This app needs location permission to function properly.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPermissionPermanentlyDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Permanently Denied'),
          content: const Text('Please enable location permission in app settings.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Geolocator.openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}