part of 'filter_film_bloc.dart';

sealed class FilterFilmState extends Equatable {
  const FilterFilmState();

  @override
  List<Object> get props => [];
}

class FilterFilmInitial extends FilterFilmState {}

class FiltersLoaded extends FilterFilmState {
  final Map<FilterType, dynamic> filters;
  
  const FiltersLoaded({
    this.filters = const {
      FilterType.countries: -1,
      FilterType.genres: -1,
      FilterType.years: 'Все годы',
    },
  });
  
  int get country => filters[FilterType.countries] as int;
  int get genre => filters[FilterType.genres] as int;
  String get years => filters[FilterType.years] as String;
  
  // Для удобства
  (int, int) get yearRange {
    final yearsValue = years;
    if (yearsValue.contains('-')) {
      final parts = yearsValue.split('-');
      return (int.parse(parts[0]), int.parse(parts[1]));
    }
    return (int.parse(yearsValue), int.parse(yearsValue));
  }
  
  FiltersLoaded copyWith({
    Map<FilterType, dynamic>? filters,
  }) {
    return FiltersLoaded(
      filters: filters ?? this.filters,
    );
  }
  
  @override
  List<Object> get props => [filters];
}