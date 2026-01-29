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

  factory FilmCardModel.fromObject(FilmCollectionResponseItems object){
    return FilmCardModel(
      kinopoiskId: object.kinopoiskId,
      nameRu: object.nameRu,
      nameEn: object.nameEn,
      nameOriginal: object.nameOriginal,
      countries: object.countries?.map((country) => country.country).toList(),
      genres: object.genres?.map((genre) => genre.genre).toList(),
      ratingKinopoisk: object.ratingKinopoisk,
      ratingImbd: object.ratingImbd,
      year: object.year,
      type: object.type?.name,
      posterUrl: object.posterUrl,
      posterUrlPreview: object.posterUrlPreview
    );
  }
}