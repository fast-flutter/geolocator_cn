import 'dart:convert';
import 'dart:math';

/// Geographic coordinate system
enum CRS {
  /// international coordinate
  wgs84,

  /// in China, amap coordinate
  gcj02,

  /// in China, baidu map coordinate
  bd09,

  /// not set
  unknown
}

/// precision convertor for double
extension Precision on double {
  double toPrecision(int fractionDigits) {
    var mod = pow(10, fractionDigits.toDouble()).toDouble();
    return ((this * mod).round().toDouble() / mod);
  }
}

/// The response object of [GeolocatorCN.getLocation] and [GeolocatorCN.onLocationChanged]
class LocationData {
  /// The latitude of the location
  final double latitude;

  /// Longitude of the location
  final double longitude;

  /// the crs of this coordinate
  final CRS crs;

  /// The name of the provider that generated this data.
  final String provider;

  /// accuracy
  final double accuracy;

  /// time
  final int timestamp;

  factory LocationData(
      {double latitude = 0.0,
      double longitude = 0.0,
      CRS crs = CRS.unknown,
      String provider = '',
      double accuracy = 500,
      int timestamp = 0}) {
    return LocationData._(
        latitude.toPrecision(6),
        longitude.toPrecision(6),
        crs,
        provider,
        accuracy.toPrecision(1),
        DateTime.now().millisecondsSinceEpoch ~/ 1000);
  }

  LocationData._(this.latitude, this.longitude, this.crs, this.provider,
      this.accuracy, this.timestamp);

  factory LocationData.fromMap(Map<String, dynamic> dataMap) {
    return LocationData(
        latitude: dataMap['latitude'],
        longitude: dataMap['longitude'],
        crs: dataMap['crs'],
        provider: dataMap['provider'],
        accuracy: dataMap['accuracy'],
        timestamp: dataMap['timestamp']);
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'crs': crs.toString().split('.').last,
      'provider': provider,
      'accuracy': accuracy,
      'timestamp': timestamp
    };
  }

  String toJson() => const JsonEncoder.withIndent('  ').convert(toMap());

  @override
  String toString() => toMap().toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationData &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          crs == other.crs;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode ^ crs.hashCode;
}

abstract class LocationServiceProvider {
  late String name;

  LocationServiceProvider();

  /// Returns the current location of the device.
  Future<LocationData> getLocation();

  setKey({String androidKey = '', String iosKey = ''});
}
