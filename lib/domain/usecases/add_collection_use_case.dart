import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';

class AddCollectionUseCase {
  final CollectionRepository collectionRepository;

  AddCollectionUseCase({required this.collectionRepository});

  Future<void> call(CollectionEntity collection) async {
    try{
      await collectionRepository.addCollection(CollectionModel.fromCollectionEntity(collection));
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}