import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/film_collection_link.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';

class WatchLinksUseCase {
  final FilmCollectionRepository filmCollectionRepository;

  WatchLinksUseCase({required this.filmCollectionRepository});

  Stream<List<FilmCollectionLink>> call(){
    try{
      return filmCollectionRepository.watchLinks();
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}