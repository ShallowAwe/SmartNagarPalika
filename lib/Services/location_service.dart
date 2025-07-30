// services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'logger_service.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  final _logger = LoggerService.instance;

  Future<LocationResult> getCurrentLocation() async {
    _logger.methodEntry('getCurrentLocation');

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      _logger.permissionCheck('Location Services', serviceEnabled);

      if (!serviceEnabled) {
        _logger.warning('Location services are disabled');
        _logger.methodExit('getCurrentLocation', 'Location services disabled');
        return LocationResult.error(
          'Location services are disabled. Please enable location services.',
        );
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      _logger.debug('Initial location permission: $permission');

      if (permission == LocationPermission.denied) {
        _logger.info('Requesting location permission');
        permission = await Geolocator.requestPermission();
        _logger.permissionCheck(
          'Location Permission',
          permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always,
        );

        if (permission == LocationPermission.denied) {
          _logger.warning('Location permission denied by user');
          _logger.methodExit('getCurrentLocation', 'Permission denied');
          return LocationResult.error(
            'Location permission denied. Please grant location permission.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.error('Location permissions permanently denied');
        _logger.methodExit(
          'getCurrentLocation',
          'Permission permanently denied',
        );
        return LocationResult.error(
          'Location permissions are permanently denied. Please enable in settings.',
        );
      }

      // Get current position
      _logger.info('Getting current position with high accuracy');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _logger.locationUpdate(position.latitude, position.longitude);
      _logger.methodExit(
        'getCurrentLocation',
        'Location obtained successfully',
      );
      return LocationResult.success(position);
    } catch (e) {
      _logger.error('Error getting location', e);
      _logger.methodExit('getCurrentLocation', 'Error occurred');
      return LocationResult.error('Error getting location: ${e.toString()}');
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    _logger.methodEntry('isLocationServiceEnabled');
    final result = await Geolocator.isLocationServiceEnabled();
    _logger.permissionCheck('Location Services', result);
    _logger.methodExit('isLocationServiceEnabled', result);
    return result;
  }

  Future<LocationPermission> checkPermission() async {
    _logger.methodEntry('checkPermission');
    final permission = await Geolocator.checkPermission();
    _logger.debug('Current location permission: $permission');
    _logger.methodExit('checkPermission', permission);
    return permission;
  }

  Future<LocationPermission> requestPermission() async {
    _logger.methodEntry('requestPermission');
    _logger.info('Requesting location permission from user');
    final permission = await Geolocator.requestPermission();
    _logger.permissionCheck(
      'Location Permission',
      permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always,
    );
    _logger.methodExit('requestPermission', permission);
    return permission;
  }

  Future<void> openLocationSettings() async {
    _logger.methodEntry('openLocationSettings');
    _logger.info('Opening location settings');
    await Geolocator.openLocationSettings();
    _logger.methodExit('openLocationSettings');
  }

  Future<void> openAppSettings() async {
    _logger.methodEntry('openAppSettings');
    _logger.info('Opening app settings');
    await Geolocator.openAppSettings();
    _logger.methodExit('openAppSettings');
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
