import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';

abstract class AiFilmRepository {
  Future<List<AiFilmRecommendation>> getRecommendations(String query);
}
