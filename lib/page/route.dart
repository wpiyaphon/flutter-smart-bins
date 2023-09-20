import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_bins_flutter/models/bin_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  List<Bin> binData = [];

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _activateListeners();
    getLocation();
  }

  void _activateListeners() {
    _database.child("bins").onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<Object?, Object?>?;
      if (data != null && mounted) {
        setState(() {
          binData = data.entries.map((e) {
            final value = e.value as Map<Object?, Object?>;
            final name = value['name'] as String? ?? "";
            final volume = value['capacity'] is num
                ? (value['capacity'] as num).toDouble()
                : 0.0; // Handle null or non-double values
            final latitude = value['latitude'] is num
                ? (value['latitude'] as num).toDouble()
                : 0.0;
            final longitude = value['longitude'] is num
                ? (value['longitude'] as num).toDouble()
                : 0.0;
            setState(() {
              _markers.add(
                Marker(
                  markerId: MarkerId(name),
                  position: LatLng(latitude, longitude),
                  infoWindow: InfoWindow(
                    title: name,
                  ),
                ),
              );
            });
            return Bin(
                name: name,
                volume: volume,
                latitude: latitude,
                longitude: longitude);
          }).toList();
        });
      }
    });
  }

  // Google Maps
  Completer<GoogleMapController> _controller = Completer();
  List<Marker> _markers = [];
  LatLng? _currentPosition;
  bool _isLoading = true;

  getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location service is not enabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location service is not enabled");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permissions permanently denied, we cannot request permission");
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    double lat = position.latitude;
    double long = position.longitude;

    LatLng location = LatLng(lat, long);

    if (mounted) {
      setState(() {
        _currentPosition = location;
        _isLoading = false;
        _markers.add(
          Marker(
            markerId: const MarkerId('1'),
            position: _currentPosition!,
            infoWindow: const InfoWindow(
              title: 'My Position',
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(_currentPosition);
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _currentPosition ?? const LatLng(0.0, 0.0),
                zoom: 19.151926040649414,
              ),
              markers: Set<Marker>.of(_markers),
              myLocationEnabled: true,
              compassEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
    );
  }
}
