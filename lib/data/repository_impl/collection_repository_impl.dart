
import 'dart:async';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/collection_local_data_source.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';

class CollectionRepositoryImpl implements CollectionRepository{
  final CollectionLocalDataSource collectionLocalDataSource;

  CollectionRepositoryImpl({
    required this.collectionLocalDataSource
  });

  @override
  Stream<List<CollectionEntity>> watchCollections(){
    try{
      return collectionLocalDataSource.watchCollections().map((collectionModels) {
        return collectionModels.map((model) {
          return CollectionEntity.fromCollectionModel(model);
        }).toList();
      });
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<void> addCollection(CollectionModel collection) async {
    try{
      await collectionLocalDataSource.addCollection(collection);
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<List<CollectionEntity>> getAllCollections() async {
    try{
      List<CollectionEntity> collectionsEntity = [];
      List<CollectionModel>? collectionsModel = await collectionLocalDataSource.getAllCollections();
      if(collectionsModel != null){
        for(var collectionModel in collectionsModel){
          collectionsEntity.add(CollectionEntity.fromCollectionModel(collectionModel));
        }
      }
      return collectionsEntity;
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

  @override
  Future<void> updateCollection(CollectionEntity collectionEntity) async {
    try{
      final collectionModel = CollectionModel.fromCollectionEntity(collectionEntity);
      await collectionLocalDataSource.addCollection(collectionModel);
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}