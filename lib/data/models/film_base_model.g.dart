// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'film_base_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FilmBaseModelAdapter extends TypeAdapter<FilmBaseModel> {
  @override
  final int typeId = 1;

  @override
  FilmBaseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FilmBaseModel(
      kinopoiskId: fields[0] as int?,
      nameRu: fields[1] as String?,
      nameEn: fields[2] as String?,
      nameOriginal: fields[3] as String?,
      countries: (fields[4] as List?)?.cast<String>(),
      genres: (fields[5] as List?)?.cast<String>(),
      ratingKinopoisk: fields[6] as num?,
      ratingImbd: fields[7] as num?,
      year: fields[8] as int?,
      type: fields[9] as String?,
      posterUrl: fields[10] as String?,
      posterUrlPreview: fields[11] as String?,
      collectionIds: (fields[12] as List?)?.cast<String>(),
      userComment: fields[13] as String?,
      userRating: fields[14] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, FilmBaseModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.kinopoiskId)
      ..writeByte(1)
      ..write(obj.nameRu)
      ..writeByte(2)
      ..write(obj.nameEn)
      ..writeByte(3)
      ..write(obj.nameOriginal)
      ..writeByte(4)
      ..write(obj.countries)
      ..writeByte(5)
      ..write(obj.genres)
      ..writeByte(6)
      ..write(obj.ratingKinopoisk)
      ..writeByte(7)
      ..write(obj.ratingImbd)
      ..writeByte(8)
      ..write(obj.year)
      ..writeByte(9)
      ..write(obj.type)
      ..writeByte(10)
      ..write(obj.posterUrl)
      ..writeByte(11)
      ..write(obj.posterUrlPreview)
      ..writeByte(12)
      ..write(obj.collectionIds)
      ..writeByte(13)
      ..write(obj.userComment)
      ..writeByte(14)
      ..write(obj.userRating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilmBaseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
