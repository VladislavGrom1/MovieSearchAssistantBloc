part of 'film_information_bloc.dart';

sealed class FilmInformationEvent extends Equatable {
  const FilmInformationEvent();

  @override
  List<Object> get props => [];
}

class DisplayFilmInformationEvent extends FilmInformationEvent{
  final int idFilm;

  const DisplayFilmInformationEvent({required this.idFilm});

  @override
  List<Object> get props => [idFilm];
}

class AddFilmInCollectionEvent extends FilmInformationEvent {
  final String collectionId;

  const AddFilmInCollectionEvent({required this.collectionId});

  @override
  List<Object> get props => [collectionId];
}

class RemoveFilmFromCollectionEvent extends FilmInformationEvent {
  final String collectionId;

  const RemoveFilmFromCollectionEvent({required this.collectionId});

  @override
  List<Object> get props => [collectionId];
}

class OnSavedCollectionsUpdated extends FilmInformationEvent {
  final List<CollectionEntity> collections;

  const OnSavedCollectionsUpdated({required this.collections});

  @override
  List<Object> get props => [collections];
}