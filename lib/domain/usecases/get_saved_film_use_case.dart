import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class GetSavedFilmUseCase {
  final FilmRepository filmRepository;
  final FilmCollectionRepository filmCollectionRepository;

  GetSavedFilmUseCase({required this.filmRepository, required this.filmCollectionRepository});

  Future<(FilmEntity?, List<String> collectionIds)> call(int filmId) async{
    try{
      FilmEntity? savedFilm = await filmRepository.getFilmFromLocalDataSource(filmId);
      List<String> collectionIds = await filmCollectionRepository.getCollectionIdsByFilmId(filmId);
      return (savedFilm, collectionIds);
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}