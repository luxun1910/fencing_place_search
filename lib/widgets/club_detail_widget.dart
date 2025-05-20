import 'package:flutter/material.dart';

import '../models/fencing_club.dart';
import '../utils/url_launcher_util.dart';

/// フェンシングクラブの詳細を表示するウィジェット
class ClubDetailWidget extends StatelessWidget {
  /// フェンシングクラブのデータ
  final FencingClub club;

  /// コンストラクタ
  const ClubDetailWidget({
    Key? key,
    required this.club,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                child:
                    SelectableText(club.Name, key: PageStorageKey("clubName")),
              ),
            ]),
            TableRow(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                child: Text("地域"),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                child: SelectableText(club.Prefecture,
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
                child: SelectableText(club.Address),
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
                child: SelectableText(club.Qualification,
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
                  child: SelectableText(club.Fee),
                  key: PageStorageKey("fee")),
            ]),
            TableRow(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                child: const Text("練習日"),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                  child: SelectableText(club.Date),
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
                    onTap: () => launchURL(Uri.parse(club.HomePage)),
                    child: Text(
                      club.HomePage,
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
                child: SelectableText(club.Remarks,
                    key: PageStorageKey("remarks")),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
