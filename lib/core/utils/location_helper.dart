import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final String addressLine;
  final String city;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;

  const LocationResult({
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
  });
}

class LocationHelper {
  static Future<LocationResult?> fetchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can continue accessing the position of the device.
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        
        final street = place.street ?? '';
        final subLocality = place.subLocality ?? '';
        final name = place.name ?? '';

        // Combine parts cleanly for addressLine
        final parts = <String>[];
        if (name.isNotEmpty && name != street) parts.add(name);
        if (street.isNotEmpty) parts.add(street);
        if (subLocality.isNotEmpty && subLocality != street) parts.add(subLocality);
        if (parts.isEmpty && place.thoroughfare != null) parts.add(place.thoroughfare!);

        final addressLine = parts.isNotEmpty ? parts.join(', ') : 'Current Location';
        final city = place.locality ?? place.subAdministrativeArea ?? 'Jaipur';
        final state = place.administrativeArea ?? 'Rajasthan';
        final pincode = place.postalCode ?? '302001';

        return LocationResult(
          addressLine: addressLine,
          city: city,
          state: state,
          pincode: pincode,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    } catch (e) {
      // If reverse geocoding fails, return default fallback with coordinates
      return LocationResult(
        addressLine: 'Lat: ${position.latitude.toStringAsFixed(4)}, Long: ${position.longitude.toStringAsFixed(4)}',
        city: 'Jaipur',
        state: 'Rajasthan',
        pincode: '302001',
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }

    return null;
  }
}
