import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final GeolocatorPlatform _geolocator = GeolocatorPlatform.instance;

  /// Check if location services are enabled and request permissions if needed
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await _geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request to enable them
      serviceEnabled = await _geolocator.openLocationSettings();
      if (!serviceEnabled) {
        return false;
      }
    }

    // Check location permissions
    permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      await openAppSettings();
      return false;
    }

    return true;
  }

  /// Get current position
  Future<LatLng> getCurrentPosition() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      throw Exception('Location permissions are denied');
    }

    final position = await _geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  /// Get position updates stream
  Stream<LatLng> getPositionStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return _geolocator
        .getPositionStream(locationSettings: locationSettings)
        .map((position) => LatLng(position.latitude, position.longitude));
  }

  /// Calculate distance between two points in meters
  double calculateDistance(LatLng start, LatLng end) {
    return _geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }
}
