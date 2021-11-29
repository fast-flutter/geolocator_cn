library geolocator_cn;

import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:coordtransform/coordtransform.dart';
import 'src/providers/baidu.dart';
import 'src/providers/system.dart';
import 'src/providers/amap.dart';
import 'src/providers/ip.dart';
import 'src/types.dart';
export 'src/types.dart';

/// provider registry
class GeolocatorCNProviders {
  static Map<String, dynamic> config = {
    'baidu': {'ios': 'YOUR API KEY'},
    'amap': {'ios': 'YOUR API KEY', 'android': 'YOUR API KEY'},
  };

  static LocationServiceProviderBaidu baidu =
      LocationServiceProviderBaidu(config['amap']['ios']);
  static LocationServiceProviderSystem system = LocationServiceProviderSystem();
  static LocationServiceProviderAmap amap = LocationServiceProviderAmap(
      config['amap']['android'], config['amap']['ios']);
  static LocationServiceProviderIPaddr ip = LocationServiceProviderIPaddr();
}

/// A service helper class that can use multiple location services at the same time.
class GeolocatorCN {
  List<LocationServiceProvider> providers;

  factory GeolocatorCN({List<LocationServiceProvider>? providers}) {
    return GeolocatorCN._(providers ??
        [
          GeolocatorCNProviders.system,
          GeolocatorCNProviders.baidu,
          GeolocatorCNProviders.amap
        ]);
  }

  GeolocatorCN._(this.providers);

  /// check if the location service is enabled, if not enabled, request permission
  Future<bool> hasPermission() async {
    PermissionStatus status = await Permission.location.request();

    return (status == PermissionStatus.granted);
  }

  /// get the current location
  Future<LocationData> getLocation({CRS crs = CRS.gcj02}) async {
    LocationData location = LocationData();

    if (await hasPermission() == true) {
      Completer c = Completer();

      /// 哪个先返回有效结果就用哪个
      for (var provider in providers) {
        provider.getLocation().then((value) {
          if (value.latitude != 0 && value.longitude != 0) {
            if (c.isCompleted != true) {
              c.complete(value);
            }
          }
        }).catchError((e) {
          print(e);
        });
      }

      try {
        location = await c.future;
      } catch (e) {
        print(e);
        location = await GeolocatorCNProviders.ip.getLocation();
      }
    } else {
      /// if we cat't get permission, we can only use the ip location api
      location = await GeolocatorCNProviders.ip.getLocation();
    }

    /// transform the location to the specified crs and return
    LocationData ret = _transormCrs(location, location.crs, crs);
    print('GeolocatorCN->getLocation: $ret');

    return ret;
  }

  /// transform the location data from one crs to another
  LocationData _transormCrs(LocationData data, CRS from, CRS to) {
    if (data.crs != CRS.unknown &&
        from != to &&
        data.latitude != 0 &&
        data.longitude != 0) {
      CoordResult result = CoordResult(data.longitude, data.latitude);
      if (from == CRS.wgs84 && to == CRS.gcj02) {
        result =
            CoordTransform.transformWGS84toGCJ02(data.longitude, data.latitude);
      } else if (from == CRS.gcj02 && to == CRS.wgs84) {
        result =
            CoordTransform.transformGCJ02toWGS84(data.longitude, data.latitude);
      } else if (from == CRS.wgs84 && to == CRS.bd09) {
        result =
            CoordTransform.transformWGS84toBD09(data.longitude, data.latitude);
      } else if (from == CRS.bd09 && to == CRS.wgs84) {
        result =
            CoordTransform.transformBD09toWGS84(data.longitude, data.latitude);
      } else if (from == CRS.gcj02 && to == CRS.bd09) {
        result =
            CoordTransform.transformGCJ02toBD09(data.longitude, data.latitude);
      } else if (from == CRS.bd09 && to == CRS.gcj02) {
        result =
            CoordTransform.transformBD09toGCJ02(data.longitude, data.latitude);
      }

      Map<String, dynamic> tmp = data.toMap();
      tmp['latitude'] = result.lat;
      tmp['longitude'] = result.lon;
      tmp['crs'] = to;

      return LocationData.fromMap(tmp);
    } else {
      return data;
    }
  }
}
