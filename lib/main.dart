import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'TypeAdapter/markerInfo.dart';
import 'screens/home_page.dart';

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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'フェンシング練習場',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme:
              GoogleFonts.sawarabiGothicTextTheme(Theme.of(context).textTheme)),
      home: MyHomePage(
        title: 'フェンシング練習場マップ',
      ),
    );
  }
}
