import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_search.dart';

enum AiSessionTurnStatus { loaded, empty }

class AiSessionTurn extends Equatable {
  final AiFilmSearch search;
  final AiSessionTurnStatus status;
  final List<AiFilmRecommendation> films;

  const AiSessionTurn({
    required this.search,
    required this.status,
    this.films = const <AiFilmRecommendation>[],
  });

  @override
  List<Object?> get props => [search, status, films];
}

class AiSession extends Equatable {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AiSessionTurn> turns;

  const AiSession({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.turns,
  });

  AiSessionTurn? get lastTurn => turns.isEmpty ? null : turns.last;

  @override
  List<Object?> get props => [id, createdAt, updatedAt, turns];
}
