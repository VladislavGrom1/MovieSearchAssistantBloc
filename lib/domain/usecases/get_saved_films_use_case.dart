import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class GetSavedFilmsUseCase {
  final FilmRepository filmRepository;

  GetSavedFilmsUseCase({
    required this.filmRepository
  });

  Future<List<FilmEntity>> call(String collectionId) async{
    try{
      List<FilmEntity> savedFilms = await filmRepository.getFilmsFromLocalDataSource(collectionId);
      return savedFilms;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}