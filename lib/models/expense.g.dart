// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 2;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as String,
      tripId: fields[1] as String,
      description: fields[2] as String,
      amount: fields[3] as double,
      currency: fields[4] as String,
      paidById: fields[5] as String,
      participantIds: (fields[6] as List).cast<String>(),
      shares: (fields[7] as Map).cast<String, double>(),
      categoryId: fields[8] as String,
      dateTime: fields[9] as DateTime,
      notes: fields[10] as String?,
      receiptImageUrl: fields[11] as String?,
      splitType: fields[12] as String,
      isSettled: fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tripId)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.paidById)
      ..writeByte(6)
      ..write(obj.participantIds)
      ..writeByte(7)
      ..write(obj.shares)
      ..writeByte(8)
      ..write(obj.categoryId)
      ..writeByte(9)
      ..write(obj.dateTime)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.receiptImageUrl)
      ..writeByte(12)
      ..write(obj.splitType)
      ..writeByte(13)
      ..write(obj.isSettled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
