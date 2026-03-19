import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';

class WatchLinksByFilmUseCase {
  final FilmCollectionRepository filmCollectionRepository;

  WatchLinksByFilmUseCase({required this.filmCollectionRepository});

  Stream<List<String>> call(int filmId){
    try{
      return filmCollectionRepository.watchLinksByFilmId(filmId);
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}