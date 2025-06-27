// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'animate_drop_pin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDbT1VCmP4HyZc3B3j-5gdhncD2D4-aVnA",
      authDomain: "dc-reg-a81e3.firebaseapp.com",
      projectId: "dc-reg-a81e3",
      storageBucket: "dc-reg-a81e3.appspot.com",
      messagingSenderId: "406897259160",
      appId: "1:406897259160:web:bc07b8faeeccacf89d96ed",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Map',
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? lastAddedId;
  late final DateTime _appStartTime;
  final Set<String> _animatedPinIds = {};
  final MapController _mapController = MapController();
  final LatLng _defaultCenter = const LatLng(13.9416, 121.1631); // Lipa City
  List<Marker> _markers = [];

  @override
  void initState() {
    _appStartTime = DateTime.now();
    super.initState();
    _subscribeToPinUpdates();
  }

  void _subscribeToPinUpdates() {
    FirebaseFirestore.instance.collection('registrations').snapshots().listen(
        (snapshot) {
      final newMarkers = snapshot.docs.where((doc) {
        final data = doc.data();
        final location = data['location'];
        final timestamp = data['timestamp'];

        return location != null &&
            location['lat'] != null &&
            location['lng'] != null &&
            timestamp != null;
      }).map<Marker>((doc) {
        final data = doc.data();
        final docId = doc.id;
        final loc = data['location'];
        final timestamp = (data['timestamp'] as Timestamp).toDate();

        final isNew = timestamp.isAfter(_appStartTime) &&
            !_animatedPinIds.contains(docId);

        if (isNew) _animatedPinIds.add(docId);

        return Marker(
          point: LatLng(loc['lat'], loc['lng']),
          width: 40,
          height: 40,
          child: isNew
              ? const AnimatedDropPin()
              : const Icon(Icons.location_pin, size: 30, color: Colors.red),
        );
      }).toList();

      setState(() {
        _markers = newMarkers;
      });

      if (_markers.isNotEmpty) {
        _mapController.move(_markers.last.point, _mapController.zoom);
      }
    }, onError: (error) {
      debugPrint('Error loading locations: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _defaultCenter,
          zoom: 14,
          maxZoom: 18,
          minZoom: 3,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.yourcompany.mapapp',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}
