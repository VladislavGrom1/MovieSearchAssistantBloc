
import 'dart:async';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/collection_local_data_source.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';

class CollectionsRepositoryImpl implements CollectionRepository{
  final CollectionLocalDataSource collectionLocalDataSource;
  final _savedCollectionsController = StreamController<List<CollectionEntity>>.broadcast();

  CollectionsRepositoryImpl({
    required this.collectionLocalDataSource
  });

  @override
  Stream<List<CollectionEntity>> watchSavedCollections(){
    return _savedCollectionsController.stream;
  }

  @override
  Future<void> addCollection(CollectionModel collection) async {
    try{
      await collectionLocalDataSource.addCollection(collection);
      final updatedCollections = await getAllCollections();
      if(updatedCollections != null){
        _savedCollectionsController.add(updatedCollections);
      }
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<List<CollectionEntity>?> getAllCollections() async {
    try{
      List<CollectionEntity> collectionsEntity = [];
      List<CollectionModel>? collectionsModel = await collectionLocalDataSource.getAllCollections();
      if(collectionsModel != null){
        for(var collectionModel in collectionsModel){
          collectionsEntity.add(CollectionEntity.fromCollectionModel(collectionModel));
        }
        return collectionsEntity;
      }
      return null;
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<void> removeCollection(String collectionId) async {
    try{
      await collectionLocalDataSource.removeCollection(collectionId);
      final updatedCollections = await getAllCollections();
      if(updatedCollections != null){
        _savedCollectionsController.add(updatedCollections);
      }
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<void> removeAllCollection() async {
    try{
      await collectionLocalDataSource.removeAllCollections();
      final updatedCollections = await getAllCollections();
      if(updatedCollections != null){
        _savedCollectionsController.add(updatedCollections);
      }
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<bool> collectionIsExist(String collectionId) async {
    try{
      return await collectionLocalDataSource.collectionIsExist(collectionId);
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}