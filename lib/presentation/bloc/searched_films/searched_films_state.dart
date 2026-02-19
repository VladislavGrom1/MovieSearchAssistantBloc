part of 'searched_films_bloc.dart';

sealed class SearchedFilmsState extends Equatable {
  const SearchedFilmsState();
  
  @override
  List<Object> get props => [];
}

final class SearchedFilmsInitial extends SearchedFilmsState {}

final class SearchedFilmsLoading extends SearchedFilmsState{}

final class SearchedFilmsLoadedSuccessful extends SearchedFilmsState{
  final List<FilmEntity> searchedFilms;
  final bool isLoadingMore;
  final bool hasReachedMax;

  const SearchedFilmsLoadedSuccessful({
    required this.searchedFilms,
    this.isLoadingMore = false,
    this.hasReachedMax = false
  });

  SearchedFilmsLoadedSuccessful copyWith({
    List<FilmEntity>? searchedFilms,
    bool? isLoadingMore,
    bool? hasReachedMax,
  }) {
    return SearchedFilmsLoadedSuccessful(
      searchedFilms: searchedFilms ?? this.searchedFilms,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [searchedFilms, isLoadingMore, hasReachedMax];
}

final class SearchedFilmsLoadedFailure extends SearchedFilmsState{
  final String exceptionType;
  final int? statusCode;
  
  const SearchedFilmsLoadedFailure({required this.exceptionType, this.statusCode});

  @override
  List<Object> get props => [exceptionType, if (statusCode != null) statusCode!];
}
