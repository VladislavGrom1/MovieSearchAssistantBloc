import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/data/models/film_information_model.dart';

class FilmInformationEntity extends Equatable {
  final int? kinopoiskId;
  //String? kinopoiskHDId;
  //String? imdbId;
  final String? nameRu;
  //String? nameEn;
  final String? nameOriginal;
  final String? posterUrl;
  //String? posterUrlPreview;
  //String? coverUrl;
  //String? logoUrl;
  //int? reviewsCount;
  //num? ratingGoodReview;
  //int? ratingGoodReviewVoteCount;
  final num? ratingKinopoisk;
  final int? ratingKinopoiskVoteCount;
  final num? ratingImdb;
  final int? ratingImdbVoteCount;
  //num? ratingFilmCritics;
  //int? ratingFilmCriticsVoteCount;
  //num? ratingAwait;
  //int? ratingAwaitCount;
  //num? ratingRfCritics;
  //int? ratingRfCriticsVoteCount;
  final String? webUrl;
  final int? year;
  //int? filmLength;
  final String? slogan;
  final String? description;
  //String? shortDescription;
  //String? editorAnnotation;
  //bool? isTicketsAvailable;
  //String? productionStatus;
  //String? type;
  //String? ratingMpaa;
  //String? ratingAgeLimits;
  //bool? hasImax;
  //bool? has3D;
  //String? lastSync;
  final List<String>? countries;
  final List<String>? genres;
  final int? startYear;
  final int? endYear;
  final bool? serial;
  //bool? shortFilm;
  //bool? completed;

  const FilmInformationEntity({
    this.kinopoiskId,
    //this.kinopoiskHDId,
    //this.imdbId,
    this.nameRu,
    //this.nameEn,
    this.nameOriginal,
    this.posterUrl,
    //this.posterUrlPreview,
    //this.coverUrl,
    //this.logoUrl,
    //this.reviewsCount,
    //this.ratingGoodReview,
    //this.ratingGoodReviewVoteCount,
    this.ratingKinopoisk,
    this.ratingKinopoiskVoteCount,
    this.ratingImdb,
    this.ratingImdbVoteCount,
    //this.ratingFilmCritics,
    //this.ratingFilmCriticsVoteCount,
    //this.ratingAwait,
    //this.ratingAwaitCount,
    //this.ratingRfCritics,
    //this.ratingRfCriticsVoteCount,
    this.webUrl,
    this.year,
    //this.filmLength,
    this.slogan,
    this.description,
    //this.shortDescription,
    //this.editorAnnotation,
    //this.isTicketsAvailable,
    //this.productionStatus,
    //this.type,
    //this.ratingMpaa,
    //this.ratingAgeLimits,
    //this.hasImax,
    //this.has3D,
    //this.lastSync,
    this.countries,
    this.genres,
    this.startYear,
    this.endYear,
    this.serial,
    //this.shortFilm,
    //this.completed,
  });

  factory FilmInformationEntity.fromModel(FilmInformationModel filmInformationModel){
    return FilmInformationEntity(
      kinopoiskId: filmInformationModel.kinopoiskId,
      //kinopoiskHDId: film.kinopoiskHDId,
      //imdbId: film.imdbId,
      nameRu: filmInformationModel.nameRu,
      //nameEn: film.nameEn,
      nameOriginal: filmInformationModel.nameOriginal,
      posterUrl: filmInformationModel.posterUrl,
      //posterUrlPreview: film.posterUrlPreview,
      //coverUrl: film.coverUrl,
      //logoUrl: film.logoUrl,
      //reviewsCount: film.reviewsCount,
      //ratingGoodReview: film.ratingGoodReview,
      //ratingGoodReviewVoteCount: film.ratingGoodReviewVoteCount,
      ratingKinopoisk: filmInformationModel.ratingKinopoisk,
      ratingKinopoiskVoteCount: filmInformationModel.ratingKinopoiskVoteCount,
      ratingImdb: filmInformationModel.ratingImdb,
      ratingImdbVoteCount: filmInformationModel.ratingImdbVoteCount,
      //ratingFilmCritics: film.ratingFilmCritics,
      //ratingFilmCriticsVoteCount: film.ratingFilmCriticsVoteCount,
      //ratingAwait: film.ratingAwait,
      //ratingAwaitCount: film.ratingAwaitCount,
      //ratingRfCritics: film.ratingRfCritics,
      //ratingRfCriticsVoteCount: film.ratingRfCriticsVoteCount,
      webUrl: filmInformationModel.webUrl,
      year: filmInformationModel.year,
      //filmLength: film.filmLength,
      slogan: filmInformationModel.slogan,
      description: filmInformationModel.description,
      //shortDescription: film.shortDescription,
      //editorAnnotation: film.editorAnnotation,
      //isTicketsAvailable: film.isTicketsAvailable,
      //productionStatus: film.productionStatus?.name,
      //type: film.type.name,
      //ratingMpaa: film.ratingMpaa,
      //ratingAgeLimits: film.ratingAgeLimits,
      //hasImax: film.hasImax,
      //has3D: film.has3D,
      //lastSync: film.lastSync,
      countries: filmInformationModel.countries,
      genres: filmInformationModel.genres,
      startYear: filmInformationModel.startYear,
      endYear: filmInformationModel.endYear,
      serial: filmInformationModel.serial,
      //shortFilm: film.shortFilm,
      //completed: film.completed,
    );
  }
  
  @override
  List<Object?> get props => [
    kinopoiskId,
    //kinopoiskHDId,
    //imdbId,
    nameRu,
    //nameEn,
    nameOriginal,
    posterUrl,
    //posterUrlPreview,
    //coverUrl,
    //logoUrl,
    //reviewsCount,
    //ratingGoodReview,
    //ratingGoodReviewVoteCount,
    ratingKinopoisk,
    ratingKinopoiskVoteCount,
    ratingImdb,
    ratingImdbVoteCount,
    //ratingFilmCritics,
    //ratingFilmCriticsVoteCount,
    //ratingAwait,
    //ratingAwaitCount,
    //ratingRfCritics,
    //ratingRfCriticsVoteCount,
    webUrl,
    year,
    //filmLength,
    slogan,
    description,
    //shortDescription,
    //editorAnnotation,
    //isTicketsAvailable,
    //productionStatus,
    //type,
    //ratingMpaa,
    //ratingAgeLimits,
    //hasImax,
    //has3D,
    //lastSync,
    countries,
    genres,
    startYear,
    endYear,
    serial,
    //shortFilm,
    //completed,
  ];
}