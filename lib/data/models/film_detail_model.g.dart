// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'film_detail_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FilmDetailModelAdapter extends TypeAdapter<FilmDetailModel> {
  @override
  final int typeId = 2;

  @override
  FilmDetailModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FilmDetailModel(
      filmBaseModel: fields[0] as FilmBaseModel,
      kinopoiskHDId: fields[1] as String?,
      imdbId: fields[2] as String?,
      coverUrl: fields[3] as String?,
      logoUrl: fields[4] as String?,
      reviewsCount: fields[5] as int?,
      ratingGoodReview: fields[6] as num?,
      ratingGoodReviewVoteCount: fields[7] as int?,
      ratingKinopoiskVoteCount: fields[8] as int?,
      ratingImdbVoteCount: fields[9] as int?,
      ratingFilmCritics: fields[10] as num?,
      ratingFilmCriticsVoteCount: fields[11] as int?,
      ratingAwait: fields[12] as num?,
      ratingAwaitCount: fields[13] as int?,
      ratingRfCritics: fields[14] as num?,
      ratingRfCriticsVoteCount: fields[15] as int?,
      webUrl: fields[16] as String?,
      filmLength: fields[17] as int?,
      slogan: fields[18] as String?,
      description: fields[19] as String?,
      shortDescription: fields[20] as String?,
      editorAnnotation: fields[21] as String?,
      isTicketsAvailable: fields[22] as bool?,
      productionStatus: fields[23] as String?,
      ratingMpaa: fields[24] as String?,
      ratingAgeLimits: fields[25] as String?,
      hasImax: fields[26] as bool?,
      has3D: fields[27] as bool?,
      lastSync: fields[28] as String?,
      startYear: fields[29] as int?,
      endYear: fields[30] as int?,
      serial: fields[31] as bool?,
      shortFilm: fields[32] as bool?,
      completed: fields[33] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, FilmDetailModel obj) {
    writer
      ..writeByte(34)
      ..writeByte(0)
      ..write(obj.filmBaseModel)
      ..writeByte(1)
      ..write(obj.kinopoiskHDId)
      ..writeByte(2)
      ..write(obj.imdbId)
      ..writeByte(3)
      ..write(obj.coverUrl)
      ..writeByte(4)
      ..write(obj.logoUrl)
      ..writeByte(5)
      ..write(obj.reviewsCount)
      ..writeByte(6)
      ..write(obj.ratingGoodReview)
      ..writeByte(7)
      ..write(obj.ratingGoodReviewVoteCount)
      ..writeByte(8)
      ..write(obj.ratingKinopoiskVoteCount)
      ..writeByte(9)
      ..write(obj.ratingImdbVoteCount)
      ..writeByte(10)
      ..write(obj.ratingFilmCritics)
      ..writeByte(11)
      ..write(obj.ratingFilmCriticsVoteCount)
      ..writeByte(12)
      ..write(obj.ratingAwait)
      ..writeByte(13)
      ..write(obj.ratingAwaitCount)
      ..writeByte(14)
      ..write(obj.ratingRfCritics)
      ..writeByte(15)
      ..write(obj.ratingRfCriticsVoteCount)
      ..writeByte(16)
      ..write(obj.webUrl)
      ..writeByte(17)
      ..write(obj.filmLength)
      ..writeByte(18)
      ..write(obj.slogan)
      ..writeByte(19)
      ..write(obj.description)
      ..writeByte(20)
      ..write(obj.shortDescription)
      ..writeByte(21)
      ..write(obj.editorAnnotation)
      ..writeByte(22)
      ..write(obj.isTicketsAvailable)
      ..writeByte(23)
      ..write(obj.productionStatus)
      ..writeByte(24)
      ..write(obj.ratingMpaa)
      ..writeByte(25)
      ..write(obj.ratingAgeLimits)
      ..writeByte(26)
      ..write(obj.hasImax)
      ..writeByte(27)
      ..write(obj.has3D)
      ..writeByte(28)
      ..write(obj.lastSync)
      ..writeByte(29)
      ..write(obj.startYear)
      ..writeByte(30)
      ..write(obj.endYear)
      ..writeByte(31)
      ..write(obj.serial)
      ..writeByte(32)
      ..write(obj.shortFilm)
      ..writeByte(33)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilmDetailModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
