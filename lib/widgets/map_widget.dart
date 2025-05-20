import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// マップを表示するウィジェット
class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() =>
      _MyMapState(clubMarkerSet, initialPosition, controller);

  final Set<Marker> clubMarkerSet;
  final LatLng initialPosition;
  final Completer<GoogleMapController> controller;

  MyMap(this.clubMarkerSet, this.initialPosition, this.controller);
}

/// マップを表示するウィジェットのステート
class _MyMapState extends State<MyMap>
    with AutomaticKeepAliveClientMixin<MyMap> {
  /// マップのマーカー
  final Set<Marker> _clubMarkerSet;

  /// 初期位置
  final LatLng _initialPosition;

  /// コントローラ
  late Completer<GoogleMapController> _controller;

  /// コンストラクタ
  _MyMapState(this._clubMarkerSet, this._initialPosition, this._controller)
      : super();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GoogleMap(
      key: PageStorageKey<String>("googleMap"),
      mapType: MapType.normal,
      markers: _clubMarkerSet,
      initialCameraPosition: CameraPosition(
        target: _initialPosition,
        zoom: 10,
      ),
      myLocationEnabled: true, //現在位置をマップ上に表示
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
