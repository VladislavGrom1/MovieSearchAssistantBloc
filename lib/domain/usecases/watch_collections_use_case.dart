import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:rxdart/rxdart.dart';

class WatchCollectionsUseCase {
  final CollectionRepository collectionRepository;
  final FilmCollectionRepository filmCollectionRepository;

  const WatchCollectionsUseCase({
    required this.collectionRepository,
    required this.filmCollectionRepository
  });

  Stream<List<CollectionEntity>> call() {
    try{
      return Rx.combineLatest2(
        collectionRepository.watchCollections(), 
        filmCollectionRepository.watchLinks(),
        (collections, links) {
          final counts = <String, int>{};

          for(final link in links) {
            counts[link.collectionId] = (counts[link.collectionId] ?? 0) + 1;
          }

          return collections.map((c) {
            return CollectionEntity(
              id: c.id,
              name: c.name,
              createdAt: c.createdAt,
              filmCount: counts[c.id] ?? 0,
              imagePath: c.imagePath
            );
          }).toList();
        }
      );
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}