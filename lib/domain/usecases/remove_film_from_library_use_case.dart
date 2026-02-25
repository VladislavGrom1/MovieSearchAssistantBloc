import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class RemoveFilmFromLibraryUseCase {
  final FilmRepository filmRepository;

  RemoveFilmFromLibraryUseCase({
    required this.filmRepository
  });

  Future<void> call(FilmEntity film) async {
    try{
      await filmRepository.removeFilmFromLocalDataSource(film.kinopoiskId!);
    } on LocalDataSourceException{
      rethrow; 
    } catch(e){
      rethrow;
    }
  }
}