import 'package:movie_search_assistant_bloc/data/data_sources/local/image_storage_service.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';

class RemoveImageCollectionUseCase {
  final CollectionRepository collectionRepository;
  final ImageStorageService imageStorageService;
 
  RemoveImageCollectionUseCase({
    required this.collectionRepository,
    required this.imageStorageService,
  });
 
  Future<void> call(CollectionEntity collection) async {
    if (collection.imagePath == null || collection.imagePath!.isEmpty) {
      return;
    }
 
    await imageStorageService.deleteCollectionImage(collection.id!);
 
    final updatedCollection = collection.copyWith(clearImagePath: true);
    await collectionRepository.updateCollection(updatedCollection);
  }
}