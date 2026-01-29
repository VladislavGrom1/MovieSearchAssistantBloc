
import 'package:movie_search_assistant_bloc/domain/entities/film_card_entity.dart';

abstract class FilmRepository {
  Future<List<FilmCardEntity>?> getCollectionFilms(String apiKey, String collectionName, int page);
}