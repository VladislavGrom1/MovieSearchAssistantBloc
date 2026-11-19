import 'package:movie_search_assistant_bloc/data/data_sources/local/ai_session_local_data_source.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/image_storage_service.dart';
import 'package:movie_search_assistant_bloc/data/models/ai_session_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_session.dart';
import 'package:movie_search_assistant_bloc/domain/repository/ai_session_repository.dart';

class AiSessionRepositoryImpl implements AiSessionRepository {
  final AiSessionLocalDataSource aiSessionLocalDataSource;
  final ImageStorageService imageStorageService;

  const AiSessionRepositoryImpl({
    required this.aiSessionLocalDataSource,
    required this.imageStorageService,
  });

  @override
  Future<List<AiSession>> getSessions() async {
    final models = await aiSessionLocalDataSource.getSessions();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> saveSession(AiSession session) async {
    final turns = <AiSessionTurnModel>[];

    for (final turn in session.turns) {
      final films = <AiFilmSnapshotModel>[];

      for (final recommendation in turn.films) {
        films.add(await _toSnapshot(session.id, recommendation));
      }

      turns.add(
        AiSessionTurnModel(
          id: turn.search.id,
          query: turn.search.query,
          onlyNew: turn.search.onlyNew,
          createdAt: turn.search.createdAt,
          status: turn.status == AiSessionTurnStatus.empty
              ? AiSessionTurnModelStatus.empty
              : AiSessionTurnModelStatus.loaded,
          films: films,
        ),
      );
    }

    final evictedIds = await aiSessionLocalDataSource.saveSession(
      AiSessionModel(
        id: session.id,
        createdAt: session.createdAt,
        updatedAt: session.updatedAt,
        turns: turns,
      ),
    );

    for (final id in evictedIds) {
      await imageStorageService.deleteSessionImages(id);
    }
  }

  @override
  Future<void> deleteSession(int sessionId) async {
    await aiSessionLocalDataSource.deleteSession(sessionId);
    await imageStorageService.deleteSessionImages(sessionId);
  }

  @override
  Future<void> clearSessions() async {
    await aiSessionLocalDataSource.deleteAllSessions();
    await imageStorageService.deleteAllSessionImages();
  }

  /// Скачивает постер в папку сессии. Если не получилось — путь остаётся
  /// `null`, карточка покажет плейсхолдер и повторно постер не докачивается.
  Future<AiFilmSnapshotModel> _toSnapshot(
    int sessionId,
    AiFilmRecommendation recommendation,
  ) async {
    final film = recommendation.film;

    String? posterPath;
    if (film.kinopoiskId != null) {
      posterPath = await imageStorageService.saveSessionPoster(
        sessionId: sessionId,
        filmId: film.kinopoiskId!,
        posterUrl: film.posterUrl ?? film.posterUrlPreview,
      );
    }

    return AiFilmSnapshotModel(
      kinopoiskId: film.kinopoiskId,
      nameRu: film.nameRu,
      nameOriginal: film.nameOriginal,
      year: film.year,
      genres: film.genres ?? const <String>[],
      ratingKinopoisk: film.ratingKinopoisk,
      posterPath: posterPath,
      description: recommendation.description,
    );
  }
}
