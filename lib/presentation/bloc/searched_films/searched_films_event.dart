part of 'searched_films_bloc.dart';

sealed class SearchedFilmsEvent extends Equatable {
  const SearchedFilmsEvent();

  @override
  List<Object> get props => [];
}

class DisplaySearchedFilterFilms extends SearchedFilmsEvent{
  final String? keyword;
  final List<int>? countries;
  final List<int>? genres;
  final int? yearFrom;
  final int? yearTo;
  final int page;

  const DisplaySearchedFilterFilms({
    this.keyword,
    this.countries,
    this.genres,
    this.yearFrom,
    this.yearTo,
    required this.page
  });
}

class DisplaySearchedCollectionFilms extends SearchedFilmsEvent{
  final String nameCollection;
  final int page;

  const DisplaySearchedCollectionFilms({
    required this.nameCollection,
    required this.page
  });
}

class LoadNextSearchedFilterFilmsPage extends SearchedFilmsEvent {
  final String? keyword;
  final List<int>? countries;
  final List<int>? genres;
  final int? yearFrom;
  final int? yearTo;

  const LoadNextSearchedFilterFilmsPage({
    this.keyword,
    this.countries,
    this.genres,
    this.yearFrom,
    this.yearTo,
  });
}

class LoadNextSearchedCollectionFilmsPage extends SearchedFilmsEvent {
  final String nameCollection;

  const LoadNextSearchedCollectionFilmsPage({
    required this.nameCollection,
  });
}

class RefreshFilmsPage extends SearchedFilmsEvent{}
