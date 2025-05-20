import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/fencing_club.dart';
import '../utils/url_launcher_util.dart';

/// フェンシングクラブのリストを表示するウィジェット
class ClubListWidget extends StatefulWidget {
  /// フェンシングクラブのデータリスト
  final List<FencingClub> fencingClubDataList;

  /// アイテムの位置リスナー
  final ItemPositionsListener itemPositionsListener;

  /// 上部のインデックス
  final int topIndex;

  /// バナー広告
  final BannerAd bannerAd;

  /// コンストラクタ
  const ClubListWidget({
    Key? key,
    required this.fencingClubDataList,
    required this.itemPositionsListener,
    required this.topIndex,
    required this.bannerAd,
  }) : super(key: key);

  @override
  _ClubListWidgetState createState() => _ClubListWidgetState();
}

/// フェンシングクラブのリストを表示するウィジェットのステート
class _ClubListWidgetState extends State<ClubListWidget> {
  /// リストが展開されているか
  late List<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = List.filled(widget.fencingClubDataList.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(widget.fencingClubDataList[widget.topIndex].Prefecture),
        Flexible(
          child: ScrollablePositionedList.builder(
              key: PageStorageKey<String>("fencingClubDataList"),
              itemPositionsListener: widget.itemPositionsListener,
              shrinkWrap: false,
              itemCount: widget.fencingClubDataList.length,
              itemBuilder: (BuildContext context, index) {
                return ExpansionTile(
                  key: PageStorageKey<int>(index),
                  maintainState: true,
                  textColor: Colors.black,
                  onExpansionChanged: (bool isExpand) {
                    setState(() => _isExpanded[index] = isExpand);
                  },
                  title: Text(widget.fencingClubDataList[index].Name,
                      style: TextStyle(
                          fontWeight: _isExpanded[index]
                              ? FontWeight.bold
                              : FontWeight.normal)),
                  expandedAlignment: Alignment.centerLeft,
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Table(
                        border: TableBorder.all(color: Colors.black),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.top,
                        children: [
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                              child: Text("地域"),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                              child: SelectableText(
                                  widget.fencingClubDataList[index].Prefecture,
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
                              child: SelectableText(
                                  widget.fencingClubDataList[index].Address),
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
                                  widget
                                      .fencingClubDataList[index].Qualification,
                                  key: PageStorageKey("qualification")),
                            ),
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                              child: const Text("費用"),
                            ),
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                                child: SelectableText(
                                    widget.fencingClubDataList[index].Fee),
                                key: PageStorageKey("fee")),
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                              child: const Text("練習日"),
                            ),
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                                child: SelectableText(
                                    widget.fencingClubDataList[index].Date),
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
                                  onTap: () => launchURL(Uri.parse(widget
                                      .fencingClubDataList[index].HomePage)),
                                  child: Text(
                                    widget.fencingClubDataList[index].HomePage,
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
                                  widget.fencingClubDataList[index].Remarks,
                                  key: PageStorageKey("remarks")),
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
            child: AdWidget(ad: widget.bannerAd),
            width: widget.bannerAd.size.width.toDouble(),
            height: widget.bannerAd.size.height.toDouble()),
      ],
    );
  }
}
