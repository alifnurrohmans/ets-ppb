import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  
  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
      }

      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return null;
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are denied forever');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint('Location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      rethrow;
    }
  }

  /// Get position stream for real-time location updates
  Stream<Position> getPositionStream({
    int distanceFilter = 10, // Between updates in meters
    int timeInterval = 5000, // Between updates in milliseconds
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        timeLimit: Duration(milliseconds: timeInterval),
      ),
    );
  }

  /// Calculate distance between two points
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Get geocode address from coordinates
  Future<List<Placemark>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await GeocodingPlatform.instance
          ?.placemarkFromCoordinates(latitude, longitude) ??
          [];
      return placemarks;
    } catch (e) {
      debugPrint('Error getting address: $e');
      return [];
    }
  }

  /// Format position to readable string
  String formatPosition(Position position) {
    return 'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Open app settings for location permission
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings for app permissions
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}

// Geocoding platform (you might need to add geocoding plugin)
// For now, we'll create a dummy interface
abstract class GeocodingPlatform {
  static GeocodingPlatform? instance;

  Future<List<Placemark>?> placemarkFromCoordinates(
    double latitude,
    double longitude,
  );
}

class Placemark {}
