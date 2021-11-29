# Flutter geolocator_cn Plugin

## Features

- Location service helper class that can use multiple location services at the same time.

  - system ✅
  - baidu ✅
  - amap ✅
  - ip locaton✅
- Auto handle permission requests.
- Auto transform CRS to GCJ02 in mainland China.
  Or you can set the CRS manually

## Getting started

Add this to your package's pubspec.yaml file:

```dart
dependencies:
  geolocator_cn: ^1.1.0
```

## Configure

#### 1. Configure baidu lbs sdk api keys:

Edit  *android/app/src/Manifest.xml*, and add the following code in `<Application>` Node:

```
<meta-data
    android:name="com.baidu.lbsapi.API_KEY"
    android:value="YOUR API KEY" />
```

### 2. Config amap android dependence

Edit *android/app/build.gradle*, add this to dependencies:

```
dependencies
{
    implementation 'com.amap.api:location:5.6.0'
}
```

## Usage

```dart
import 'package:geolocator_cn/geolocator_cn.dart';

GeolocatorCNProviders.config = {
      'baidu': {'ios': 'YOUR API KEY'},
      'amap': {'ios': 'YOUR API KEY', 'android': 'YOUR API KEY'},
    };

GeolocatorCN().getLocation().then((location) {
      print(location);
    });

```

or

```dart
import 'package:geolocator_cn/geolocator_cn.dart';

GeolocatorCNProviders.config = {
      'baidu': {'ios': 'YOUR API KEY'},
      'amap': {'ios': 'YOUR API KEY', 'android': 'YOUR API KEY'},
    };

LocationData location = await GeolocatorCN().getLocation();
print(location);

```
