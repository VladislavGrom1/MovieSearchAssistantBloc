
import 'package:hive/hive.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/hive_storage_keys.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';

class CollectionLocalDataSource {
  
  Future<void> addCollection(CollectionModel collection) async {
    try{
      final storageBox = Hive.box<CollectionModel>(HiveStorageKeys.collectionModelKeyBox);
      await storageBox.put(collection.collectionName, collection);
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<List<CollectionModel>?> getAllCollections() async {
    try{
      final storageBox = Hive.box<CollectionModel>(HiveStorageKeys.collectionModelKeyBox);
      List<CollectionModel>? collections = storageBox.values.toList();
      return collections;
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<void> removeCollection(String collectionName) async {
    try{
      final storageBox = Hive.box<CollectionModel>(HiveStorageKeys.collectionModelKeyBox);
      await storageBox.delete(collectionName);
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<bool> collectionsIsExist(String collectionName) async {
    try{
      final storageBox = Hive.box<CollectionModel>(HiveStorageKeys.collectionModelKeyBox);
      return storageBox.containsKey(collectionName);
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  Future<void> removeAllCollections() async {
    try{
      final storageBox = Hive.box<CollectionModel>(HiveStorageKeys.collectionModelKeyBox);
      await storageBox.clear();
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<bool> collectionIsExist(String collectionName) async {
    try{
      final storageBox = Hive.box<CollectionModel>(HiveStorageKeys.collectionModelKeyBox);
      return storageBox.containsKey(collectionName);
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }
}