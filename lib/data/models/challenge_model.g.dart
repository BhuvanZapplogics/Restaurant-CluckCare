// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeModelAdapter extends TypeAdapter<ChallengeModel> {
  @override
  final int typeId = 100;

  @override
  ChallengeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      points: fields[4] as int,
      startDate: fields[5] as DateTime,
      endDate: fields[6] as DateTime,
      createdBy: fields[7] as String,
      createdAt: fields[8] as DateTime,
      participants: (fields[9] as List).cast<String>(),
      progress: (fields[10] as Map).cast<String, dynamic>(),
      isActive: fields[11] as bool,
      difficulty: fields[12] as String,
      tags: (fields[13] as List).cast<String>(),
      imageUrl: fields[14] as String,
      requirements: (fields[15] as Map).cast<String, dynamic>(),
      rewards: (fields[16] as Map).cast<String, dynamic>(),
      maxParticipants: fields[17] as int,
      isPublic: fields[18] as bool,
      admins: (fields[19] as List).cast<String>(),
      settings: (fields[20] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.points)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.endDate)
      ..writeByte(7)
      ..write(obj.createdBy)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.participants)
      ..writeByte(10)
      ..write(obj.progress)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.difficulty)
      ..writeByte(13)
      ..write(obj.tags)
      ..writeByte(14)
      ..write(obj.imageUrl)
      ..writeByte(15)
      ..write(obj.requirements)
      ..writeByte(16)
      ..write(obj.rewards)
      ..writeByte(17)
      ..write(obj.maxParticipants)
      ..writeByte(18)
      ..write(obj.isPublic)
      ..writeByte(19)
      ..write(obj.admins)
      ..writeByte(20)
      ..write(obj.settings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
