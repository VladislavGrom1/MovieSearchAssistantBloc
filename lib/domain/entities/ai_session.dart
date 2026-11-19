import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_search.dart';

/// Чем закончился ход сессии.
///
/// Ошибки не сохраняются: неудачный ход живёт только в памяти BLoC и может
/// быть повторён, а в историю попадают лишь успешные ответы.
enum AiSessionTurnStatus { loaded, empty }

/// Один ход диалога: что пользователь спросил и что ответил ассистент.
///
/// Сейчас у сессии ровно один ход, но модель рассчитана на диалог из
/// нескольких промптов — в будущем у хода появится ещё и текст ответа.
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

/// Сессия AI-Ассистента: диалог из одного или нескольких ходов.
///
/// [id] — секунды от epoch (`createdAt.millisecondsSinceEpoch ~/ 1000`): Hive
/// принимает int-ключи только до `0xFFFFFFFF`, поэтому миллисекунды не годятся.
/// То же число используется именем папки с постерами. [updatedAt] — когда
/// сессию в последний раз трогали; по нему вытесняется самая старая сессия при
/// переполнении лимита.
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
