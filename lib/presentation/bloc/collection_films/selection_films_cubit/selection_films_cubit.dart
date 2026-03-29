import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'selection_films_state.dart';

class SelectionFilmsCubit extends Cubit<SelectionFilmsState> {
  SelectionFilmsCubit() : super(SelectionFilmsState());

  void enterSelection(int filmId) {
    emit(SelectionFilmsState(
      isSelectionMode: true,
      selectedFilmIds: {filmId}
    ));
  }

  void toggle(int filmId) {
    final newFilmIds = Set<int>.from(state.selectedFilmIds);

    if(newFilmIds.contains(filmId)){
      newFilmIds.remove(filmId);
    } else{
      newFilmIds.add(filmId);
    }

    emit(state.copyWith(
      isSelectionMode: newFilmIds.isNotEmpty,
      selectedFilmIds: newFilmIds
    ));
  }

  void selectAll(List<int> filmIds){
    emit(state.copyWith(
      isSelectionMode: true,
      selectedFilmIds: filmIds.toSet()
    ));
  }

  void clear(){
    emit(const SelectionFilmsState());
  }
}
