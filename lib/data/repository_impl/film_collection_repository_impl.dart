import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/film_collection_link_local_data_source.dart';
import 'package:movie_search_assistant_bloc/data/models/film_collection_link.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';

class FilmCollectionRepositoryImpl implements FilmCollectionRepository{
  final FilmCollectionLinkLocalDataSource filmCollectionLinkLocalDataSource;
  
  FilmCollectionRepositoryImpl({required this.filmCollectionLinkLocalDataSource});

  @override
  Stream<List<int>> watchLinksByCollectionId(String collectionId) {
    try{
      return filmCollectionLinkLocalDataSource.watchLinksByCollectionId(collectionId);
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Stream<List<String>> watchLinksByFilmId(int filmId) {
    try{
      return filmCollectionLinkLocalDataSource.watchLinksByFilmId(filmId);
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<void> addFilmCollectionLink(FilmCollectionLink filmCollectionLink) async {
    try{
      return await filmCollectionLinkLocalDataSource.addLink(filmCollectionLink);
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }    
  }

  @override
  Future<void> removeFilmCollectionLink(FilmCollectionLink filmCollectionLink) async {
    try{
      return await filmCollectionLinkLocalDataSource.removeLink(filmCollectionLink);
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }    
  }

  @override
  Future<void> removeAllLinksByCollectionId(String collectionId) async {
    try{
      return await filmCollectionLinkLocalDataSource.removeAllLinksByCollectionId(collectionId);
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }    
  }

  @override
  Future<List<FilmCollectionLink>> getAllFilmCollectionLinks() async {
    try{
      return await filmCollectionLinkLocalDataSource.getAllLinks();
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<List<int>> getFilmIdsByCollectionId(String collectionId) async {
    try{
      return await filmCollectionLinkLocalDataSource.getFilmIdsByCollectionId(collectionId);
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }    
  }

  @override
  Future<List<String>> getCollectionIdsByFilmId(int filmId) async {
    try{
      return await filmCollectionLinkLocalDataSource.getCollectionIdsByFilmId(filmId);
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }    
  }
}