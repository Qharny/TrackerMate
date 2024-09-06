import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

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

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
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

    _startLocationTracking();
  }

  void _startLocationTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _updateLocation(position);
    });
  }

  void _updateLocation(Position position) {
    FirebaseFirestore.instance.collection('device_locations').doc('current_user_id').set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
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
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          LatLng deviceLocation = LatLng(data['latitude'], data['longitude']);
          
          setState(() {
            _markers.clear();
            _markers.add(Marker(
              markerId: MarkerId(username),
              position: deviceLocation,
              infoWindow: InfoWindow(title: username),
            ));
          });

          _mapController.animateCamera(CameraUpdate.newLatLngZoom(deviceLocation, 15));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),
                zoom: 2,
              ),
              markers: _markers,
              mapType: MapType.normal,
              myLocationEnabled: true,
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location),
        onPressed: () async {
          Position position = await Geolocator.getCurrentPosition();
          _mapController.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(position.latitude, position.longitude),
              15,
            ),
          );
        },
      ),
    );
  }
}