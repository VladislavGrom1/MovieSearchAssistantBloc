
import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/data/models/film_base_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';

class FilmEntity extends Equatable {
  // FilmBaseInformation
  final int? kinopoiskId;
  final String? nameRu;
  final String? nameEn;
  final String? nameOriginal;
  final List<String>? countries;
  final List<String>? genres;
  final num? ratingKinopoisk;
  final num? ratingImbd;
  final int? year;
  final String? type;
  final String? posterUrl;
  final String? posterUrlPreview;
  final String? userComment;
  final int? userRating;
  final String? localPosterImagePath;
  final List<String>? localScreenshotPaths;
  // FilmDetailInformation
  final String? kinopoiskHDId;
  final String? imdbId;
  final String? coverUrl;
  final String? logoUrl;
  final int? reviewsCount;
  final num? ratingGoodReview;
  final int? ratingGoodReviewVoteCount;
  final int? ratingKinopoiskVoteCount;
  final int? ratingImdbVoteCount;
  final num? ratingFilmCritics;
  final int? ratingFilmCriticsVoteCount;
  final num? ratingAwait;
  final int? ratingAwaitCount;
  final num? ratingRfCritics;
  final int? ratingRfCriticsVoteCount;
  final String? webUrl;
  final int? filmLength;
  final String? slogan;
  final String? description;
  final String? shortDescription;
  final String? editorAnnotation;
  final bool? isTicketsAvailable;
  final String? productionStatus;
  final String? ratingMpaa;
  final String? ratingAgeLimits;
  final bool? hasImax;
  final bool? has3D;
  final String? lastSync;
  final int? startYear;
  final int? endYear;
  final bool? serial;
  final bool? shortFilm;
  final bool? completed;

