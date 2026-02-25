part of 'library_bloc.dart';

sealed class LibraryState extends Equatable {
  const LibraryState();
  
  @override
  List<Object> get props => [];
}

final class LibraryInitial extends LibraryState {}

final class SavedFilmsLoading extends LibraryState{}

final class SavedFilmsLoadedSuccessful extends LibraryState{
  final List<FilmEntity> savedFilms;

  const SavedFilmsLoadedSuccessful({required this.savedFilms});

  SavedFilmsLoadedSuccessful copyWith({
    List<FilmEntity>? savedFilms
  }) {
    return SavedFilmsLoadedSuccessful(
      savedFilms: savedFilms ?? this.savedFilms
    );
  }

  @override
  List<Object> get props => [savedFilms];
}

final class SavedFilmsLoadedFailure extends LibraryState{
  final String exceptionType;
  final int? statusCode;
  
  const SavedFilmsLoadedFailure({required this.exceptionType, this.statusCode});

  @override
  List<Object> get props => [exceptionType, if (statusCode != null) statusCode!];
}
