
import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/data/models/film_card_model.dart';

class FilmCardEntity extends Equatable {
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

  FilmCardEntity({
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