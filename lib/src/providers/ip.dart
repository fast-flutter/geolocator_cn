import 'dart:convert';

import 'package:geolocator_cn/src/types.dart';
import 'package:http/http.dart' as http;

class LocationServiceProviderIPaddr implements LocationServiceProvider {
  @override
  String name = 'ip';

  static Map<String, dynamic>? _lastResult;

  LocationServiceProviderIPaddr();

  @override
  setKey({String androidKey = '', String iosKey = ''}) {}

  @override
  Future<LocationData> getLocation() async {
    try {
      if (_lastResult == null) {
        final response = await http.get(Uri.parse("http://ip-api.com/json/"));
        if (response.statusCode == 200) {
          _lastResult = jsonDecode(response.body);
        }
      }
    } catch (e) {
      print(e);
    }

    return LocationData(
        latitude: _lastResult?['lat'] ?? 0,
        longitude: _lastResult?['lon'] ?? 0,
        crs: CRS.wgs84,
        provider: name,
        accuracy: 50000);
  }
}
