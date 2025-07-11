// services/location_service.dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  Future<LocationResult> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.error('Location services are disabled. Please enable location services.');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.error('Location permission denied. Please grant location permission.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.error('Location permissions are permanently denied. Please enable in settings.');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationResult.success(position);
    } catch (e) {
      return LocationResult.error('Error getting location: ${e.toString()}');
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}

class LocationResult {
  final Position? position;
  final String? error;
  final bool isSuccess;

  LocationResult._({this.position, this.error, required this.isSuccess});

  factory LocationResult.success(Position position) {
    return LocationResult._(position: position, isSuccess: true);
  }

  factory LocationResult.error(String error) {
    return LocationResult._(error: error, isSuccess: false);
  }
}