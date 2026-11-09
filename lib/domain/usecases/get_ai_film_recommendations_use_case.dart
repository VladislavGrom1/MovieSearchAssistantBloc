import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/repository/ai_film_repository.dart';

class GetAiFilmRecommendationsUseCase {
  final AiFilmRepository aiFilmRepository;

  GetAiFilmRecommendationsUseCase(this.aiFilmRepository);

  Future<List<AiFilmRecommendation>> call(String query) {
    return aiFilmRepository.getRecommendations(query);
  }
}
