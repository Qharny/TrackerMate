import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  late AnimationController _menuController;
  late Animation<double> _menuAnimation;
  bool _isMenuOpen = false;

  bool _isOnline = true;
  List<Map<String, dynamic>> _offlineData = [];

  LatLng _currentPosition = const LatLng(0, 0);
  bool _locationPermissionGranted = false;

  // New variables for real-time updates
  String? _currentUserId;
  final Map<String, StreamSubscription<DocumentSnapshot>> _locationStreams = {};

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
    
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _menuAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_menuController);
    
    _checkConnectivity();
    _requestLocationPermission();
    _initializeCurrentUser();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _menuController.dispose();
    _searchController.dispose();
    _locationStreams.forEach((_, subscription) => subscription.cancel());
    super.dispose();
  }

  Future<void> _initializeCurrentUser() async {
    // In a real app, you'd get the current user's ID from your authentication system
    // For this example, we'll use a dummy ID
    _currentUserId = 'current_user_id';
    _startListeningToLocationUpdates(_currentUserId!);
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
      if (_isOnline) {
        _syncOfflineData();
      }
    } as void Function(List<ConnectivityResult> event)?);
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    setState(() {
      _locationPermissionGranted = true;
    });
    _getCurrentLocation();
    _startLocationTracking();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _updateMarkers();
      });
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 15));
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  void _startLocationTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _updateMarkers();
      });
      _updateLocation(position);
    });
  }

  void _updateLocation(Position position) {
    Map<String, dynamic> locationData = {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (_isOnline) {
      _sendLocationToFirebase(locationData);
    } else {
      _storeLocationLocally(locationData);
    }
  }

  Future<void> _sendLocationToFirebase(Map<String, dynamic> locationData) async {
    try {
      await FirebaseFirestore.instance.collection('device_locations').doc(_currentUserId).set({
        'latitude': locationData['latitude'],
        'longitude': locationData['longitude'],
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending location to Firebase: $e');
      _storeLocationLocally(locationData);
    }
  }

  Future<void> _storeLocationLocally(Map<String, dynamic> locationData) async {
    _offlineData.add(locationData);
    await _saveOfflineData();
  }

  Future<void> _saveOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(_offlineData);
    await prefs.setString('offline_location_data', jsonData);
  }

  Future<void> _loadOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('offline_location_data');
    if (jsonData != null) {
      List<dynamic> decodedData = jsonDecode(jsonData);
      _offlineData = decodedData.cast<Map<String, dynamic>>();
    }
  }

  Future<void> _syncOfflineData() async {
    await _loadOfflineData();
    for (var locationData in _offlineData) {
      await _sendLocationToFirebase(locationData);
    }
    _offlineData.clear();
    await _saveOfflineData();
  }

  void _searchDevice() async {
    String username = _searchController.text;
    if (username.isNotEmpty) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('device_locations')
            .doc(username)
            .get();

        if (doc.exists) {
          _startListeningToLocationUpdates(username);
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _updateDeviceMarker(username, data);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No device found for username: $username')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching for device: $e')),
        );
      }
    }
  }

  void _startListeningToLocationUpdates(String userId) {
    if (_locationStreams.containsKey(userId)) {
      // Already listening to this user's updates
      return;
    }

    var stream = FirebaseFirestore.instance
        .collection('device_locations')
        .doc(userId)
        .snapshots();

    _locationStreams[userId] = stream.listen((docSnapshot) {
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        _updateDeviceMarker(userId, data);
      }
    });
  }

  void _updateDeviceMarker(String userId, Map<String, dynamic> data) {
    LatLng deviceLocation = LatLng(data['latitude'], data['longitude']);
    
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == MarkerId(userId));
      _markers.add(Marker(
        markerId: MarkerId(userId),
        position: deviceLocation,
        infoWindow: InfoWindow(title: userId),
      ));
    });

    if (userId != _currentUserId) {
      _mapController.animateCamera(CameraUpdate.newLatLng(deviceLocation));
    }
  }

  void _updateMarkers() {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == MarkerId(_currentUserId!));
      _markers.add(Marker(
        markerId: MarkerId(_currentUserId!),
        position: _currentPosition,
        infoWindow: const InfoWindow(title: 'Current Location'),
      ));
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _menuController.forward();
      } else {
        _menuController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 15,
              ),
              markers: _markers,
              mapType: MapType.normal,
              myLocationEnabled: _locationPermissionGranted,
              myLocationButtonEnabled: false,
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  color: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Enter username to track',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.blue),
                          onPressed: _searchDevice,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isOnline ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ScaleTransition(
            scale: _menuAnimation,
            child: FloatingActionButton(
              heroTag: "location",
              backgroundColor: Colors.blue,
              child: const Icon(Icons.my_location),
              onPressed: () {
                if (_locationPermissionGranted) {
                  _mapController.animateCamera(
                    CameraUpdate.newLatLngZoom(_currentPosition, 15),
                  );
                } else {
                  _requestLocationPermission();
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          ScaleTransition(
            scale: _menuAnimation,
            child: FloatingActionButton(
              heroTag: "settings",
              backgroundColor: Colors.green,
              child: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "menu",
            backgroundColor: Colors.blue,
            onPressed: _toggleMenu,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _menuController,
            ),
          ),
        ],
      ),
    );
  }
}