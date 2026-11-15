import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/repository/ai_film_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class GetAiFilmRecommendationsUseCase {
  final AiFilmRepository aiFilmRepository;
  final FilmRepository filmRepository;

  GetAiFilmRecommendationsUseCase({required this.aiFilmRepository, required this.filmRepository});

  Future<List<AiFilmRecommendation>> call(String query, bool onlyNew) async {
    List<int> savedKinopoiskIds = [];
    List<String?> savedTitles = [];
    if(onlyNew){
       final result = await filmRepository.getSavedIdsAndTitles();
       savedKinopoiskIds = result.$1;
       savedTitles = result.$2;
    }
    return aiFilmRepository.getRecommendations(query, onlyNew, savedKinopoiskIds, savedTitles);
  }
}
