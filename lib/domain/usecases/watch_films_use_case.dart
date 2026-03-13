import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class WatchFilmsUseCase {
  final FilmRepository filmRepository;

  WatchFilmsUseCase({required this.filmRepository});

  Stream<List<FilmEntity>> call() {
    try{
      return filmRepository.watchFilms();
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}