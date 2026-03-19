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
