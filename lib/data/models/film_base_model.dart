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
  @HiveField(14) String? localPosterImagePath;
  @HiveField(15) List<String>? localScreenshotPaths;

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
    this.userRating,
    this.localPosterImagePath,
    this.localScreenshotPaths
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

  Map<String, dynamic> toJson() => {
    "kinopoiskId": kinopoiskId,
    "nameRu": nameRu,
    "nameEn": nameEn,
    "nameOriginal": nameOriginal,
    "countries": countries,
    "genres": genres,
    "ratingKinopoisk": ratingKinopoisk,
    "ratingImbd": ratingImbd,
    "year": year,
    "type": type,
    "posterUrl": posterUrl,
    "posterUrlPreview": posterUrlPreview,
    "userComment": userComment,
    "userRating": userRating,
    "localPosterImagePath": localPosterImagePath,
    "localScreenshotPaths": localScreenshotPaths,
  };

  factory FilmBaseModel.fromJson(Map<String, dynamic> json) {
    return FilmBaseModel(
      kinopoiskId: json["kinopoiskId"],
      nameRu: json["nameRu"],
      nameEn: json["nameEn"],
      nameOriginal: json["nameOriginal"],
      countries: json["countries"] != null ? List<String>.from(json["countries"]) : null,
      genres: json["genres"] != null ? List<String>.from(json["genres"]) : null,
      ratingKinopoisk: json["ratingKinopoisk"],
      ratingImbd: json["ratingImbd"],
      year: json["year"],
      type: json["type"],
      posterUrl: json["posterUrl"],
      posterUrlPreview: json["posterUrlPreview"],
      userComment: json["userComment"],
      userRating: json["userRating"],
      localPosterImagePath: json["localPosterImagePath"],
      localScreenshotPaths: json["localScreenshotPaths"] != null 
          ? List<String>.from(json["localScreenshotPaths"]) 
          : null,
    );
  }

  FilmBaseModel copyWith({
    int? kinopoiskId,
    String? nameRu,
    String? nameEn,
    String? nameOriginal,
    List<String>? countries,
    List<String>? genres,
    num? ratingKinopoisk,
    num? ratingImbd,
    int? year,
    String? type,
    String? posterUrl,
    String? posterUrlPreview,
    String? userComment,
    int? userRating,
    String? localPosterImagePath,
    List<String>? localScreenshotPaths,
  }) {
    return FilmBaseModel(
      kinopoiskId: kinopoiskId ?? this.kinopoiskId,
      nameRu: nameRu ?? this.nameRu,
      nameEn: nameEn ?? this.nameEn,
      nameOriginal: nameOriginal ?? this.nameOriginal,
      countries: countries ?? this.countries,
      genres: genres ?? this.genres,
      ratingKinopoisk: ratingKinopoisk ?? this.ratingKinopoisk,
      ratingImbd: ratingImbd ?? this.ratingImbd,
      year: year ?? this.year,
      type: type ?? this.type,
      posterUrl: posterUrl ?? this.posterUrl,
      posterUrlPreview: posterUrlPreview ?? this.posterUrlPreview,
      userComment: userComment ?? this.userComment,
      userRating: userRating ?? this.userRating,
      localPosterImagePath: localPosterImagePath ?? this.localPosterImagePath,
      localScreenshotPaths: localScreenshotPaths ?? this.localScreenshotPaths,
    );
  }
}