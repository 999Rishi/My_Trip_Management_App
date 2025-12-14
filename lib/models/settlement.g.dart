// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettlementAdapter extends TypeAdapter<Settlement> {
  @override
  final int typeId = 4;

  @override
  Settlement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settlement(
      id: fields[0] as String,
      tripId: fields[1] as String,
      fromUserId: fields[2] as String,
      toUserId: fields[3] as String,
      amount: fields[4] as double,
      currency: fields[5] as String,
      dateTime: fields[6] as DateTime,
      notes: fields[7] as String?,
      paymentMethod: fields[8] as String,
      isSettled: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Settlement obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tripId)
      ..writeByte(2)
      ..write(obj.fromUserId)
      ..writeByte(3)
      ..write(obj.toUserId)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.currency)
      ..writeByte(6)
      ..write(obj.dateTime)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.paymentMethod)
      ..writeByte(9)
      ..write(obj.isSettled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettlementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
