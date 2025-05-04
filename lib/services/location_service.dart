import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  static const String googleMapsApiKey = 'AIzaSyB1wnhHnT5QhKvFcOXiiqiTmxoNnVqAC2I';

  // Request location permission
  static Future<bool> requestLocationPermission() async {
    final permission = await Permission.location.request();
    return permission.isGranted;
  }

  // Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return null;
        }
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Calculate distance between two points
  static double calculateDistance(
      double lat1, double lon1,
      double lat2, double lon2
      ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Convert to km
  }

  // Check if doctor is within radius
  static bool isDoctorNearby(
      Position userLocation,
      double doctorLat,
      double doctorLon,
      {double radiusKm = 200.0}
      ) {
    final distance = calculateDistance(
      userLocation.latitude,
      userLocation.longitude,
      doctorLat,
      doctorLon,
    );
    return distance <= radiusKm;
  }

  // Open maps app for directions
  static Future<void> openMapsDirections(double lat, double lng) async {
    final googleMapsUrl = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final appleMapsUrl = Uri.parse('maps://maps.apple.com/?daddr=$lat,$lng');

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl);
      } else {
        throw 'Could not open map';
      }
    } catch (e) {
      print('Error opening maps: $e');
    }
  }
}