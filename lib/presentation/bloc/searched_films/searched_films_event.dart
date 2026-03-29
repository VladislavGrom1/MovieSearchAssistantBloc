part of 'searched_films_bloc.dart';

sealed class SearchedFilmsEvent extends Equatable {
  const SearchedFilmsEvent();

  @override
  List<Object> get props => [];
}

class LoadSearchedFilms extends SearchedFilmsEvent{
  final String? nameCollection;
  final String? keyword;
  final List<int>? countries;
  final List<int>? genres;
  final int? yearFrom;
  final int? yearTo;
  final int page;
  
  const LoadSearchedFilms({
    this.nameCollection,
    this.keyword,
    this.countries,
    this.genres,
    this.yearFrom,
    this.yearTo,
    this.page = 1
  });
}

class LoadNextPage extends SearchedFilmsEvent {
  final String? nameCollection;
  final String? keyword;
  final List<int>? countries;
  final List<int>? genres;
  final int? yearFrom;
  final int? yearTo;

  const LoadNextPage({
    this.nameCollection,
    this.keyword,
    this.countries,
    this.genres,
    this.yearFrom,
    this.yearTo,
  });
}

class RefreshFilmsPage extends SearchedFilmsEvent{}


