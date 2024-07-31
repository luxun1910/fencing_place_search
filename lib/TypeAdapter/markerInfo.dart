import 'package:hive/hive.dart';
part 'markerInfo.g.dart';

@HiveType(typeId: 0)
class MarkerInfo extends HiveObject {
  @HiveField(0)
  String markerID;

  @HiveField(1)
  late double latitude;

  @HiveField(2)
  late double longitude;

  @HiveField(3)
  String infoWindowTitle;

  @HiveField(4)
  String infoWindowSnippet;

  @HiveField(5)
  String? address;

  MarkerInfo(
      {required this.markerID,
      required this.latitude,
      required this.longitude,
      required this.infoWindowTitle,
      required this.infoWindowSnippet,
      required this.address});
}
