import 'package:generated/generated.dart';

class FilmInformationModel {
  int? kinopoiskId;
  String? kinopoiskHDId;
  String? imdbId;
  String? nameRu;
  String? nameEn;
  String? nameOriginal;
  String? posterUrl;
  String? posterUrlPreview;
  String? coverUrl;
  String? logoUrl;
  int? reviewsCount;
  num? ratingGoodReview;
  int? ratingGoodReviewVoteCount;
  num? ratingKinopoisk;
  int? ratingKinopoiskVoteCount;
  num? ratingImdb;
  int? ratingImdbVoteCount;
  num? ratingFilmCritics;
  int? ratingFilmCriticsVoteCount;
  num? ratingAwait;
  int? ratingAwaitCount;
  num? ratingRfCritics;
  int? ratingRfCriticsVoteCount;
  String? webUrl;
  int? year;
  int? filmLength;
  String? slogan;
  String? description;
  String? shortDescription;
  String? editorAnnotation;
  bool? isTicketsAvailable;
  String? productionStatus;
  String? type;
  String? ratingMpaa;
  String? ratingAgeLimits;
  bool? hasImax;
  bool? has3D;
  String? lastSync;
  List<String>? countries;
  List<String>? genres;
  int? startYear;
  int? endYear;
  bool? serial;
  bool? shortFilm;
  bool? completed;

  FilmInformationModel({
    this.kinopoiskId,
    this.kinopoiskHDId,
    this.imdbId,
    this.nameRu,
    this.nameEn,
    this.nameOriginal,
    this.posterUrl,
    this.posterUrlPreview,
    this.coverUrl,
    this.logoUrl,
    this.reviewsCount,
    this.ratingGoodReview,
    this.ratingGoodReviewVoteCount,
    this.ratingKinopoisk,
    this.ratingKinopoiskVoteCount,
    this.ratingImdb,
    this.ratingImdbVoteCount,
    this.ratingFilmCritics,
    this.ratingFilmCriticsVoteCount,
    this.ratingAwait,
    this.ratingAwaitCount,
    this.ratingRfCritics,
    this.ratingRfCriticsVoteCount,
    this.webUrl,
    this.year,
    this.filmLength,
    this.slogan,
    this.description,
    this.shortDescription,
    this.editorAnnotation,
    this.isTicketsAvailable,
    this.productionStatus,
    this.type,
    this.ratingMpaa,
    this.ratingAgeLimits,
    this.hasImax,
    this.has3D,
    this.lastSync,
    this.countries,
    this.genres,
    this.startYear,
    this.endYear,
    this.serial,
    this.shortFilm,
    this.completed,
  });

  factory FilmInformationModel.fromFilm(Film film){
    return FilmInformationModel(
      kinopoiskId: film.kinopoiskId,
      kinopoiskHDId: film.kinopoiskHDId,
      imdbId: film.imdbId,
      nameRu: film.nameRu,
      nameEn: film.nameEn,
      nameOriginal: film.nameOriginal,
      posterUrl: film.posterUrl,
      posterUrlPreview: film.posterUrlPreview,
      coverUrl: film.coverUrl,
      logoUrl: film.logoUrl,
      reviewsCount: film.reviewsCount,
      ratingGoodReview: film.ratingGoodReview,
      ratingGoodReviewVoteCount: film.ratingGoodReviewVoteCount,
      ratingKinopoisk: film.ratingKinopoisk,
      ratingKinopoiskVoteCount: film.ratingKinopoiskVoteCount,
      ratingImdb: film.ratingImdb,
      ratingImdbVoteCount: film.ratingImdbVoteCount,
      ratingFilmCritics: film.ratingFilmCritics,
      ratingFilmCriticsVoteCount: film.ratingFilmCriticsVoteCount,
      ratingAwait: film.ratingAwait,
      ratingAwaitCount: film.ratingAwaitCount,
      ratingRfCritics: film.ratingRfCritics,
      ratingRfCriticsVoteCount: film.ratingRfCriticsVoteCount,
      webUrl: film.webUrl,
      year: film.year,
      filmLength: film.filmLength,
      slogan: film.slogan,
      description: film.description,
      shortDescription: film.shortDescription,
      editorAnnotation: film.editorAnnotation,
      isTicketsAvailable: film.isTicketsAvailable,
      productionStatus: film.productionStatus?.name,
      type: film.type.name,
      ratingMpaa: film.ratingMpaa,
      ratingAgeLimits: film.ratingAgeLimits,
      hasImax: film.hasImax,
      has3D: film.has3D,
      lastSync: film.lastSync,
      countries: film.countries.map((country) => country.country).toList(),
      genres: film.genres.map((genre) => genre.genre).toList(),
      startYear: film.startYear,
      endYear: film.endYear,
      serial: film.serial,
      shortFilm: film.shortFilm,
      completed: film.completed,
    );
  }
}