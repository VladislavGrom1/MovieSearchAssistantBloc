import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_similar_films_use_case.dart';
 
sealed class SimilarFilmsState extends Equatable {
  const SimilarFilmsState();
 
  @override
  List<Object?> get props => [];
}
 
class SimilarFilmsInitial extends SimilarFilmsState {
  const SimilarFilmsInitial();
}
 
class SimilarFilmsLoading extends SimilarFilmsState {
  const SimilarFilmsLoading();
}
 
class SimilarFilmsLoaded extends SimilarFilmsState {
  final List<FilmEntity> films;
 
  const SimilarFilmsLoaded(this.films);
 
  @override
  List<Object?> get props => [films];
}
 
class SimilarFilmsFailure extends SimilarFilmsState {
  const SimilarFilmsFailure();
}
 
class SimilarFilmsCubit extends Cubit<SimilarFilmsState> {
  final GetSimilarFilmsUseCase getSimilarFilmsUseCase;
 
  SimilarFilmsCubit({required this.getSimilarFilmsUseCase})
      : super(const SimilarFilmsInitial());
 
  Future<void> load(int filmId) async {
    if (state is SimilarFilmsLoading || state is SimilarFilmsLoaded) return;
 
    emit(const SimilarFilmsLoading());
    try {
      final films = await getSimilarFilmsUseCase(filmId);
      if (isClosed) return;
      emit(SimilarFilmsLoaded(films));
    } catch (_) {
      if (isClosed) return;
      emit(const SimilarFilmsFailure());
    }
  }
}