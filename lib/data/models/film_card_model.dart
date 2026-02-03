import 'package:generated/generated.dart';

class FilmCardModel {
  int? kinopoiskId;
  String? nameRu;
  String? nameEn;
  String? nameOriginal;
  List<String>? countries;
  List<String>? genres;
  num? ratingKinopoisk;
  num? ratingImbd;
  int? year;
  String? type;
  String? posterUrl;
  String? posterUrlPreview;

  FilmCardModel({
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
    this.posterUrlPreview
  });

  factory FilmCardModel.fromFilmCollectionResponseItems(FilmCollectionResponseItems film){
    return FilmCardModel(
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
      posterUrlPreview: film.posterUrlPreview
    );
  }

  factory FilmCardModel.fromFilmSearchByFiltersResponseItems(FilmSearchByFiltersResponseItems film){
    return FilmCardModel(
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