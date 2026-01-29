part of 'search_films_bloc.dart';

sealed class SearchFilmsEvent extends Equatable {
  const SearchFilmsEvent();

  @override
  List<Object> get props => [];
}

class DisplayFilmCollectionsEvent extends SearchFilmsEvent{}
