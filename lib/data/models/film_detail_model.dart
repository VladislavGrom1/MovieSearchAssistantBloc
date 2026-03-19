import 'package:generated/generated.dart';
import 'package:hive/hive.dart';
import 'package:movie_search_assistant_bloc/data/models/film_base_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';

part 'film_detail_model.g.dart';

@HiveType(typeId: 2)
class FilmDetailModel {
  @HiveField(0) FilmBaseModel filmBaseModel;
  @HiveField(1) String? kinopoiskHDId;
  @HiveField(2) String? imdbId;
  @HiveField(3) String? coverUrl;
  @HiveField(4) String? logoUrl;
  @HiveField(5) int? reviewsCount;
  @HiveField(6) num? ratingGoodReview;
  @HiveField(7) int? ratingGoodReviewVoteCount;
  @HiveField(8) int? ratingKinopoiskVoteCount;
  @HiveField(9) int? ratingImdbVoteCount;
  @HiveField(10) num? ratingFilmCritics;
  @HiveField(11) int? ratingFilmCriticsVoteCount;
  @HiveField(12) num? ratingAwait;
  @HiveField(13) int? ratingAwaitCount;
  @HiveField(14) num? ratingRfCritics;
  @HiveField(15) int? ratingRfCriticsVoteCount;
  @HiveField(16) String? webUrl;
  @HiveField(17) int? filmLength;
  @HiveField(18) String? slogan;
  @HiveField(19) String? description;
  @HiveField(20) String? shortDescription;
  @HiveField(21) String? editorAnnotation;
  @HiveField(22) bool? isTicketsAvailable;
  @HiveField(23) String? productionStatus;
  @HiveField(24) String? ratingMpaa;
  @HiveField(25) String? ratingAgeLimits;
  @HiveField(26) bool? hasImax;
  @HiveField(27) bool? has3D;
  @HiveField(28) String? lastSync;
  @HiveField(29) int? startYear;
  @HiveField(30) int? endYear;
  @HiveField(31) bool? serial;
  @HiveField(32) bool? shortFilm;
  @HiveField(33) bool? completed;

  FilmDetailModel({
    required this.filmBaseModel,
    this.kinopoiskHDId,
    this.imdbId,
    this.coverUrl,
    this.logoUrl,
    this.reviewsCount,
    this.ratingGoodReview,
    this.ratingGoodReviewVoteCount,
    this.ratingKinopoiskVoteCount,
    this.ratingImdbVoteCount,
    this.ratingFilmCritics,
    this.ratingFilmCriticsVoteCount,
    this.ratingAwait,
    this.ratingAwaitCount,
    this.ratingRfCritics,
    this.ratingRfCriticsVoteCount,
    this.webUrl,
    this.filmLength,
    this.slogan,
    this.description,
    this.shortDescription,
    this.editorAnnotation,
    this.isTicketsAvailable,
    this.productionStatus,
    this.ratingMpaa,
    this.ratingAgeLimits,
    this.hasImax,
    this.has3D,
    this.lastSync,
    this.startYear,
    this.endYear,
    this.serial,
    this.shortFilm,
    this.completed,
  });

