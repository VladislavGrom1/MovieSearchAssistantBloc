import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';

class WatchSavedCollectionsUseCase {
  final CollectionRepository collectionRepository;

  WatchSavedCollectionsUseCase({required this.collectionRepository});

  Stream<List<CollectionEntity>> call() {
    return collectionRepository.watchSavedCollections();
  }
}