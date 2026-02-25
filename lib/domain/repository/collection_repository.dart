import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';

abstract class CollectionRepository {
  Future<void> addCollection(CollectionModel collection);

  Future<List<CollectionEntity>?> getAllCollections();

  Future<void> removeCollection(String collectionName);

  Future<void> removeAllCollection();

  Future<bool> collectionIsExist(String collectionName);

  // TODO: Написать USE CASES для добавления/удаления коллекций и соответственно UI подготовить
}