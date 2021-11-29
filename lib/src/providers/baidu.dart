import 'dart:async';
import 'dart:io';

import 'package:geolocator_cn/src/types.dart';

import 'package:flutter_bmflocation/bdmap_location_flutter_plugin.dart';
import 'package:flutter_bmflocation/flutter_baidu_location.dart';
import 'package:flutter_bmflocation/flutter_baidu_location_android_option.dart';
import 'package:flutter_bmflocation/flutter_baidu_location_ios_option.dart';

class LocationServiceProviderBaidu implements LocationServiceProvider {
  @override
  String name = 'baidu';

  static bool inited = false;

  /// baidu stuff
  String iosKey = '';
  BaiduLocation? _lastResult;
  static final LocationFlutterPlugin _locationPlugin = LocationFlutterPlugin();

  /// constructor
  @override
  LocationServiceProviderBaidu(this.iosKey);

  @override
  setKey({String androidKey = '', String iosKey = ''}) {}

  @override
  Future<LocationData> getLocation() async {
    _init();

    _startLocation();

    Completer c = Completer();

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_lastResult?.latitude != null && _lastResult?.longitude != null) {
        timer.cancel();
        c.complete(_lastResult);
      }
    });

    await c.future;

    return LocationData(
        provider: name,
        latitude: _lastResult?.latitude ?? 0,
        longitude: _lastResult?.longitude ?? 0,
        crs: CRS.bd09,
        accuracy: _lastResult?.radius ?? 0);
  }

  void _init() {
    if (inited) {
      return;
    }

    /// 设置ios端ak, android端ak可以直接在清单文件中配置
    if (Platform.isIOS) {
      /// 设置ios端ak, android端ak可以直接在清单文件中配置
      LocationFlutterPlugin.setApiKey(iosKey);
    }

    _locationPlugin.onResultCallback().listen((Map<String, Object>? result) {
      BaiduLocation _baiduLocation = BaiduLocation.fromMap(result);

      if (_baiduLocation.latitude != null && _baiduLocation.longitude != null) {
        _lastResult = _baiduLocation;
        _stopLocation();
      }
    });

    inited = true;
  }

  /// 启动定位
  void _startLocation() {
    try {
      _setLocOption();
      _locationPlugin.startLocation();
    } catch (e) {
      print(e);
    }
  }

  /// 停止定位
  void _stopLocation() {
    try {
      _locationPlugin.stopLocation();
    } catch (e) {
      print(e);
    }
  }

  /// 设置android端和ios端定位参数
  void _setLocOption() {
    /// android 端设置定位参数
    BaiduLocationAndroidOption androidOption = BaiduLocationAndroidOption();
    androidOption.setCoorType("BD09ll"); // 设置返回的位置坐标系类型
    androidOption.setIsNeedAltitude(false); // 设置是否需要返回海拔高度信息
    androidOption.setIsNeedAddres(false); // 设置是否需要返回地址信息
    androidOption.setIsNeedLocationPoiList(false); // 设置是否需要返回周边poi信息
    androidOption.setIsNeedNewVersionRgc(false); // 设置是否需要返回最新版本rgc信息
    androidOption.setIsNeedLocationDescribe(false); // 设置是否需要返回位置描述
    androidOption.setOpenGps(true); // 设置是否需要使用gps
    androidOption.setLocationMode(LocationMode.Battery_Saving); // 设置定位模式
    androidOption.setScanspan(1000); // 设置发起定位请求时间间隔

    Map androidMap = androidOption.getMap();

    /// ios 端设置定位参数
    BaiduLocationIOSOption iosOption = BaiduLocationIOSOption();
    iosOption.setIsNeedNewVersionRgc(true); // 设置是否需要返回最新版本rgc信息
    iosOption.setBMKLocationCoordinateType(
        "BMKLocationCoordinateTypeBMK09LL"); // 设置返回的位置坐标系类型
    iosOption.setActivityType("CLActivityTypeFitness"); // 设置应用位置类型
    iosOption.setLocationTimeout(10); // 设置位置获取超时时间
    iosOption
        .setDesiredAccuracy("kCLLocationAccuracyNearestTenMeters"); // 设置预期精度参数
    iosOption.setReGeocodeTimeout(10); // 设置获取地址信息超时时间
    iosOption.setDistanceFilter(0); // 设置定位最小更新距离
    iosOption.setAllowsBackgroundLocationUpdates(false); // 是否允许后台定位
    iosOption.setPauseLocUpdateAutomatically(true); //  定位是否会被系统自动暂停

    Map iosMap = iosOption.getMap();

    _locationPlugin.prepareLoc(androidMap, iosMap);
  }
}
