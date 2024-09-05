import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  Future<bool> initialize() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    _permissionGranted = await location.hasPermission();
    while (_permissionGranted != PermissionStatus.granted) {
      _permissionGranted = await location.requestPermission();
    }

    return true;
  }

  Future<LocationData?> getLocation() async {
    try {
      _locationData = await location.getLocation();
      return _locationData;
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  Future<void> sendLocationToServer(String username) async {
    if (_locationData != null) {
      final url = Uri.parse('https://your-server-url.com/update-location');
      final response = await http.post(
        url,
        body: json.encode({
          'username': username,
          'latitude': _locationData!.latitude,
          'longitude': _locationData!.longitude,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send location to server');
      }
    }
  }
}