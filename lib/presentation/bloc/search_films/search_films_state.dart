part of 'search_films_bloc.dart';

sealed class SearchFilmsState extends Equatable {
  const SearchFilmsState();
  
  @override
  List<Object> get props => [];
}

final class SearchFilmsInitial extends SearchFilmsState {}

final class SearchFilmsLoading extends SearchFilmsState{}

final class CollectionsFilmsLoadedSuccessful extends SearchFilmsState{
  final Map<String, List<FilmCardEntity>?>? filmCollectionsMap;
  const CollectionsFilmsLoadedSuccessful({required this.filmCollectionsMap});

  @override
  List<Object> get props => [if (filmCollectionsMap != null) filmCollectionsMap!];
}

final class CollectionsFilmsLoadedFailure extends SearchFilmsState{
  final String exceptionType;
  final int? statusCode;
  
  const CollectionsFilmsLoadedFailure({required this.exceptionType, this.statusCode});

  @override
  List<Object> get props => [exceptionType, if (statusCode != null) statusCode!];
}
