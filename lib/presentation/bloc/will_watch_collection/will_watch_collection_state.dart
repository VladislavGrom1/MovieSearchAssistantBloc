part of 'will_watch_collection_bloc.dart';

sealed class WillWatchCollectionState extends Equatable {
  const WillWatchCollectionState();
  
  @override
  List<Object> get props => [];
}

final class WillWatchCollectionInitial extends WillWatchCollectionState {}

final class SavedFilmsLoading extends WillWatchCollectionState{}

final class SavedFilmsLoadedSuccessful extends WillWatchCollectionState{
  final List<FilmDetailModel> savedFilms;

  const SavedFilmsLoadedSuccessful({required this.savedFilms});

  SavedFilmsLoadedSuccessful copyWith({
    List<FilmDetailModel>? savedFilms
  }) {
    return SavedFilmsLoadedSuccessful(
      savedFilms: savedFilms ?? this.savedFilms
    );
  }

  @override
  List<Object> get props => [savedFilms];
}

final class SavedFilmsLoadedFailure extends WillWatchCollectionState{
  final String exceptionType;
  final int? statusCode;
  
  const SavedFilmsLoadedFailure({required this.exceptionType, this.statusCode});

  @override
  List<Object> get props => [exceptionType, if (statusCode != null) statusCode!];
}
