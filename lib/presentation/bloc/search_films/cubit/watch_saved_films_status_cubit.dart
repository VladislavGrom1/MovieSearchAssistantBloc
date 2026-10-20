import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_saved_films_status_use_case.dart';
 
class FilmLibraryStatus extends Equatable {
  final bool isSaved;
  final int? userRating;
 
  const FilmLibraryStatus({this.isSaved = false, this.userRating});
 
  static const notSaved = FilmLibraryStatus();
 
  @override
  List<Object?> get props => [isSaved, userRating];
}
 
class SavedFilmsStatusState extends Equatable {
  final Map<int, int?> ratingsById;
 
  const SavedFilmsStatusState([this.ratingsById = const {}]);
 
  FilmLibraryStatus statusOf(int? filmId) {
    if (filmId == null || !ratingsById.containsKey(filmId)) {
      return FilmLibraryStatus.notSaved;
    }
    return FilmLibraryStatus(isSaved: true, userRating: ratingsById[filmId]);
  }
 
  @override
  List<Object?> get props => [ratingsById];
}
 
class WatchSavedFilmsStatusCubit extends Cubit<SavedFilmsStatusState> {
  final WatchSavedFilmsStatusUseCase watchSavedFilmsStatusUseCase;
  StreamSubscription? _subscription;
 
  WatchSavedFilmsStatusCubit(this.watchSavedFilmsStatusUseCase)
      : super(const SavedFilmsStatusState()) {
    _subscription = watchSavedFilmsStatusUseCase().listen(
      (ratingsById) => emit(SavedFilmsStatusState(ratingsById)),
    );
  }
 
  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}