import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class SearchCollectionFilmsUseCase {
  final FilmRepository filmRepository;

  SearchCollectionFilmsUseCase({
    required this.filmRepository, 
  });

  Future<List<FilmEntity>?> call(String collectionName, int page) async{
    List<FilmEntity>? filmCollectionsMap = [];
    try{
      filmCollectionsMap = await filmRepository.getCollectionFilms(collectionName, page);
      return filmCollectionsMap;
    } on RemoteDataSourceException{
      rethrow;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}