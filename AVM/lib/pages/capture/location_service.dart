import 'dart:async';
import 'dart:convert';

import 'package:avm/backend/database/geolocation.dart';
import 'package:avm/backend/preferences.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  Future<bool> enableService() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  Future<bool> displayPermissionsDialog() async {
    // if (SharedPreferencesUtil().locationPermissionRequested) return false;
    SharedPreferencesUtil().locationPermissionRequested = true;
    var status = await permissionStatus();
    return await isServiceEnabled() == false ||
        (status != PermissionStatus.granted &&
            status != PermissionStatus.deniedForever);
  }

  Future<bool> isServiceEnabled() => location.serviceEnabled();

  Future<PermissionStatus> requestPermission() async {
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }
    return permissionGranted;
  }

  Future<PermissionStatus> permissionStatus() => location.hasPermission();

  Future hasPermission() async =>
      (await location.hasPermission()) == PermissionStatus.granted;

  // Future<Geolocation?> getGeolocationDetails() async {
  //   if (await hasPermission()) {
  //     LocationData locationData = await location.getLocation();
  //     // move http requests to other.dart

  //     try {
  //       var res = await http.get(
  //         Uri.parse(
  //           "https://maps.googleapis.com/maps/api/geocode/json?latlng"
  //           "=${locationData.latitude},${locationData.longitude}&key=${Env.googleMapsApiKey}",
  //         ),
  //       );

  //       var data = json.decode(res.body);

  //       String? placeName;
  //       var addressComponents = data['results'][0]['address_components'];
  //       for (var component in addressComponents) {
  //         var types = component['types'];
  //         if (types.contains('locality') || types.contains('sublocality')) {
  //           placeName = component['long_name'];
  //           break;
  //         }
  //       }

  //       // If no locality or sublocality found, try to get a meaningful name
  //       if (placeName == null) {
  //         for (var component in addressComponents) {
  //           var types = component['types'];
  //           if (types.contains('neighborhood') ||
  //               types.contains('administrative_area_level_2') ||
  //               types.contains('administrative_area_level_1')) {
  //             placeName = component['long_name'];
  //             break;
  //           }
  //         }
  //       }

  //       Geolocation geolocation = Geolocation(
  //         latitude: locationData.latitude,
  //         longitude: locationData.longitude,
  //         address: data['results'][0]['formatted_address'],
  //         locationType: data['results'][0]['types'][0],
  //         googlePlaceId: data['results'][0]['place_id'],
  //       );
  //       return geolocation;
  //     } catch (e) {
  //       return Geolocation(
  //           latitude: locationData.latitude, longitude: locationData.longitude);
  //     }
  //   } else {
  //     return null;
  //   }
  // }

  Future<Geolocation?> getGeolocationDetails() async {
    if (await hasPermission()) {
      const googleMapsApiKey = 'AIzaSyDWJIATVb9XFFr4qgaKpoEFBXIbxMYa250';

      // Get the current location
      LocationData locationData = await location.getLocation();

      try {
        // Make the HTTP request to Google Maps API
        String url =
            "https://maps.googleapis.com/maps/api/geocode/json?latlng=${locationData.latitude},${locationData.longitude}&key=$googleMapsApiKey";

        var res = await http.get(Uri.parse(url));

        var data = json.decode(res.body);

        // Check if results are available
        if (data['results'] == null || data['results'].isEmpty) {
          return Geolocation(
            latitude: locationData.latitude,
            longitude: locationData.longitude,
          );
        }

        // Extract address components
        String? placeName;
        var addressComponents = data['results'][0]['address_components'] ?? [];
        for (var component in addressComponents) {
          var types = component['types'] ?? [];

          if (types.contains('locality') || types.contains('sublocality')) {
            placeName = component['long_name'];
            break;
          }
        }

        // Attempt fallback address extraction if locality not found
        if (placeName == null) {
          for (var component in addressComponents) {
            var types = component['types'] ?? [];
            if (types.contains('neighborhood') ||
                types.contains('administrative_area_level_2') ||
                types.contains('administrative_area_level_1')) {
              placeName = component['long_name'];
              break;
            }
          }
        }

        // Create Geolocation object
        Geolocation geolocation = Geolocation(
          latitude: locationData.latitude,
          longitude: locationData.longitude,
          address: data['results'][0]['formatted_address'] ?? "Unknown address",
          locationType: data['results'][0]['types']?[0] ?? "Unknown",
          googlePlaceId: data['results'][0]['place_id'] ?? "",
        );
        return geolocation;
      } catch (e) {
        return Geolocation(
          latitude: locationData.latitude,
          longitude: locationData.longitude,
        );
      }
    } else {
      return null;
    }
  }
}