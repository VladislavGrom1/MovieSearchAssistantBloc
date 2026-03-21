part of 'collection_films_bloc.dart';

sealed class CollectionFilmsEvent extends Equatable {
  const CollectionFilmsEvent();

  @override
  List<Object> get props => [];
}

class GetSavedFilms extends CollectionFilmsEvent {
  final String collectionId;

  const GetSavedFilms({required this.collectionId});

  @override
  List<Object> get props => [];
}

class UpdateSavedFilms extends CollectionFilmsEvent {
  final List<FilmEntity> updatedSavedFilms;

  const UpdateSavedFilms({required this.updatedSavedFilms});

  @override
  List<Object> get props => [updatedSavedFilms];
}

class RemoveFilm extends CollectionFilmsEvent{
  final FilmEntity film;
  final String collectionId;
 
  const RemoveFilm({required this.film, required this.collectionId});

  @override
  List<Object> get props => [film, collectionId];
}
