import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class WatchSavedFilmsUseCase {
  final FilmRepository filmRepository;

  WatchSavedFilmsUseCase({required this.filmRepository});

  Stream<List<FilmEntity>> call() {
    return filmRepository.watchSavedFilms();
  }
}