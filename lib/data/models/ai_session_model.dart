import 'package:hive/hive.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_search.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_session.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';

part 'ai_session_model.g.dart';

@HiveType(typeId: 5)
class AiSessionModel {
  static const int currentSchemaVersion = 1;

  @HiveField(0)
  final int id;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final DateTime updatedAt;

  @HiveField(3)
  final int schemaVersion;

  @HiveField(4)
  final List<AiSessionTurnModel> turns;

  const AiSessionModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.turns,
    this.schemaVersion = currentSchemaVersion,
  });

  AiSession toEntity() {
    return AiSession(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      turns: turns.map((turn) => turn.toEntity()).toList(),
    );
  }
}

@HiveType(typeId: 6)
class AiSessionTurnModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String query;

  @HiveField(2)
  final bool onlyNew;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final List<AiFilmSnapshotModel> films;

  const AiSessionTurnModel({
    required this.id,
    required this.query,
    required this.onlyNew,
    required this.createdAt,
    required this.status,
    required this.films,
  });

  AiSessionTurn toEntity() {
    return AiSessionTurn(
      search: AiFilmSearch(
        id: id,
        query: query,
        onlyNew: onlyNew,
        createdAt: createdAt,
      ),
      status: status == AiSessionTurnModelStatus.empty
          ? AiSessionTurnStatus.empty
          : AiSessionTurnStatus.loaded,
      films: films.map((film) => film.toRecommendation()).toList(),
    );
  }
}

class AiSessionTurnModelStatus {
  static const String loaded = 'loaded';
  static const String empty = 'empty';
}

@HiveType(typeId: 7)
class AiFilmSnapshotModel {
  @HiveField(0)
  final int? kinopoiskId;

  @HiveField(1)
  final String? nameRu;

  @HiveField(2)
  final String? nameOriginal;

  @HiveField(3)
  final int? year;

  @HiveField(4)
  final List<String> genres;

  @HiveField(5)
  final num? ratingKinopoisk;

  @HiveField(6)
  final String? posterPath;

  @HiveField(7)
  final String? description;

  const AiFilmSnapshotModel({
    this.kinopoiskId,
    this.nameRu,
    this.nameOriginal,
    this.year,
    this.genres = const <String>[],
    this.ratingKinopoisk,
    this.posterPath,
    this.description,
  });

  AiFilmRecommendation toRecommendation() {
    return AiFilmRecommendation(
      film: FilmEntity(
        kinopoiskId: kinopoiskId,
        nameRu: nameRu,
        nameOriginal: nameOriginal,
        year: year,
        genres: genres.isEmpty ? null : genres,
        ratingKinopoisk: ratingKinopoisk,
        localPosterImagePath: posterPath,
      ),
      description: description ?? '',
    );
  }
}
