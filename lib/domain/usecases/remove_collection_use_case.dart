import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';

class RemoveCollectionUseCase {
  final CollectionRepository collectionRepository;

  RemoveCollectionUseCase({required this.collectionRepository});

  Future<void> call(String collectionName) async {
    try{
      await collectionRepository.removeCollection(collectionName);
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}