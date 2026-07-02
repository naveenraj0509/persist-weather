import 'package:geolocator/geolocator.dart';

/// Service responsible for managing device location requests using geolocator.
class LocationService {
  /// Fetches current GPS coordinates.
  ///
  /// Requests location permissions if they are not already granted.
  /// Throws user-friendly exception messages on failure.
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(
        'Location services are disabled. Please enable GPS in your device settings.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationServiceException(
          'Location permission was denied. Please grant location access to fetch weather.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Location permission is permanently denied. Please enable it in your device settings to fetch weather.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      throw LocationServiceException(
        'Failed to retrieve location: $e. Please make sure location access is enabled.',
      );
    }
  }
}

/// Custom exception for location service errors.
class LocationServiceException implements Exception {
  final String message;
  const LocationServiceException(this.message);

  @override
  String toString() => message;
}
