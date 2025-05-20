import 'package:url_launcher/url_launcher.dart';

/// URLを開く
Future<void> launchURL(Uri uri) async {
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $uri';
  }
}
