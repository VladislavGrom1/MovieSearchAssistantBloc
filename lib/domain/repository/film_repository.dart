
import 'package:movie_search_assistant_bloc/domain/entities/film_card_entity.dart';

abstract class FilmRepository {
  Future<List<FilmCardEntity>?> getCollectionFilms(String collectionName, int page);

  Future<List<FilmCardEntity>?> getFilterFilms(String? keyword, List<int>? countries, List<int>? genres, int? yearFrom, int? yearTo, int page);
}