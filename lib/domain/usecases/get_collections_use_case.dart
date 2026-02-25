import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';

class GetCollectionsUseCase {
  final CollectionRepository collectionRepository;

  GetCollectionsUseCase({required this.collectionRepository});

  Future<List<CollectionEntity>?> call() async{
    try{
      List<CollectionEntity>? collections = await collectionRepository.getAllCollections();
      return collections;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}