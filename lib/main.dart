import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'TypeAdapter/markerInfo.dart';

class FencingClub {
  late String Prefecture;
  late String Name;
  late String HomePage;
  late String Address;
  late String Qualification;
  late String Fee;
  late String Date;
  late String Remarks;
  FencingClub(String prefecture, String name, String homePage, String address,
      String qualification, String fee, String date, String remarks) {
    Prefecture = prefecture;
    Name = name;
    HomePage = homePage;
    Address = address;
    Qualification = qualification;
    Fee = fee;
    Date = date;
    Remarks = remarks;
  }
}

late Box markerInfoBox;

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(MarkerInfoAdapter());

  markerInfoBox = await Hive.openBox<MarkerInfo>("box");

  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  final fencingClubDataList = <FencingClub>[];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'フェンシング練習場',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          textTheme:
              GoogleFonts.sawarabiGothicTextTheme(Theme.of(context).textTheme)),
      home: MyHomePage(
        title: 'フェンシング練習場マップ',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
    final url = "https://fencing-jpn.jp/training_place/";
    final target = Uri.parse(url);
    late Response response;

    try {
      response = await http.get(target);
    } catch (SocketException) {
      //ダイアログを入れる処理をしたい

      exit(0);
    }

    if (response.statusCode != 200) {
      //ここもダイアログ入れたい
      print('ERROR: ${response.statusCode}');
      exit(0);
    }

    RegExp regExp = new RegExp(
      r'(?<=href=").*(?=" )|(?<=href=").*(?=")',
      caseSensitive: false,
      multiLine: false,
    );

    final document = parse(response.body);

    final result = document.getElementById('tablepress-1');

    final prefectures =
        result?.getElementsByClassName("column-1").map((e) => e.text).toList();

    final names_and_homePages = result?.getElementsByClassName("column-2");

    final names = names_and_homePages?.map((e) => e.text).toList();

    final homePages = names_and_homePages
        ?.map((element) => element.querySelector("a")?.attributes["href"] ?? "")
        .toList();

    final addresses =
        result?.getElementsByClassName("column-3").map((e) => e.text).toList();

    final qualifications =
        result?.getElementsByClassName("column-4").map((e) => e.text).toList();

    final fees =
        result?.getElementsByClassName("column-5").map((e) => e.text).toList();

    final dates =
        result?.getElementsByClassName("column-6").map((e) => e.text).toList();

    final remarkses =
        result?.getElementsByClassName("column-7").map((e) => e.text).toList();

    print(result);

    var clubDataList = <FencingClub>[];

    for (var i = 0; i < names!.length; i++) {
      clubDataList.add(new FencingClub(
          prefectures![i],
          names[i],
          homePages![i],
          addresses![i],
          qualifications![i],
          fees![i],
          dates![i],
          remarkses![i]));
    }

    setState(() {
      _initialFencingClubDataList = clubDataList.skip(1).toList();
      _fencingClubDataList = _initialFencingClubDataList;
      _isExpanded = new List.filled(_fencingClubDataList.length, false);
      _clubDataLoading = false;
    });
  }

  //現在位置を更新し続ける
  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _initialPosition = LatLng(position.latitude, position.longitude);

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
        setLocaleIdentifier('ja_JP');
        try {
          location =
              await locationFromAddress(_initialFencingClubDataList[i].Address);
        } catch (e) {
        } finally {}

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
      if(marker != null){
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
          return Container(
              margin: EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  border: TableBorder.all(color: Colors.black),
                  defaultVerticalAlignment: TableCellVerticalAlignment.top,
                  children: [
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child: Text("クラブ名"),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child: SelectableText(_fencingClubDataList[index].Name,
                            key: PageStorageKey("prefecture")),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child: Text("地域"),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child: SelectableText(
                            _fencingClubDataList[index].Prefecture,
                            key: PageStorageKey("prefecture")),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child: Text("住所・最寄り駅駐車場"),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child:
                            SelectableText(_fencingClubDataList[index].Address),
                        key: PageStorageKey("address"),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child: const Text("参加資格"),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child: SelectableText(
                            _fencingClubDataList[index].Qualification,
                            key: PageStorageKey("qualification")),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child: const Text("費用"),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                          child:
                              SelectableText(_fencingClubDataList[index].Fee),
                          key: PageStorageKey("fee")),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child: const Text("練習日"),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                          child:
                              SelectableText(_fencingClubDataList[index].Date),
                          key: PageStorageKey("date")),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child: const Text("ホームページ"),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child: GestureDetector(
                            onTap: () => _launchURL(Uri.parse(
                                _fencingClubDataList[index].HomePage)),
                            child: Text(
                              _fencingClubDataList[index].HomePage,
                              style: TextStyle(color: Colors.blue),
                            )),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child: const Text("備考"),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                        child: SelectableText(
                            _fencingClubDataList[index].Remarks,
                            key: PageStorageKey("remarks")),
                      ),
                    ]),
                  ],
                ),
              ));
        });
  }

  _launchURL(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $uri';
    }
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: TabBarView(
          key: const PageStorageKey<String>("tabBar"),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _clubDataLoading
                ? const CircularProgressIndicator()
                : Center(
                    // Center is a layout widget. It takes a single child and positions it
                    // in the middle of the parent.
                    child: Column(
                      // Column is also a layout widget. It takes a list of children and
                      // arranges them vertically. By default, it sizes itself to fit its
                      // children horizontally, and tries to be as tall as its parent.
                      //
                      // Invoke "debug painting" (press "p" in the console, choose the
                      // "Toggle Debug Paint" action from the Flutter Inspector in Android
                      // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                      // to see the wireframe for each widget.
                      //
                      // Column has various properties to control how it sizes itself and
                      // how it positions its children. Here we use mainAxisAlignment to
                      // center the children vertically; the main axis here is the vertical
                      // axis because Columns are vertical (the cross axis would be
                      // horizontal).
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(_fencingClubDataList[_topIndex].Prefecture),
                        Flexible(
                          child: ScrollablePositionedList.builder(
                              key:
                                  PageStorageKey<String>("fencingClubDataList"),
                              itemPositionsListener: _itemPositionsListener,
                              shrinkWrap: false,
                              itemCount: _fencingClubDataList.length,
                              itemBuilder: (BuildContext context, index) {
                                return ExpansionTile(
                                  key: PageStorageKey<int>(index),
                                  maintainState: true,
                                  textColor: Colors.black,
                                  onExpansionChanged: (bool isExpand) {
                                    setState(
                                        () => _isExpanded[index] = isExpand);
                                  },
                                  title: Text(_fencingClubDataList[index].Name,
                                      style: TextStyle(
                                          fontWeight: _isExpanded[index]
                                              ? FontWeight.bold
                                              : FontWeight.normal)),
                                  expandedAlignment: Alignment.centerLeft,
                                  expandedCrossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Table(
                                        border: TableBorder.all(
                                            color: Colors.black),
                                        defaultVerticalAlignment:
                                            TableCellVerticalAlignment.top,
                                        children: [
                                          TableRow(children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      4.0, 0, 0, 0),
                                              child: Text("地域"),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      4.0, 0, 0, 0),
                                              child: SelectableText(
                                                  _fencingClubDataList[index]
                                                      .Prefecture,
                                                  key: PageStorageKey(
                                                      "prefecture")),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      4.0, 0, 0, 0),
                                              child: Text("住所・最寄り駅駐車場"),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      4.0, 0, 0, 0),
                                              child: SelectableText(
                                                  _fencingClubDataList[index]
                                                      .Address),
                                              key: PageStorageKey("address"),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      4.0, 0, 0, 0),
                                              child: const Text("参加資格"),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      4.0, 0, 0, 0),
                                              child: SelectableText(
                                                  _fencingClubDataList[index]
                                                      .Qualification,
                                                  key: PageStorageKey(
                                                      "qualification")),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      4.0, 0, 0, 0),
                                              child: const Text("費用"),
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        4.0, 0, 0, 0),
                                                child: SelectableText(
                                                    _fencingClubDataList[index]
                                                        .Fee),
                                                key: PageStorageKey("fee")),
                                          ]),
                                          TableRow(children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      4.0, 0, 0, 0),
                                              child: const Text("練習日"),
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        4.0, 0, 0, 0),
                                                child: SelectableText(
                                                    _fencingClubDataList[index]
                                                        .Date),
                                                key: PageStorageKey("date")),
                                          ]),
                                          TableRow(children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      4.0, 0, 0, 0),
                                              child: const Text("ホームページ"),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      4.0, 0, 0, 0),
                                              child: GestureDetector(
                                                  onTap: () => _launchURL(
                                                      Uri.parse(
                                                          _fencingClubDataList[
                                                                  index]
                                                              .HomePage)),
                                                  child: Text(
                                                    _fencingClubDataList[index]
                                                        .HomePage,
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                  )),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      4.0, 0, 0, 0),
                                              child: const Text("備考"),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      4.0, 0, 0, 0),
                                              child: SelectableText(
                                                  _fencingClubDataList[index]
                                                      .Remarks,
                                                  key: PageStorageKey(
                                                      "remarks")),
                                            ),
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                        Container(
                            alignment: Alignment.center,
                            child: AdWidget(ad: myBanner),
                            width: myBanner.size.width.toDouble(),
                            height: myBanner.size.height.toDouble()),
                      ],
                    ),
                  ),
            _mapLoading || _markerLoading
                ? const CircularProgressIndicator()
                : Center(
                    child:
                        MyMap(_clubMarkerSet, _initialPosition, _controller)),
            Card(
              elevation: 4.0,
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            const AssetImage('assets/myfencing.jpg'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: SvgPicture.asset(
                              'assets/mark-github.svg',
                              semanticsLabel: 'shopping',
                              width: 50,
                              height: 50,
                            ),
                            onPressed: () {
                              _launchURL(Uri.parse(
                                  "https://github.com/luxun1910"));
                            },
                          ),
                          IconButton(
                            icon: SvgPicture.asset(
                              'assets/Twitter-logo.svg',
                              semanticsLabel: 'shopping',
                              width: 50,
                              height: 50,
                            ),
                            onPressed: () {
                              _launchURL(Uri.parse(
                                  "https://twitter.com/unanimity1910"));
                            },
                          ),
                          IconButton(
                            iconSize: 40,
                            icon: Icon(Icons.email),
                            onPressed: () => _launchURL(Uri.parse(
                                "mailto:luxun.unanimity1910@gmail.com")),
                          ),
                        ],
                      ),
                      const Text("エペをやっているフェンサーです。\nご意見・ご感想など、お気軽にお問い合わせください。"),
                      ListTile(
                        onTap:() {
                              _launchURL(Uri.parse(
                                  "https://luxun1910.github.io/unanimousworks_privacy_policy/fencing_place_search.html"));
                            },
                        title: Text("プライバシーポリシー",
                        style: const TextStyle(color: Colors.blue),),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const TabBar(
          tabs: const [
            const Tab(icon: Icon(Icons.list_alt, color: Colors.indigo)),
            const Tab(icon: Icon(Icons.map_outlined, color: Colors.indigo)),
            const Tab(icon: Icon(Icons.person, color: Colors.indigo))
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

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() =>
      _MyMapState(clubMarkerSet, initialPosition, controller);

  final Set<Marker> clubMarkerSet;
  final LatLng initialPosition;
  final Completer<GoogleMapController> controller;

  MyMap(this.clubMarkerSet, this.initialPosition, this.controller);
}

class _MyMapState extends State<MyMap>
    with AutomaticKeepAliveClientMixin<MyMap> {
  final Set<Marker> _clubMarkerSet;
  final LatLng _initialPosition;
  late Completer<GoogleMapController> _controller;

  _MyMapState(this._clubMarkerSet, this._initialPosition, this._controller)
      : super();

  @override
  Widget build(BuildContext context) {
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
