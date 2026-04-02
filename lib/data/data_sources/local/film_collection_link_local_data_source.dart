import 'package:hive/hive.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/hive_storage_keys.dart';
import 'package:movie_search_assistant_bloc/data/models/film_collection_link.dart';
import 'package:rxdart/rxdart.dart';

class FilmCollectionLinkLocalDataSource {

  Stream<List<FilmCollectionLink>> watchLinks() {
    try{
      final filmCollectionLinkBox = Hive.box<FilmCollectionLink>(HiveStorageKeys.filmCollectionLinkBox);
      return filmCollectionLinkBox.watch()
      .map((_) => filmCollectionLinkBox.values.toList())
      .startWith(filmCollectionLinkBox.values.toList());
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Stream<List<int>> watchLinksByCollectionId(String collectionId){
    try{
      final filmCollectionLinkBox = Hive.box<FilmCollectionLink>(HiveStorageKeys.filmCollectionLinkBox);
      return filmCollectionLinkBox.watch()
      .map((_) => filmCollectionLinkBox.values.where((link) => link.collectionId == collectionId)
      .map((link) => link.filmId).toList())
      .startWith(
        filmCollectionLinkBox.values
        .where((link) => link.collectionId == collectionId)
        .map((link) => link.filmId)
        .toList()
      );
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Stream<List<String>> watchLinksByFilmId(int filmId) {
    try{
      final filmCollectionLinkBox = Hive.box<FilmCollectionLink>(HiveStorageKeys.filmCollectionLinkBox);
      return filmCollectionLinkBox.watch()
      .map((_) => filmCollectionLinkBox.values
      .where((link) => link.filmId == filmId)
      .map((link) => link.collectionId).toList())
      .startWith(
        filmCollectionLinkBox.values
        .where((link) => link.filmId == filmId)
        .map((link) => link.collectionId)
        .toList()
      );
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<void> addLink(FilmCollectionLink filmCollectionLink) async {
    try{
      final filmCollectionLinkBox = Hive.box<FilmCollectionLink>(HiveStorageKeys.filmCollectionLinkBox);
      final key = "${filmCollectionLink.filmId}_${filmCollectionLink.collectionId}";
      await filmCollectionLinkBox.put(key, filmCollectionLink);
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<void> removeLink(FilmCollectionLink filmCollectionLink) async {
    try{
      final filmCollectionLinkBox = Hive.box<FilmCollectionLink>(HiveStorageKeys.filmCollectionLinkBox);
      final key = "${filmCollectionLink.filmId}_${filmCollectionLink.collectionId}";
      await filmCollectionLinkBox.delete(key);
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<void> removeAllLinksByCollectionId(String collectionId) async {
    try{
      final filmCollectionLinkBox = Hive.box<FilmCollectionLink>(HiveStorageKeys.filmCollectionLinkBox);
      final keysToDelete = filmCollectionLinkBox.keys.where((key) {
        final link = filmCollectionLinkBox.get(key);
        return link?.collectionId == collectionId;
      }).toList();
      await filmCollectionLinkBox.deleteAll(keysToDelete);
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<void> removeAllLinks() async {
    try{
      final filmCollectionLinkBox = Hive.box<FilmCollectionLink>(HiveStorageKeys.filmCollectionLinkBox);
      filmCollectionLinkBox.clear();
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<List<FilmCollectionLink>> getAllLinks() async {
    try{
      final filmCollectionLinkBox = Hive.box<FilmCollectionLink>(HiveStorageKeys.filmCollectionLinkBox);
      return filmCollectionLinkBox.values.toList();
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<List<int>> getFilmIdsByCollectionId(String collectionId) async {
    try{
      final filmCollectionLinkBox = Hive.box<FilmCollectionLink>(HiveStorageKeys.filmCollectionLinkBox);
      return filmCollectionLinkBox.values.where((link) => link.collectionId == collectionId).map((link) => link.filmId).toList();
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<List<String>> getCollectionIdsByFilmId(int filmId) async {
    try{
      final filmCollectionLinkBox = Hive.box<FilmCollectionLink>(HiveStorageKeys.filmCollectionLinkBox);
      return filmCollectionLinkBox.values.where((link) => link.filmId == filmId).map((link) => link.collectionId).toList();
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }
}