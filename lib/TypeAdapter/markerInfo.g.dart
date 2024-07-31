// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'markerInfo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarkerInfoAdapter extends TypeAdapter<MarkerInfo> {
  @override
  final int typeId = 0;

  @override
  MarkerInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarkerInfo(
      markerID: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      infoWindowTitle: fields[3] as String,
      infoWindowSnippet: fields[4] as String,
      address: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MarkerInfo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.markerID)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.infoWindowTitle)
      ..writeByte(4)
      ..write(obj.infoWindowSnippet)
      ..writeByte(5)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkerInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
