import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class WatchFilmUseCase {
  final FilmRepository filmRepository;

  WatchFilmUseCase({required this.filmRepository});

  Stream<FilmEntity?> call(int filmId) => filmRepository.watchFilm(filmId);
}