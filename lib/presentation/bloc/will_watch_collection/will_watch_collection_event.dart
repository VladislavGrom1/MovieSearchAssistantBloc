part of 'will_watch_collection_bloc.dart';

sealed class WillWatchCollectionEvent extends Equatable {
  const WillWatchCollectionEvent();

  @override
  List<Object> get props => [];
}

class DisplaySavedFilms extends WillWatchCollectionEvent{}

class SavedFilmsUpdated extends WillWatchCollectionEvent{
  final List<FilmDetailModel> savedFilms;
  
  const SavedFilmsUpdated({required this.savedFilms});
  
  @override
  List<Object> get props => [savedFilms];
}
