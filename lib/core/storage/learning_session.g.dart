// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LearningSessionAdapter extends TypeAdapter<LearningSession> {
  @override
  final int typeId = 1;

  @override
  LearningSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LearningSession(
      topicId: fields[0] as String,
      subtopicCode: fields[1] as String,
      currentStepIndex: fields[2] as int,
      completedStepIds: (fields[3] as List).cast<String>(),
      startedAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      synced: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LearningSession obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.topicId)
      ..writeByte(1)
      ..write(obj.subtopicCode)
      ..writeByte(2)
      ..write(obj.currentStepIndex)
      ..writeByte(3)
      ..write(obj.completedStepIds)
      ..writeByte(4)
      ..write(obj.startedAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
