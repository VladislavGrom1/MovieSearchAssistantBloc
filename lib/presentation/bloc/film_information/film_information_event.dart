part of 'film_information_bloc.dart';

sealed class FilmInformationEvent extends Equatable {
  const FilmInformationEvent();

  @override
  List<Object?> get props => [];
}

class GetFilmInformation extends FilmInformationEvent{
  final int idFilm;

  const GetFilmInformation({required this.idFilm});

  @override
  List<Object?> get props => [idFilm];
}

class AddFilmToCollection extends FilmInformationEvent {
  final String collectionId;
  
  const AddFilmToCollection({required this.collectionId});

  @override
  List<Object?> get props => [collectionId];
}

class RemoveFilmFromCollection extends FilmInformationEvent {
  final String collectionId;
  
  const RemoveFilmFromCollection({required this.collectionId});

  @override
  List<Object?> get props => [collectionId];
}

class UpdateFilmLinks extends FilmInformationEvent {
  final List<String> updatedCollectionIds;

  const UpdateFilmLinks({required this.updatedCollectionIds});

  @override
  List<Object?> get props => [updatedCollectionIds]; 
}

class UpdateUserFilmInformation extends FilmInformationEvent {
  final int? userRating;
  final String? userComment;

  const UpdateUserFilmInformation({this.userRating, this.userComment});

  @override
  List<Object?> get props => [userRating, userComment];
}

class RefreshFilmInformation extends FilmInformationEvent {
  final FilmEntity film;

  const RefreshFilmInformation({required this.film});

  @override
  List<Object?> get props => [film];
}
