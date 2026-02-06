
import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/data/models/film_card_model.dart';

class FilmCardEntity extends Equatable {
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

  const FilmCardEntity({
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

  factory FilmCardEntity.fromModel(FilmCardModel filmCardModel){
    return FilmCardEntity(
      kinopoiskId: filmCardModel.kinopoiskId,
      nameRu: filmCardModel.nameRu,
      nameEn: filmCardModel.nameEn,
      nameOriginal: filmCardModel.nameOriginal,
      countries: filmCardModel.countries,
      genres: filmCardModel.genres,
      ratingKinopoisk: filmCardModel.ratingKinopoisk,
      ratingImbd: filmCardModel.ratingImbd,
      year: filmCardModel.year,
      type: filmCardModel.type,
      posterUrl: filmCardModel.posterUrl,
      posterUrlPreview: filmCardModel.posterUrlPreview
    );
  }

  @override
  List<Object?> get props => [
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
    posterUrlPreview
  ];
}