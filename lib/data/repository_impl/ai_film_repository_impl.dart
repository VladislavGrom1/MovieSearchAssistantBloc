import 'package:movie_search_assistant_bloc/data/data_sources/remote/ai_film_remote_data_source.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/repository/ai_film_repository.dart';

class AiFilmRepositoryImpl implements AiFilmRepository {
  final AiFilmRemoteDataSource aiFilmRemoteDataSource;

  AiFilmRepositoryImpl(this.aiFilmRemoteDataSource);

  @override
  Future<List<AiFilmRecommendation>> getRecommendations(String query) async {
    final models = await aiFilmRemoteDataSource.getRecommendations(query);
    return models.map((model) => model.toEntity()).toList();
  }
}
