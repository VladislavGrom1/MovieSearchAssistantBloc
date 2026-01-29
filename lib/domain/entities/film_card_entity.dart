
import 'package:equatable/equatable.dart';

class FilmCardEntity extends Equatable {
  int? kinopoiskId;
  String? nameRu;
  String? nameEn;
  String? nameOriginal;
  num? ratingKinopoisk;

  FilmCardEntity({
    this.kinopoiskId,
    this.nameRu,
    this.nameEn,
    this.nameOriginal,
    this.ratingKinopoisk
  });

  @override
  List<Object?> get props => [
    kinopoiskId, 
    nameRu, 
    nameEn, 
    nameOriginal,
    ratingKinopoisk
  ];
}