part of 'searched_films_bloc.dart';

sealed class SearchedFilmsEvent extends Equatable {
  const SearchedFilmsEvent();

  @override
  List<Object> get props => [];
}

class DisplaySearchedFilms extends SearchedFilmsEvent{
  String? keyword;
  List<int>? countries;
  List<int>? genres;
  int? yearFrom;
  int? yearTo;
  int page;

  DisplaySearchedFilms({
    this.keyword,
    this.countries,
    this.genres,
    this.yearFrom,
    this.yearTo,
    required this.page
  });
}
