import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:smart_bins_flutter/directions_repository.dart';
import 'package:smart_bins_flutter/models/bin_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_bins_flutter/models/directions_model.dart';

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
    getCurrentLocation();
    _activateListeners();
  }

  int limitCapacity = (12 * (75 / 100)).ceil();

  void _activateListeners() {
    _database.child("bins").onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<Object?, Object?>?;
      if (data != null && mounted) {
        setState(() {
          binData = data.entries.map((e) {
            final value = e.value as Map<Object?, Object?>;
            final name = value['name'] as String? ?? "";
            final capacity = value['capacity'] is num
                ? (value['capacity'] as num).toDouble()
                : 0.0; // Handle null or non-double values
            final latitude = value['latitude'] is num
                ? (value['latitude'] as num).toDouble()
                : 0.0;
            final longitude = value['longitude'] is num
                ? (value['longitude'] as num).toDouble()
                : 0.0;
            if (capacity >= limitCapacity) {
              locationList.add(
                Marker(
                  markerId: MarkerId(name),
                  position: LatLng(latitude, longitude),
                  infoWindow: InfoWindow(
                    title: name,
                  ),
                ),
              );
              _markers.add(
                Marker(
                  markerId: MarkerId(name),
                  position: LatLng(latitude, longitude),
                  infoWindow: InfoWindow(
                    title: name,
                  ),
                ),
              );
            }
            return Bin(
                name: name,
                volume: capacity,
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
  List<Marker> locationList = [];
  LatLng? _currentPosition;
  bool _isLoading = true;
  List<Directions> _routes = [];

  getCurrentLocation() async {
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
        // _markers.add(
        //   Marker(
        //     markerId: const MarkerId('currentPosition'),
        //     position: LatLng(location.latitude, location.longitude),
        //     infoWindow: const InfoWindow(
        //       title: 'My Location',
        //     ),
        //   ),
        // );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: false,
          title: const Text("Google Maps"),
          actions: [
            TextButton(
                onPressed: () => _addRoute(), child: const Text("Find Route"))
          ]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _currentPosition ?? const LatLng(0.0, 0.0),
                zoom: 16,
              ),
              markers: Set<Marker>.of(_markers),
              myLocationEnabled: true,
              compassEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              polylines: Set<Polyline>.of(
                _routes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final route = entry.value;

                  return Polyline(
                    polylineId: PolylineId(
                        'route_$index'), // Unique ID for each polyline
                    color: Colors.purple,
                    width: 5,
                    points: route.polylinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList(),
                  );
                }),
              ),
            ),
    );
  }

  void _addRoute() async {
    if (locationList.length > 1 && mounted) {
      _isLoading = true;

      List<Marker> destinations = locationList;
      List<Directions> resultRoutes = [];

      while (destinations.isNotEmpty) {
        List<Directions> tempRoutes = [];
        Directions tempCurrentLocation = Directions(
          bounds: LatLngBounds(
            northeast: const LatLng(0, 0),
            southwest: const LatLng(0, 0),
          ),
          polylinePoints: [],
          totalDistance: 999999,
          totalDuration: 999999,
          endAddress: 'init',
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        );

        int bestDistance = 999999;
        int bestRouteIndex = 0;

        for (var i = 0; i < destinations.length; i++) {
          final directions = await DirectionsRepository().getDirections(
              origin: tempCurrentLocation.position,
              destination: destinations[i].position);
          tempRoutes.add(directions!);
          // Call API
        }
        for (var i = 0; i < tempRoutes.length; i++) {
          if (tempRoutes[i].totalDistance < bestDistance) {
            bestDistance = tempRoutes[i].totalDistance;
            bestRouteIndex = i;
          }
        }

        resultRoutes.add(tempRoutes[bestRouteIndex]);
        tempCurrentLocation = tempRoutes[bestRouteIndex];
        destinations.removeAt(bestRouteIndex);
      }
      resultRoutes.add(Directions(
        bounds: LatLngBounds(
          northeast: const LatLng(0, 0),
          southwest: const LatLng(0, 0),
        ),
        polylinePoints: [],
        totalDistance: 999999,
        totalDuration: 999999,
        endAddress: 'backToCurrentLocation',
        position:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      ));

      setState(() => _routes = resultRoutes);
      _isLoading = false;
    }
  }
}
