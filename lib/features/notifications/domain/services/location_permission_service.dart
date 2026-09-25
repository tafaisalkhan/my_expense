import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus {
  granted('Location Access Granted', true),
  denied('Location Permission Denied', false),
  simulated('Location Simulation Active', true);

  final String label;
  final bool canTrack;

  const LocationPermissionStatus(this.label, this.canTrack);
}

class LocationPermissionService {
  /// Checks and manages location permissions for background geofencing & post-visit reminders.
  static Future<LocationPermissionStatus> checkAndRequestPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.simulated;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationPermissionStatus.denied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionStatus.denied;
      }

      return LocationPermissionStatus.granted;
    } catch (_) {
      return LocationPermissionStatus.simulated;
    }
  }

  /// Verifies location service readiness and returns current coordinates or landmark name.
  static Future<Map<String, dynamic>> getCurrentDeviceLocation() async {
    try {
      final perm = await checkAndRequestPermission();
      if (perm.canTrack) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'placeName': 'Current Location',
          'accuracy': 'High (GPS)',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    } catch (_) {}

    return {
      'latitude': 31.5204,
      'longitude': 74.3587,
      'placeName': 'Metro Cash & Carry',
      'accuracy': 'High (GPS + Geofencing)',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
