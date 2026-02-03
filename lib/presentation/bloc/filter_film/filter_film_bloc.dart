import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/domain/entities/filter_data.dart';

part 'filter_film_event.dart';
part 'filter_film_state.dart';

class FilterFilmBloc extends Bloc<FilterFilmEvent, FilterFilmState> {
  FilterFilmBloc() : super(FilterFilmInitial()) {
    on<LoadFilters>(_onLoadFilters);
    on<UpdateFilterValue>(_onUpdateFilterValue);
    on<ResetFilters>(_onResetFilters);
  }

  void _onLoadFilters(LoadFilters event, Emitter emit) {
    emit(const FiltersLoaded());
  }

  void _onUpdateFilterValue(UpdateFilterValue event, Emitter emit) {
    final currentState = state;
    if (currentState is FiltersLoaded) {
      final updatedFilters = Map<FilterType, dynamic>.from(currentState.filters);
      updatedFilters[event.filterType] = event.value;
      
      emit(currentState.copyWith(filters: updatedFilters));
    }
  }

  void _onResetFilters(ResetFilters event, Emitter emit) {
    emit(const FiltersLoaded());
  }
}
