import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class WatchSavedFilmsUseCase {
  final FilmRepository filmRepository;

  WatchSavedFilmsUseCase({required this.filmRepository});

  Stream<List<FilmDetailModel>> call() {
    return filmRepository.watchSavedFilms();
  }
}