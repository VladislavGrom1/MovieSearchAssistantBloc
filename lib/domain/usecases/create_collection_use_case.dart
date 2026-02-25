import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';

class CreateCollectionUseCase {
  final CollectionRepository collectionRepository;

  CreateCollectionUseCase({required this.collectionRepository});

  Future<void> call(CollectionEntity collection) async {
    try{
      if(await collectionRepository.collectionIsExist(collection.collectionName!)){
        return;
      }
      await collectionRepository.addCollection(CollectionModel.fromCollectionEntity(collection));
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}