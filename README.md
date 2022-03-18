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

### 1. Configure project workspace

<details>
<summary>Android</summary>
  
**AndroidX** 
1. Add the following to your "gradle.properties" file:

```
android.useAndroidX=true
android.enableJetifier=true
```
2. Make sure you set the `compileSdkVersion` in your "android/app/build.gradle" file to 30:

```
android {
  compileSdkVersion 30

  ...
}
```
3. Make sure you replace all the `android.` dependencies to their AndroidX counterparts (a full list can be found here: [Migrating to AndroidX](https://developer.android.com/jetpack/androidx/migrate)).

**Permissions**

On Android you'll need to add either the `ACCESS_COARSE_LOCATION` or the `ACCESS_FINE_LOCATION` permission to your Android Manifest. To do so open the AndroidManifest.xml file (located under android/app/src/main) and add one of the following two lines as direct children of the `<manifest>` tag (when you configure both permissions the `ACCESS_FINE_LOCATION` will be used by the geolocator plugin):

``` xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

Starting from Android 10 you need to add the `ACCESS_BACKGROUND_LOCATION` permission (next to the `ACCESS_COARSE_LOCATION` or the `ACCESS_FINE_LOCATION` permission) if you want to continue receiving updates even when your App is running in the background (note that the geolocator plugin doesn't support receiving an processing location updates while running in the background):

``` xml
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

> **NOTE:** Specifying the `ACCESS_COARSE_LOCATION` permission results in location updates with an accuracy approximately equivalent to a city block. It might take a long time (minutes) before you will get your first locations fix as `ACCESS_COARSE_LOCATION` will only use the network services to calculate the position of the device. More information can be found [here](https://developer.android.com/training/location/retrieve-current#permissions). 


</details>
<details>
<summary>iOS</summary>

On iOS you'll need to add the following entries to your Info.plist file (located under ios/Runner) in order to access the device's location. Simply open your Info.plist file and add the following (make sure you update the description so it is meaningfull in the context of your App):

``` xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location when in the background.</string>
```

If you would like to receive updates when your App is in the background, you'll also need to add the Background Modes capability to your XCode project (Project > Signing and Capabilities > "+ Capability" button) and select Location Updates. Be careful with this, you will need to explain in detail to Apple why your App needs this when submitting your App to the AppStore. If Apple isn't satisfied with the explanation your App will be rejected.

When using the `requestTemporaryFullAccuracy({purposeKey: "YourPurposeKey"})` method, a dictionary should be added to the Info.plist file.
```xml
<key>NSLocationTemporaryUsageDescriptionDictionary</key>
<dict>
  <key>YourPurposeKey</key>
  <string>The example App requires temporary access to the device&apos;s precise location.</string>
</dict>
```
The second key (in this example called `YourPurposeKey`) should match the purposeKey that is passed in the `requestTemporaryFullAccuracy()` method. It is possible to define multiple keys for different features in your app. More information can be found in Apple's [documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationtemporaryusagedescriptiondictionary).

> NOTE: the first time requesting temporary full accuracy access it might take several seconds for the pop-up to show. This is due to the fact that iOS is determining the exact user location which may take several seconds. Unfortunately this is out of our hands.
</details>



### 2. Configure baidu lbs sdk api keys:

Edit  *android/app/src/Manifest.xml*, and add the following code in `<Application>` Node:

```
<meta-data
    android:name="com.baidu.lbsapi.API_KEY"
    android:value="YOUR API KEY" />
```

### 3. Config amap android dependence

Edit *android/app/build.gradle*, add this to dependencies:

```
dependencies
{
    implementation('com.amap.api:location:6.0.1')
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
