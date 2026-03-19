
import 'package:movie_search_assistant_bloc/data/models/film_collection_link.dart';

abstract class FilmCollectionRepository {

  Stream<List<int>> watchLinksByCollectionId(String collectionId);

  Stream<List<String>> watchLinksByFilmId(int filmId);
  
  Future<void> addFilmCollectionLink(FilmCollectionLink filmCollectionLink);

  Future<void> removeFilmCollectionLink(FilmCollectionLink filmCollectionLink);

  Future<void> removeAllLinksByCollectionId(String collectionId);

  Future<List<FilmCollectionLink>> getAllFilmCollectionLinks();

  Future<List<int>> getFilmIdsByCollectionId(String collectionId);

  Future<List<String>> getCollectionIdsByFilmId(int filmId);

}