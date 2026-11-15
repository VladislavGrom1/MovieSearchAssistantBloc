import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_search.dart';

/// Состояние экрана AI-Ассистента.
sealed class AiAssistantState extends Equatable {
  const AiAssistantState();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Пользователь ещё ничего не спросил: на экране подсказки «С чего начать».
final class AiAssistantInitial extends AiAssistantState {
  const AiAssistantInitial();
}

/// Лента AI-поисков: развёрнут ровно один, остальные свёрнуты в строки.
final class AiAssistantFeed extends AiAssistantState {
  final List<AiFilmSearchState> searches;
  final int? expandedSearchId;

  const AiAssistantFeed({required this.searches, this.expandedSearchId});

  /// Развёрнутый поиск. Если id не задан — им считается самый свежий.
  AiFilmSearchState? get expanded {
    if (searches.isEmpty) {
      return null;
    }

    for (final search in searches) {
      if (search.id == expandedSearchId) {
        return search;
      }
    }

    return searches.last;
  }

  AiAssistantFeed copyWith({
    List<AiFilmSearchState>? searches,
    int? expandedSearchId,
  }) {
    return AiAssistantFeed(
      searches: searches ?? this.searches,
      expandedSearchId: expandedSearchId ?? this.expandedSearchId,
    );
  }

  @override
  List<Object?> get props => [searches, expandedSearchId];
}

/// Состояние одного AI-поиска в ленте.
sealed class AiFilmSearchState extends Equatable {
  final AiFilmSearch search;

  const AiFilmSearchState(this.search);

  int get id => search.id;

  String get query => search.query;

  bool get onlyNew => search.onlyNew;

  DateTime get createdAt => search.createdAt;

  @override
  List<Object?> get props => [search];
}

/// Запрос отправлен, ждём фильмы от сервиса.
final class AiFilmSearchLoading extends AiFilmSearchState {
  const AiFilmSearchLoading(super.search);
}

/// Сервис вернул фильмы.
final class AiFilmSearchLoaded extends AiFilmSearchState {
  final List<AiFilmRecommendation> films;

  const AiFilmSearchLoaded(super.search, this.films);

  int get filmCount => films.length;

  @override
  List<Object?> get props => [...super.props, films];
}

/// Сервис ответил, что подходящих фильмов нет.
final class AiFilmSearchEmpty extends AiFilmSearchState {
  const AiFilmSearchEmpty(super.search);
}

/// Поиск не удался: сеть, сервер или сервис рекомендаций.
final class AiFilmSearchFailure extends AiFilmSearchState {
  final String message;

  const AiFilmSearchFailure(super.search, this.message);

  @override
  List<Object?> get props => [...super.props, message];
}
