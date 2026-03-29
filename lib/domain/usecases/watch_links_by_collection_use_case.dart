
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:rxdart/rxdart.dart';

class WatchLinksByCollectionUseCase {
  final FilmRepository filmRepository;
  final FilmCollectionRepository filmCollectionRepository;

  WatchLinksByCollectionUseCase({
    required this.filmRepository,
    required this.filmCollectionRepository
  });

  Stream<List<FilmEntity>> call(String collectionId) {
    try{
      return Rx.combineLatest2(
        filmCollectionRepository.watchLinksByCollectionId(collectionId),
        filmRepository.watchFilms(),
        (List<int> filmIds, List<FilmEntity> allFilms) {
          return allFilms.where((film) => filmIds.contains(film.kinopoiskId)).toList();
        },
      );
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}