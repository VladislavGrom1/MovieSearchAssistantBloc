import 'package:generated/generated.dart';
import 'package:hive/hive.dart';

part 'film_base_model.g.dart';

@HiveType(typeId: 1)
class FilmBaseModel {
  @HiveField(0) int? kinopoiskId;
  @HiveField(1) String? nameRu;
  @HiveField(2) String? nameEn;
  @HiveField(3) String? nameOriginal;
  @HiveField(4) List<String>? countries;
  @HiveField(5) List<String>? genres;
  @HiveField(6) num? ratingKinopoisk;
  @HiveField(7) num? ratingImbd;
  @HiveField(8) int? year;
  @HiveField(9) String? type;
  @HiveField(10) String? posterUrl;
  @HiveField(11) String? posterUrlPreview;
  @HiveField(12) String? userComment;
  @HiveField(13) int? userRating;

  FilmBaseModel({
    this.kinopoiskId,
    this.nameRu,
    this.nameEn,
    this.nameOriginal,
    this.countries,
    this.genres,
    this.ratingKinopoisk,
    this.ratingImbd,
    this.year,
    this.type,
    this.posterUrl,
    this.posterUrlPreview,
    this.userComment,
    this.userRating
  });

  factory FilmBaseModel.fromFilmCollectionResponseItems(FilmCollectionResponseItems film){
    return FilmBaseModel(
      kinopoiskId: film.kinopoiskId,
      nameRu: film.nameRu,
      nameEn: film.nameEn,
      nameOriginal: film.nameOriginal,
      countries: film.countries?.map((country) => country.country).toList(),
      genres: film.genres?.map((genre) => genre.genre).toList(),
      ratingKinopoisk: film.ratingKinopoisk,
      ratingImbd: film.ratingImbd,
      year: film.year,
      type: film.type?.name,
      posterUrl: film.posterUrl,
      posterUrlPreview: film.posterUrlPreview,
    );
  }

  factory FilmBaseModel.fromFilmSearchByFiltersResponseItems(FilmSearchByFiltersResponseItems film){
    return FilmBaseModel(
      kinopoiskId: film.kinopoiskId,
      nameRu: film.nameRu,
      nameEn: film.nameEn,
      nameOriginal: film.nameOriginal,
      countries: film.countries?.map((country) => country.country).toList(),
      genres: film.genres?.map((genre) => genre.genre).toList(),
      ratingKinopoisk: film.ratingKinopoisk,
      ratingImbd: film.ratingImdb,
      year: film.year?.toInt(),
      type: film.type?.name,
      posterUrl: film.posterUrl,
      posterUrlPreview: film.posterUrlPreview
    );
  }
}