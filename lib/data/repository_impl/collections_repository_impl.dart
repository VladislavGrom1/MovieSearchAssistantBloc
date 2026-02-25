import 'dart:developer';

import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/collection_local_data_source.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';

class CollectionsRepositoryImpl implements CollectionRepository{
  final CollectionLocalDataSource collectionLocalDataSource;

  CollectionsRepositoryImpl({
    required this.collectionLocalDataSource
  });

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
  Future<void> removeCollection(String collectionName) async {
    try{
      await collectionLocalDataSource.removeCollection(collectionName);
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
  Future<bool> collectionIsExist(String collectionName) async {
    try{
      return await collectionLocalDataSource.collectionIsExist(collectionName);
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}