import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:fencing_place_search/models/fencing_club.dart';
import 'package:fencing_place_search/widgets/map_widget.dart';
import 'package:fencing_place_search/widgets/profile_widget.dart';
import 'package:fencing_place_search/widgets/club_list_widget.dart';
import 'package:fencing_place_search/widgets/club_detail_widget.dart';
import 'package:fencing_place_search/services/location_service.dart';
import 'package:fencing_place_search/services/fencing_club_service.dart';
import 'package:fencing_place_search/TypeAdapter/markerInfo.dart';

// main.dartからのグローバル変数参照
import '../main.dart' show markerInfoBox;

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position? currentPosition;

  late List<FencingClub> _initialFencingClubDataList;

  Completer<GoogleMapController> _controller = Completer();
  late StreamSubscription<Position> positionStream;
  //初期位置
  late LatLng _initialPosition;

  late Set<Marker> _clubMarkerSet;

  String selectedValue = "北海道";

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high, //正確性:highはAndroid(0-100m),iOS(10m)
    distanceFilter: 100,
  );

  late List<FencingClub> _fencingClubDataList;

  late bool _clubDataLoading;
  late bool _mapLoading;
  late bool _markerLoading;

  late int _topIndex;

  late List<bool> _isExpanded;

  // リストアイテムのインデックスを司るリスナー
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  final BannerAd myBanner = BannerAd(
    adUnitId: const String.fromEnvironment('bunnerAdUnitIDForAndroid'),
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );

  @override
  void initState() {
    super.initState();

    _clubDataLoading = true;
    _mapLoading = true;
    _markerLoading = true;

    myBanner.load();

    Future(() async {
      await _setFecningClubDataList();
      await _getUserLocation();
      await _createMarker();
    });

    _topIndex = 1;

    _itemPositionsListener.itemPositions.addListener(_itemPositionsCallback);
  }

  Future<void> _setFecningClubDataList() async {
    var clubDataList = await FencingClubService.fetchFencingClubData();

    setState(() {
      _initialFencingClubDataList = clubDataList;
      _fencingClubDataList = _initialFencingClubDataList;
      _isExpanded = List.filled(_fencingClubDataList.length, false);
      _clubDataLoading = false;
    });
  }

  //現在位置を更新し続ける
  Future<void> _getUserLocation() async {
    _initialPosition = await LocationService.getCurrentLatLng();

    setState(() {
      _mapLoading = false;
    });
  }

  Future<void> _createMarker() async {
    var fencingClubMapData = <Marker>{};

    for (int i = 0; i < _initialFencingClubDataList.length; i++) {
      var location = <Location>[];
      var clubMapInfo = await markerInfoBox.get(i);
      dynamic marker;

      // Hiveにデータがあり、住所が変わってない場合
      if (clubMapInfo != null &&
          clubMapInfo?.address == _initialFencingClubDataList[i].Address) {
        try {
          marker = Marker(
              onTap: () => {_showClubData(i)},
              markerId: MarkerId(clubMapInfo.markerID),
              position: LatLng(clubMapInfo.latitude, clubMapInfo.longitude));
        } catch (e) {}
      } else {
        location = await LocationService.getLocationFromAddress(
            _initialFencingClubDataList[i].Address);

        try {
          marker = Marker(
              onTap: () => {_showClubData(i)},
              markerId:
                  MarkerId("marker_${_initialFencingClubDataList[i].Name}"),
              position:
                  LatLng(location.first.latitude, location.first.longitude));
        } catch (e) {}

        if (location.isNotEmpty) {
          markerInfoBox.put(
              i,
              MarkerInfo(
                  markerID: "marker_${_initialFencingClubDataList[i].Name}",
                  latitude: location.first.latitude,
                  longitude: location.first.longitude,
                  infoWindowTitle: _initialFencingClubDataList[i].Name,
                  infoWindowSnippet: _initialFencingClubDataList[i].Date,
                  address: _initialFencingClubDataList[i].Address));
        }
      }
      if (marker != null) {
        fencingClubMapData.add(marker);
      }
    }

    _clubMarkerSet = fencingClubMapData;
    setState(() {
      _markerLoading = false;
    });
  }

  void _showClubData(int index) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return ClubDetailWidget(club: _fencingClubDataList[index]);
        });
  }

  List<DropdownMenuItem<String>> get prefectureDropdownItems {
    var menuItems = <DropdownMenuItem<String>>[];

    final prefectureList =
        _initialFencingClubDataList.map((data) => data.Prefecture).toSet();

    prefectureList.forEach((prefecture) {
      menuItems
          .add(DropdownMenuItem(child: Text(prefecture), value: prefecture));
    });
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: TabBarView(
          key: const PageStorageKey<String>("tabBar"),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _clubDataLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: ClubListWidget(
                      fencingClubDataList: _fencingClubDataList,
                      itemPositionsListener: _itemPositionsListener,
                      topIndex: _topIndex,
                      bannerAd: myBanner,
                    ),
                  ),
            _mapLoading || _markerLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child:
                        MyMap(_clubMarkerSet, _initialPosition, _controller)),
            const ProfileWidget(),
          ],
        ),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.list_alt, color: Colors.indigo)),
            Tab(icon: Icon(Icons.map_outlined, color: Colors.indigo)),
            Tab(icon: Icon(Icons.person, color: Colors.indigo))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 使い終わったら破棄
    _itemPositionsListener.itemPositions.removeListener(_itemPositionsCallback);
    super.dispose();
  }

  void _itemPositionsCallback() {
    // 表示中のリストアイテムのインデックス情報を取得
    final visibleIndexes = _itemPositionsListener.itemPositions.value
        .toList()
        .map((itemPosition) => itemPosition.index)
        .toList();
    visibleIndexes.sort();

    setState(() {
      _topIndex = visibleIndexes.first;
    });
  }
}
