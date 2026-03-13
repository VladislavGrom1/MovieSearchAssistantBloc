import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';

class WatchCollectionsUseCase {
  final CollectionRepository collectionRepository;

  const WatchCollectionsUseCase({required this.collectionRepository});

  Stream<List<CollectionEntity>> call() {
    try{
      return collectionRepository.watchCollections();
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}