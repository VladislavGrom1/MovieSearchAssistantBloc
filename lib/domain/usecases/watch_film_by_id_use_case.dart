import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class WatchFilmByIdUseCase {
  final FilmRepository filmRepository;
  const WatchFilmByIdUseCase({required this.filmRepository});

  Stream<FilmEntity?> call(int idFilm) {
    try{
      return filmRepository.watchFilmById(idFilm);
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}