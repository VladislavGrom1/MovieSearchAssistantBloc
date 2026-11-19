// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AiSessionModelAdapter extends TypeAdapter<AiSessionModel> {
  @override
  final int typeId = 5;

  @override
  AiSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiSessionModel(
      id: fields[0] as int,
      createdAt: fields[1] as DateTime,
      updatedAt: fields[2] as DateTime,
      schemaVersion: fields[3] as int,
      turns: (fields[4] as List).cast<AiSessionTurnModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, AiSessionModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.updatedAt)
      ..writeByte(3)
      ..write(obj.schemaVersion)
      ..writeByte(4)
      ..write(obj.turns);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AiSessionTurnModelAdapter extends TypeAdapter<AiSessionTurnModel> {
  @override
  final int typeId = 6;

  @override
  AiSessionTurnModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiSessionTurnModel(
      id: fields[0] as int,
      query: fields[1] as String,
      onlyNew: fields[2] as bool,
      createdAt: fields[3] as DateTime,
      status: fields[4] as String,
      films: (fields[5] as List).cast<AiFilmSnapshotModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, AiSessionTurnModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.query)
      ..writeByte(2)
      ..write(obj.onlyNew)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.films);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiSessionTurnModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AiFilmSnapshotModelAdapter extends TypeAdapter<AiFilmSnapshotModel> {
  @override
  final int typeId = 7;

  @override
  AiFilmSnapshotModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiFilmSnapshotModel(
      kinopoiskId: fields[0] as int?,
      nameRu: fields[1] as String?,
      nameOriginal: fields[2] as String?,
      year: fields[3] as int?,
      genres: (fields[4] as List).cast<String>(),
      ratingKinopoisk: fields[5] as num?,
      posterPath: fields[6] as String?,
      description: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AiFilmSnapshotModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.kinopoiskId)
      ..writeByte(1)
      ..write(obj.nameRu)
      ..writeByte(2)
      ..write(obj.nameOriginal)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.genres)
      ..writeByte(5)
      ..write(obj.ratingKinopoisk)
      ..writeByte(6)
      ..write(obj.posterPath)
      ..writeByte(7)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiFilmSnapshotModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
