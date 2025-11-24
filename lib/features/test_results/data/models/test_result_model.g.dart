// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TestResultModelAdapter extends TypeAdapter<TestResultModel> {
  @override
  final int typeId = 0;

  @override
  TestResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestResultModel(
      sessionId: fields[0] as String,
      totalScore: fields[1] as double,
      categoryScores: (fields[2] as Map).cast<String, int>(),
      feedback: fields[3] as String,
      completedAt: fields[4] as DateTime,
      testName: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TestResultModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.totalScore)
      ..writeByte(2)
      ..write(obj.categoryScores)
      ..writeByte(3)
      ..write(obj.feedback)
      ..writeByte(4)
      ..write(obj.completedAt)
      ..writeByte(5)
      ..write(obj.testName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
