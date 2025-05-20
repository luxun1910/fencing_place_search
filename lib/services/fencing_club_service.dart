import 'dart:io';

import 'package:fencing_place_search/models/fencing_club.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart';

/// フェンシングクラブのデータを取得するサービス
class FencingClubService {
  /// フェンシングクラブのデータを取得する
  static Future<List<FencingClub>> fetchFencingClubData() async {
    final url = "https://fencing-jpn.jp/training_place/";
    final target = Uri.parse(url);
    late Response response;

    try {
      response = await http.get(target);
    } catch (SocketException) {
      exit(0);
    }

    if (response.statusCode != 200) {
      print('ERROR: ${response.statusCode}');
      exit(0);
    }

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

    var clubDataList = <FencingClub>[];

    for (var i = 0; i < names!.length; i++) {
      clubDataList.add(FencingClub(
          prefectures![i],
          names[i],
          homePages![i],
          addresses![i],
          qualifications![i],
          fees![i],
          dates![i],
          remarkses![i]));
    }

    return clubDataList.skip(1).toList();
  }
}
