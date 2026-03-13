import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';

abstract class CollectionRepository {

  Stream<List<CollectionEntity>> watchCollections();

  Future<void> addCollection(CollectionModel collection);

  Future<List<CollectionEntity>?> getAllCollections();

  Future<void> removeCollection(String collectionId);

  Future<void> removeAllCollection();

  Future<bool> collectionIsExist(String collectionId);

  // TODO: Реализовать обновление коллекции (обновление названия коллекции)
   // TODO: Реализовать event для обновления информации о коллекции (название, количество фильмов) 
   // можно попробовать в UseСase добавления/удаления фильма триггерить обновление количества фильмов
}