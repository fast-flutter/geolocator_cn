import 'dart:async';
import 'dart:io';
import 'package:geolocator_cn/src/types.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';

class LocationServiceProviderAmap implements LocationServiceProvider {
  @override
  String name = 'amap';

  static bool inited = false;

  String androidKey = '';
  String iosKey = '';

  /// amap stuff
  static final AMapFlutterLocation _locationPlugin = AMapFlutterLocation();
  Map<String, Object>? _lastResult;

  @override
  LocationServiceProviderAmap(this.androidKey, this.iosKey);

  @override
  setKey({String androidKey = '', String iosKey = ''}) {
    androidKey = androidKey;
    iosKey = iosKey;
  }

  _init() async {
    if (inited) {
      return;
    }

    assert(androidKey.isNotEmpty, 'amap: android key is empty');
    assert(iosKey.isNotEmpty, 'amap: ios key is empty');

    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.updatePrivacyAgree(true);

    AMapFlutterLocation.setApiKey(androidKey, iosKey);

    ///注册定位结果监听
    _locationPlugin.onLocationChanged().listen((Map<String, Object> result) {
      if (result['latitude'] != null && result['longitude'] != null) {
        _lastResult = result;
        _stopLocation();
      }
    });

    inited = true;
  }

  @override
  Future<LocationData> getLocation() async {
    _init();

    _startLocation();

    Completer c = Completer();
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_lastResult?['latitude'] != null &&
          _lastResult?['longitude'] != null) {
        timer.cancel();
        c.complete(_lastResult);
      }
    });

    await c.future;

    return LocationData(
        latitude: double.tryParse("${_lastResult?['latitude']}") ?? 0,
        longitude: double.tryParse("${_lastResult?['longitude']}") ?? 0,
        accuracy: double.tryParse("${_lastResult?['accuracy']}") ?? 0,
        crs: CRS.gcj02,
        provider: name);
  }

  ///开始定位
  void _startLocation() {
    ///开始定位之前设置定位参数
    _setLocationOption();
    _locationPlugin.startLocation();
  }

  ///停止定位
  void _stopLocation() {
    _locationPlugin.stopLocation();
  }

  ///设置定位参数
  void _setLocationOption() {
    AMapLocationOption locationOption = AMapLocationOption();

    ///是否单次定位
    locationOption.onceLocation = true;

    ///是否需要返回逆地理信息
    locationOption.needAddress = false;

    ///逆地理信息的语言类型
    locationOption.geoLanguage = GeoLanguage.DEFAULT;

    locationOption.desiredLocationAccuracyAuthorizationMode =
        AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;

    locationOption.fullAccuracyPurposeKey = "AMapLocationScene";

    ///设置Android端连续定位的定位间隔
    locationOption.locationInterval = 2000;

    ///设置Android端的定位模式<br>
    ///可选值：<br>
    ///<li>[AMapLocationMode.Battery_Saving]</li>
    ///<li>[AMapLocationMode.Device_Sensors]</li>
    ///<li>[AMapLocationMode.Hight_Accuracy]</li>
    locationOption.locationMode = AMapLocationMode.Battery_Saving;

    ///设置iOS端的定位最小更新距离<br>
    locationOption.distanceFilter = -1;

    ///设置iOS端期望的定位精度
    /// 可选值：<br>
    /// <li>[DesiredAccuracy.Best] 最高精度</li>
    /// <li>[DesiredAccuracy.BestForNavigation] 适用于导航场景的高精度 </li>
    /// <li>[DesiredAccuracy.NearestTenMeters] 10米 </li>
    /// <li>[DesiredAccuracy.Kilometer] 1000米</li>
    /// <li>[DesiredAccuracy.ThreeKilometers] 3000米</li>
    locationOption.desiredAccuracy = DesiredAccuracy.HundredMeters;

    ///设置iOS端是否允许系统暂停定位
    locationOption.pausesLocationUpdatesAutomatically = true;

    ///将定位参数设置给定位插件
    _locationPlugin.setLocationOption(locationOption);
  }
}
