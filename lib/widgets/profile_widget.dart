import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/url_launcher_util.dart';

/// プロフィールを表示するウィジェット
class ProfileWidget extends StatelessWidget {
  /// コンストラクタ
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
                backgroundImage: const AssetImage('assets/myfencing.jpg'),
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
                      launchURL(Uri.parse("https://github.com/luxun1910"));
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
                      launchURL(Uri.parse("https://twitter.com/unanimity1910"));
                    },
                  ),
                  IconButton(
                    iconSize: 40,
                    icon: Icon(Icons.email),
                    onPressed: () => launchURL(
                        Uri.parse("mailto:luxun.unanimity1910@gmail.com")),
                  ),
                ],
              ),
              const Text("エペをやっているフェンサーです。\nご意見・ご感想など、お気軽にお問い合わせください。"),
              ListTile(
                onTap: () {
                  launchURL(Uri.parse(
                      "https://luxun1910.github.io/unanimousworks_privacy_policy/fencing_place_search.html"));
                },
                title: Text(
                  "プライバシーポリシー",
                  style: const TextStyle(color: Colors.blue),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