  factory FilmDetailModel.fromFilm(Film film){
    return FilmDetailModel(
      filmBaseModel: FilmBaseModel(
        kinopoiskId: film.kinopoiskId,
        nameRu: film.nameRu,
        nameEn: film.nameEn,
        nameOriginal: film.nameOriginal,
        countries: film.countries.map((country) => country.country).toList(),
        genres: film.genres.map((genre) => genre.genre).toList(),
        ratingKinopoisk: film.ratingKinopoisk,
        ratingImbd: film.ratingImdb,
        year: film.year,
        type: film.type.name,
        posterUrl: film.posterUrl,
        posterUrlPreview: film.posterUrlPreview,
      ),
      kinopoiskHDId: film.kinopoiskHDId,
      imdbId: film.imdbId,
      coverUrl: film.coverUrl,
      logoUrl: film.logoUrl,
      reviewsCount: film.reviewsCount,
      ratingGoodReview: film.ratingGoodReview,
      ratingGoodReviewVoteCount: film.ratingGoodReviewVoteCount,
      ratingKinopoiskVoteCount: film.ratingKinopoiskVoteCount,
      ratingImdbVoteCount: film.ratingImdbVoteCount,
      ratingFilmCritics: film.ratingFilmCritics,
      ratingFilmCriticsVoteCount: film.ratingFilmCriticsVoteCount,
      ratingAwait: film.ratingAwait,
      ratingAwaitCount: film.ratingAwaitCount,
      ratingRfCritics: film.ratingRfCritics,
      ratingRfCriticsVoteCount: film.ratingRfCriticsVoteCount,
      webUrl: film.webUrl,
      filmLength: film.filmLength,
      slogan: film.slogan,
      description: film.description,
      shortDescription: film.shortDescription,
      editorAnnotation: film.editorAnnotation,
      isTicketsAvailable: film.isTicketsAvailable,
      productionStatus: film.productionStatus?.name,
      ratingMpaa: film.ratingMpaa,
      ratingAgeLimits: film.ratingAgeLimits,
      hasImax: film.hasImax,
      has3D: film.has3D,
      lastSync: film.lastSync,
      startYear: film.startYear,
      endYear: film.endYear,
      serial: film.serial,
      shortFilm: film.shortFilm,
      completed: film.completed,
    );
  }

  factory FilmDetailModel.fromFilmEntity(FilmEntity filmEntity){
    return FilmDetailModel(
      filmBaseModel: FilmBaseModel(
        kinopoiskId: filmEntity.kinopoiskId,
        nameRu: filmEntity.nameRu,
        nameEn: filmEntity.nameEn,
        nameOriginal: filmEntity.nameOriginal,
        countries: filmEntity.countries,
        genres: filmEntity.genres,
        ratingKinopoisk: filmEntity.ratingKinopoisk,
        ratingImbd: filmEntity.ratingImbd,
        year: filmEntity.year,
        type: filmEntity.type,
        posterUrl: filmEntity.posterUrl,
        posterUrlPreview: filmEntity.posterUrlPreview,
        userComment: filmEntity.userComment,
        userRating: filmEntity.userRating
      ),
      kinopoiskHDId: filmEntity.kinopoiskHDId,
      imdbId: filmEntity.imdbId,
      coverUrl: filmEntity.coverUrl,
      logoUrl: filmEntity.logoUrl,
      reviewsCount: filmEntity.reviewsCount,
      ratingGoodReview: filmEntity.ratingGoodReview,
      ratingGoodReviewVoteCount: filmEntity.ratingGoodReviewVoteCount,
      ratingKinopoiskVoteCount: filmEntity.ratingKinopoiskVoteCount,
      ratingImdbVoteCount: filmEntity.ratingImdbVoteCount,
      ratingFilmCritics: filmEntity.ratingFilmCritics,
      ratingFilmCriticsVoteCount: filmEntity.ratingFilmCriticsVoteCount,
      ratingAwait: filmEntity.ratingAwait,
      ratingAwaitCount: filmEntity.ratingAwaitCount,
      ratingRfCritics: filmEntity.ratingRfCritics,
      ratingRfCriticsVoteCount: filmEntity.ratingRfCriticsVoteCount,
      webUrl: filmEntity.webUrl,
      filmLength: filmEntity.filmLength,
      slogan: filmEntity.slogan,
      description: filmEntity.description,
      shortDescription: filmEntity.shortDescription,
      editorAnnotation: filmEntity.editorAnnotation,
      isTicketsAvailable: filmEntity.isTicketsAvailable,
      productionStatus: filmEntity.productionStatus,
      ratingMpaa: filmEntity.ratingMpaa,
      ratingAgeLimits: filmEntity.ratingAgeLimits,
      hasImax: filmEntity.hasImax,
      has3D: filmEntity.has3D,
      lastSync: filmEntity.lastSync,
      startYear: filmEntity.startYear,
      endYear: filmEntity.endYear,
      serial: filmEntity.serial,
      shortFilm: filmEntity.shortFilm,
      completed: filmEntity.completed,
    );
  }
}