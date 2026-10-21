import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class GetSimilarFilmsUseCase {
  final FilmRepository filmRepository;
 
  GetSimilarFilmsUseCase({required this.filmRepository});
 
  Future<List<FilmEntity>> call(int idFilm) {
    return filmRepository.getSimilarFilms(idFilm);
  }
}