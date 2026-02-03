part of 'filter_film_bloc.dart';

sealed class FilterFilmEvent extends Equatable {
  const FilterFilmEvent();

  @override
  List<Object> get props => [];
}

class LoadFilters extends FilterFilmEvent {}

class UpdateFilterValue extends FilterFilmEvent {
  final FilterType filterType;
  final dynamic value;
  
  const UpdateFilterValue({
    required this.filterType,
    required this.value,
  });
  
  @override
  List<Object> get props => [filterType, value];
}

class ResetFilters extends FilterFilmEvent {}
