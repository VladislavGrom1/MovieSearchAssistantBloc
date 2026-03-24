part of 'selection_films_cubit.dart';

class SelectionFilmsState extends Equatable {
  final bool isSelectionMode;
  final Set<int> selectedFilmIds;

  const SelectionFilmsState({
    this.isSelectionMode = false,
    this.selectedFilmIds = const {}
  });

  SelectionFilmsState copyWith({
    bool? isSelectionMode,
    Set<int>? selectedFilmIds
  }) {
    return SelectionFilmsState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedFilmIds: selectedFilmIds ?? this.selectedFilmIds
    );
  }

  @override
  List<Object> get props => [isSelectionMode, selectedFilmIds];
}
