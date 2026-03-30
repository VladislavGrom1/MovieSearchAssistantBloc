part of 'search_films_bloc.dart';

sealed class SearchFilmsState extends Equatable {
  const SearchFilmsState();
  
  @override
  List<Object?> get props => [];
}

final class SearchFilmsInitial extends SearchFilmsState {}

final class SearchFilmsLoading extends SearchFilmsState{}

final class CollectionsFilmsLoadedSuccessful extends SearchFilmsState{
  final Map<String, List<FilmEntity>?>? filmCollectionsMap;
  const CollectionsFilmsLoadedSuccessful({required this.filmCollectionsMap});

  @override
  List<Object?> get props => [filmCollectionsMap];
}

final class CollectionsFilmsLoadedFailure extends SearchFilmsState{
  final String message;
  
  const CollectionsFilmsLoadedFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