  const FilmEntity({
    // FilmBaseInformation
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
    this.localScreenshotPaths,
    // FilmDetailInformation
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

  FilmEntity copyWith({
    // FilmBaseInformation
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
    // FilmDetailInformation
    String? kinopoiskHDId,
    String? imdbId,
    String? coverUrl,
    String? logoUrl,
    int? reviewsCount,
    num? ratingGoodReview,
    int? ratingGoodReviewVoteCount,
    int? ratingKinopoiskVoteCount,
    int? ratingImdbVoteCount,
    num? ratingFilmCritics,
    int? ratingFilmCriticsVoteCount,
    num? ratingAwait,
    int? ratingAwaitCount,
    num? ratingRfCritics,
    int? ratingRfCriticsVoteCount,
    String? webUrl,
    int? filmLength,
    String? slogan,
    String? description,
    String? shortDescription,
    String? editorAnnotation,
    bool? isTicketsAvailable,
    String? productionStatus,
    String? ratingMpaa,
    String? ratingAgeLimits,
    bool? hasImax,
    bool? has3D,
    String? lastSync,
    int? startYear,
    int? endYear,
    bool? serial,
    bool? shortFilm,
    bool? completed,
  }) {
    return FilmEntity(
      // FilmBaseInformation
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
      // FilmDetailInformation
      kinopoiskHDId: kinopoiskHDId ?? this.kinopoiskHDId,
      imdbId: imdbId ?? this.imdbId,
      coverUrl: coverUrl ?? this.coverUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      ratingGoodReview: ratingGoodReview ?? this.ratingGoodReview,
      ratingGoodReviewVoteCount: ratingGoodReviewVoteCount ?? this.ratingGoodReviewVoteCount,
      ratingKinopoiskVoteCount: ratingKinopoiskVoteCount ?? this.ratingKinopoiskVoteCount,
      ratingImdbVoteCount: ratingImdbVoteCount ?? this.ratingImdbVoteCount,
      ratingFilmCritics: ratingFilmCritics ?? this.ratingFilmCritics,
      ratingFilmCriticsVoteCount: ratingFilmCriticsVoteCount ?? this.ratingFilmCriticsVoteCount,
      ratingAwait: ratingAwait ?? this.ratingAwait,
      ratingAwaitCount: ratingAwaitCount ?? this.ratingAwaitCount,
      ratingRfCritics: ratingRfCritics ?? this.ratingRfCritics,
      ratingRfCriticsVoteCount: ratingRfCriticsVoteCount ?? this.ratingRfCriticsVoteCount,
      webUrl: webUrl ?? this.webUrl,
      filmLength: filmLength ?? this.filmLength,
      slogan: slogan ?? this.slogan,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      editorAnnotation: editorAnnotation ?? this.editorAnnotation,
      isTicketsAvailable: isTicketsAvailable ?? this.isTicketsAvailable,
      productionStatus: productionStatus ?? this.productionStatus,
      ratingMpaa: ratingMpaa ?? this.ratingMpaa,
      ratingAgeLimits: ratingAgeLimits ?? this.ratingAgeLimits,
      hasImax: hasImax ?? this.hasImax,
      has3D: has3D ?? this.has3D,
      lastSync: lastSync ?? this.lastSync,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      serial: serial ?? this.serial,
      shortFilm: shortFilm ?? this.shortFilm,
      completed: completed ?? this.completed,
    );
  }

  factory FilmEntity.fromFilmBaseModel(FilmBaseModel filmBaseModel){
    return FilmEntity(
      // FilmBaseInformation
      kinopoiskId: filmBaseModel.kinopoiskId,
      nameRu: filmBaseModel.nameRu,
      nameEn: filmBaseModel.nameEn,
      nameOriginal: filmBaseModel.nameOriginal,
      countries: filmBaseModel.countries,
      genres: filmBaseModel.genres,
      ratingKinopoisk: filmBaseModel.ratingKinopoisk,
      ratingImbd: filmBaseModel.ratingImbd,
      year: filmBaseModel.year,
      type: filmBaseModel.type,
      posterUrl: filmBaseModel.posterUrl,
      posterUrlPreview: filmBaseModel.posterUrlPreview,
      userComment: filmBaseModel.userComment,
      userRating: filmBaseModel.userRating
    );
  }

  factory FilmEntity.fromFilmDetailModel(FilmDetailModel filmDetailModel){
    return FilmEntity(
      // FilmBaseInformation
      kinopoiskId: filmDetailModel.filmBaseModel.kinopoiskId,
      nameRu: filmDetailModel.filmBaseModel.nameRu,
      nameEn: filmDetailModel.filmBaseModel.nameEn,
      nameOriginal: filmDetailModel.filmBaseModel.nameOriginal,
      countries: filmDetailModel.filmBaseModel.countries,
      genres: filmDetailModel.filmBaseModel.genres,
      ratingKinopoisk: filmDetailModel.filmBaseModel.ratingKinopoisk,
      ratingImbd: filmDetailModel.filmBaseModel.ratingImbd,
      year: filmDetailModel.filmBaseModel.year,
      type: filmDetailModel.filmBaseModel.type,
      posterUrl: filmDetailModel.filmBaseModel.posterUrl,
      posterUrlPreview: filmDetailModel.filmBaseModel.posterUrlPreview,
      userComment: filmDetailModel.filmBaseModel.userComment,
      userRating: filmDetailModel.filmBaseModel.userRating,
      localPosterImagePath: filmDetailModel.filmBaseModel.localPosterImagePath,
      localScreenshotPaths: filmDetailModel.filmBaseModel.localScreenshotPaths,
      // FilmDetailInformation
      kinopoiskHDId: filmDetailModel.kinopoiskHDId,
      imdbId: filmDetailModel.imdbId,
      coverUrl: filmDetailModel.coverUrl,
      logoUrl: filmDetailModel.logoUrl,
      reviewsCount: filmDetailModel.reviewsCount,
      ratingGoodReview: filmDetailModel.ratingGoodReview,
      ratingGoodReviewVoteCount: filmDetailModel.ratingGoodReviewVoteCount,
      ratingKinopoiskVoteCount: filmDetailModel.ratingKinopoiskVoteCount,
      ratingImdbVoteCount: filmDetailModel.ratingImdbVoteCount,
      ratingFilmCritics: filmDetailModel.ratingFilmCritics,
      ratingFilmCriticsVoteCount: filmDetailModel.ratingFilmCriticsVoteCount,
      ratingAwait: filmDetailModel.ratingAwait,
      ratingAwaitCount: filmDetailModel.ratingAwaitCount,
      ratingRfCritics: filmDetailModel.ratingRfCritics,
      ratingRfCriticsVoteCount: filmDetailModel.ratingRfCriticsVoteCount,
      webUrl: filmDetailModel.webUrl,
      filmLength: filmDetailModel.filmLength,
      slogan: filmDetailModel.slogan,
      description: filmDetailModel.description,
      shortDescription: filmDetailModel.shortDescription,
      editorAnnotation: filmDetailModel.editorAnnotation,
      isTicketsAvailable: filmDetailModel.isTicketsAvailable,
      productionStatus: filmDetailModel.productionStatus,
      ratingMpaa: filmDetailModel.ratingMpaa,
      ratingAgeLimits: filmDetailModel.ratingAgeLimits,
      hasImax: filmDetailModel.hasImax,
      has3D: filmDetailModel.has3D,
      lastSync: filmDetailModel.lastSync,
      startYear: filmDetailModel.startYear,
      endYear: filmDetailModel.endYear,
      serial: filmDetailModel.serial,
      shortFilm: filmDetailModel.shortFilm,
      completed: filmDetailModel.completed,
    );
  }

  bool equalsWithoutUserData(FilmEntity other) {    
    return kinopoiskId == other.kinopoiskId &&
        nameRu == other.nameRu &&
        nameEn == other.nameEn &&
        nameOriginal == other.nameOriginal &&
        _listEquals(countries, other.countries) &&
        _listEquals(genres, other.genres) &&
        ratingKinopoisk == other.ratingKinopoisk &&
        ratingImbd == other.ratingImbd &&
        year == other.year &&
        type == other.type &&
        posterUrl == other.posterUrl &&
        posterUrlPreview == other.posterUrlPreview &&
        kinopoiskHDId == other.kinopoiskHDId &&
        imdbId == other.imdbId &&
        coverUrl == other.coverUrl &&
        logoUrl == other.logoUrl &&
        reviewsCount == other.reviewsCount &&
        ratingGoodReview == other.ratingGoodReview &&
        ratingGoodReviewVoteCount == other.ratingGoodReviewVoteCount &&
        ratingKinopoiskVoteCount == other.ratingKinopoiskVoteCount &&
        ratingImdbVoteCount == other.ratingImdbVoteCount &&
        ratingFilmCritics == other.ratingFilmCritics &&
        ratingFilmCriticsVoteCount == other.ratingFilmCriticsVoteCount &&
        ratingAwait == other.ratingAwait &&
        ratingAwaitCount == other.ratingAwaitCount &&
        ratingRfCritics == other.ratingRfCritics &&
        ratingRfCriticsVoteCount == other.ratingRfCriticsVoteCount &&
        webUrl == other.webUrl &&
        filmLength == other.filmLength &&
        slogan == other.slogan &&
        description == other.description &&
        shortDescription == other.shortDescription &&
        editorAnnotation == other.editorAnnotation &&
        isTicketsAvailable == other.isTicketsAvailable &&
        productionStatus == other.productionStatus &&
        ratingMpaa == other.ratingMpaa &&
        ratingAgeLimits == other.ratingAgeLimits &&
        hasImax == other.hasImax &&
        has3D == other.has3D &&
        lastSync == other.lastSync &&
        startYear == other.startYear &&
        endYear == other.endYear &&
        serial == other.serial &&
        shortFilm == other.shortFilm &&
        completed == other.completed;
  }

  bool _listEquals(List? a, List? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  List<Object?> get props => [
    // FilmBaseInformation
    kinopoiskId, 
    nameRu, 
    nameEn, 
    nameOriginal,
    countries,
    genres,
    ratingKinopoisk,
    ratingImbd,
    year,
    type,
    posterUrl,
    posterUrlPreview,
    userComment,
    userRating,
    // FilmDetailInformation
    kinopoiskHDId,
    imdbId,
    coverUrl,
    logoUrl,
    reviewsCount,
    ratingGoodReview,
    ratingGoodReviewVoteCount,
    ratingKinopoiskVoteCount,
    ratingImdbVoteCount,
    ratingFilmCritics,
    ratingFilmCriticsVoteCount,
    ratingAwait,
    ratingAwaitCount,
    ratingRfCritics,
    ratingRfCriticsVoteCount,
    webUrl,
    filmLength,
    slogan,
    description,
    shortDescription,
    editorAnnotation,
    isTicketsAvailable,
    productionStatus,
    ratingMpaa,
    ratingAgeLimits,
    hasImax,
    has3D,
    lastSync,
    startYear,
    endYear,
    serial,
    shortFilm,
    completed
  ];
}