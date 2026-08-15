import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';

class RenameCollectionUseCase {
  final CollectionRepository collectionRepository;

  RenameCollectionUseCase({required this.collectionRepository});

  Future<void> call(CollectionEntity collection, String updatedName) async {
    try{
      CollectionEntity updatedCollection = collection.copyWith(name: updatedName);
      await collectionRepository.addCollection(CollectionModel.fromCollectionEntity(updatedCollection));
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}