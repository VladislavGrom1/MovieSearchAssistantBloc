// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'film_collection_link.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FilmCollectionLinkAdapter extends TypeAdapter<FilmCollectionLink> {
  @override
  final int typeId = 4;

  @override
  FilmCollectionLink read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FilmCollectionLink(
      filmId: fields[0] as int,
      collectionId: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FilmCollectionLink obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.filmId)
      ..writeByte(1)
      ..write(obj.collectionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilmCollectionLinkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
