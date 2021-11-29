import 'package:geolocator_cn/src/types.dart';
import 'package:geolocator/geolocator.dart';

class LocationServiceProviderSystem implements LocationServiceProvider {
  @override
  String name = 'system';

  LocationServiceProviderSystem();

  @override
  setKey({String androidKey = '', String iosKey = ''}) {}

  @override
  Future<LocationData> getLocation() async {
    Position? position;

    try {
      position = await Geolocator.getLastKnownPosition(
          forceAndroidLocationManager: true);

      position ??= await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          forceAndroidLocationManager: true,
          timeLimit: const Duration(seconds: 5));
    } catch (e) {
      print(e);
    }

    return LocationData(
        latitude: position?.latitude ?? 0,
        longitude: position?.longitude ?? 0,
        crs: CRS.wgs84,
        provider: name,
        accuracy: position?.accuracy ?? 0);
  }
}
