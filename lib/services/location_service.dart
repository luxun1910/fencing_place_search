import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 位置情報を取得するサービス
class LocationService {
  static final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
  );

  /// 現在の位置情報を取得する
  static Future<Position> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings);
  }

  /// 現在の位置情報を取得する
  static Future<LatLng> getCurrentLatLng() async {
    Position position = await getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  /// 住所から位置情報を取得する
  static Future<List<Location>> getLocationFromAddress(String address) async {
    setLocaleIdentifier('ja_JP');
    try {
      return await locationFromAddress(address);
    } catch (e) {
      return [];
    }
  }
}
