part of 'searched_films_bloc.dart';

sealed class SearchedFilmsState extends Equatable {
  const SearchedFilmsState();
  
  @override
  List<Object> get props => [];
}

final class SearchedFilmsInitial extends SearchedFilmsState {}

final class SearchedFilmsLoading extends SearchedFilmsState{}

final class SearchedFilmsLoadedSuccessful extends SearchedFilmsState{
  List<FilmCardEntity> searchedFilms;

  SearchedFilmsLoadedSuccessful({required this.searchedFilms});

  @override
  List<Object> get props => [searchedFilms];
}

final class SearchedFilmsLoadedFailure extends SearchedFilmsState{
  final String exceptionType;
  final int? statusCode;
  
  SearchedFilmsLoadedFailure({required this.exceptionType, this.statusCode});

  @override
  List<Object> get props => [exceptionType, if (statusCode != null) statusCode!];
}
