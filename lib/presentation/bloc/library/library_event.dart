part of 'library_bloc.dart';

sealed class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object> get props => [];
}

class DisplaySavedFilms extends LibraryEvent{}

class SavedFilmsUpdated extends LibraryEvent{
  final List<FilmEntity> savedFilms;
  
  const SavedFilmsUpdated({required this.savedFilms});
  
  @override
  List<Object> get props => [savedFilms];
}

class RemoveFilmFromLibrary extends SavedFilmsUpdated{
  final FilmEntity film;

  const RemoveFilmFromLibrary({required super.savedFilms, required this.film});

  @override
  List<Object> get props => [super.props, film];
}
