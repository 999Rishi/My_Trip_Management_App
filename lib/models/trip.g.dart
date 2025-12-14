// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripAdapter extends TypeAdapter<Trip> {
  @override
  final int typeId = 1;

  @override
  Trip read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Trip(
      id: fields[0] as String,
      name: fields[1] as String,
      imageUrl: fields[2] as String?,
      startDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime,
      memberIds: (fields[5] as List).cast<String>(),
      ownerId: fields[6] as String,
      adminIds: (fields[7] as List).cast<String>(),
      baseCurrency: fields[8] as String,
      isArchived: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Trip obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.memberIds)
      ..writeByte(6)
      ..write(obj.ownerId)
      ..writeByte(7)
      ..write(obj.adminIds)
      ..writeByte(8)
      ..write(obj.baseCurrency)
      ..writeByte(9)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
