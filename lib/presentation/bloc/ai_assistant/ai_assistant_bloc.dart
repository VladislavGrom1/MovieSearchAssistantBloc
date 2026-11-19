import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/retry_loading.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_search.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_session.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/clear_ai_sessions_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/delete_ai_session_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_ai_film_recommendations_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_ai_sessions_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/save_ai_session_use_case.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_assistant/ai_assistant_event.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_assistant/ai_assistant_state.dart';

class AiAssistantBloc extends Bloc<AiAssistantEvent, AiAssistantState> {
  static const int maxSearches = 20;

  static const String unknownErrorMessage =
      'Неизвестная ошибка. Попробуйте ещё раз.';

  final GetAiFilmRecommendationsUseCase getAiFilmRecommendationsUseCase;
  final GetAiSessionsUseCase getAiSessionsUseCase;
  final SaveAiSessionUseCase saveAiSessionUseCase;
  final DeleteAiSessionUseCase deleteAiSessionUseCase;
  final ClearAiSessionsUseCase clearAiSessionsUseCase;

  AiAssistantBloc({
    required this.getAiFilmRecommendationsUseCase,
    required this.getAiSessionsUseCase,
    required this.saveAiSessionUseCase,
    required this.deleteAiSessionUseCase,
    required this.clearAiSessionsUseCase,
  }) : super(const AiAssistantInitial()) {
    on<AiAssistantHistoryRequested>(_onHistoryRequested);
    on<AiAssistantRequested>(_onRequested);
    on<AiAssistantRetryRequested>(_onRetryRequested);
    on<AiAssistantSearchExpanded>(_onSearchExpanded);
    on<AiAssistantSessionDeleteRequested>(_onSessionDeleteRequested);
    on<AiAssistantSessionsClearRequested>(_onSessionsClearRequested);
  }

  /// Поднимает сохранённые сессии из Hive при открытии экрана.
  Future<void> _onHistoryRequested(
    AiAssistantHistoryRequested event,
    Emitter<AiAssistantState> emit,
  ) async {
    emit(const AiAssistantHistoryLoading());

    try {
      final sessions = await getAiSessionsUseCase();
      final searches = <AiFilmSearchState>[
        for (final session in sessions) _stateFromSession(session),
      ];

      if (searches.isEmpty) {
        emit(const AiAssistantInitial());
        return;
      }

      emit(
        AiAssistantFeed(
          searches: searches,
          expandedSearchId: searches.first.id,
        ),
      );
    } catch (_) {
      emit(const AiAssistantInitial());
    }
  }

  Future<void> _onRequested(
    AiAssistantRequested event,
    Emitter<AiAssistantState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      return;
    }

    final searches = _searchesOf(state);
    final search = AiFilmSearch(
      id: _newSessionId(searches),
      query: query,
      onlyNew: event.onlyNew,
      createdAt: DateTime.now(),
    );

    final updatedSearches = <AiFilmSearchState>[
      AiFilmSearchLoading(search),
      ...searches,
    ];
    final visibleSearches = updatedSearches.length > maxSearches
        ? updatedSearches.sublist(0, maxSearches)
        : updatedSearches;

    emit(
      AiAssistantFeed(
        searches: visibleSearches,
        expandedSearchId: search.id,
      ),
    );

    await _loadFilms(search, emit, persist: true);
  }

  Future<void> _onRetryRequested(
    AiAssistantRetryRequested event,
    Emitter<AiAssistantState> emit,
  ) async {
    final searches = _searchesOf(state);
    final index = searches.indexWhere((search) => search.id == event.searchId);

    if (index == -1) {
      return;
    }

    final failed = searches[index];
    if (failed is! AiFilmSearchFailure) {
      return;
    }

    final updatedSearches = <AiFilmSearchState>[...searches];
    updatedSearches[index] = AiFilmSearchLoading(failed.search);

    emit(
      AiAssistantFeed(
        searches: updatedSearches,
        expandedSearchId: failed.id,
      ),
    );

    await _loadFilms(
      failed.search,
      emit,
      minimumLoadingDuration: retryLoadingMinDuration,
      persist: true,
    );
  }

  void _onSearchExpanded(
    AiAssistantSearchExpanded event,
    Emitter<AiAssistantState> emit,
  ) {
    final searches = _searchesOf(state);

    if (_expandedSearchIdOf(state) == event.searchId) {
      return;
    }

    if (!searches.any((search) => search.id == event.searchId)) {
      return;
    }

    emit(
      AiAssistantFeed(
        searches: searches,
        expandedSearchId: event.searchId,
      ),
    );
  }

  Future<void> _onSessionDeleteRequested(
    AiAssistantSessionDeleteRequested event,
    Emitter<AiAssistantState> emit,
  ) async {
    final searches = _searchesOf(state);
    final index = searches.indexWhere((search) => search.id == event.sessionId);

    if (index == -1) {
      return;
    }

    try {
      await deleteAiSessionUseCase(event.sessionId);
    } catch (_) {
      return;
    }

    final updatedSearches = <AiFilmSearchState>[...searches]..removeAt(index);

    if (updatedSearches.isEmpty) {
      emit(const AiAssistantInitial());
      return;
    }

    final expandedSearchId = _expandedSearchIdOf(state);

    emit(
      AiAssistantFeed(
        searches: updatedSearches,
        expandedSearchId: expandedSearchId == event.sessionId
            ? updatedSearches.first.id
            : expandedSearchId,
      ),
    );
  }

  Future<void> _onSessionsClearRequested(
    AiAssistantSessionsClearRequested event,
    Emitter<AiAssistantState> emit,
  ) async {
    if (_searchesOf(state).isEmpty) {
      return;
    }

    try {
      await clearAiSessionsUseCase();
    } catch (_) {
      return;
    }

    emit(const AiAssistantInitial());
  }

  Future<void> _loadFilms(
    AiFilmSearch search,
    Emitter<AiAssistantState> emit, {
    Duration minimumLoadingDuration = Duration.zero,
    bool persist = false,
  }) async {
    // Держим загрузку на экране минимум `minimumLoadingDuration`, чтобы при
    // быстром ответе скелетоны не мелькали. Таймер стартует вместе с запросом,
    // то есть сразу после эмита `AiFilmSearchLoading`.
    final Future<void> minimumLoadingDelay =
        minimumLoadingDuration == Duration.zero
            ? Future<void>.value()
            : Future<void>.delayed(minimumLoadingDuration);

    try {
      final films = await getAiFilmRecommendationsUseCase(
        search.query,
        search.onlyNew,
      );
      await minimumLoadingDelay;
      if (_isClosed(emit)) {
        return;
      }

      await _persistIfNeeded(search, films, persist);

      _replace(
        emit,
        films.isEmpty
            ? AiFilmSearchEmpty(search)
            : AiFilmSearchLoaded(search, films),
      );
    } on RemoteDataSourceException catch (e) {
      await minimumLoadingDelay;
      if (_isClosed(emit)) {
        return;
      }

      _replace(emit, AiFilmSearchFailure(search, e.message));
    } catch (_) {
      await minimumLoadingDelay;
      if (_isClosed(emit)) {
        return;
      }

      _replace(emit, AiFilmSearchFailure(search, unknownErrorMessage));
    }
  }

  /// Сохраняет успешный поиск в историю. Ошибка сохранения не мешает показать
  /// результаты: сессия просто не попадёт в историю.
  Future<void> _persistIfNeeded(
    AiFilmSearch search,
    List<AiFilmRecommendation> films,
    bool persist,
  ) async {
    if (!persist) {
      return;
    }

    try {
      await saveAiSessionUseCase(
        AiSession(
          id: search.id,
          createdAt: search.createdAt,
          updatedAt: DateTime.now(),
          turns: [
            AiSessionTurn(
              search: search,
              status: films.isEmpty
                  ? AiSessionTurnStatus.empty
                  : AiSessionTurnStatus.loaded,
              films: films,
            ),
          ],
        ),
      );
    } catch (_) {
      // История — вспомогательная функция: без неё экран работает как раньше.
    }
  }

  AiFilmSearchState _stateFromSession(AiSession session) {
    final turn = session.lastTurn;

    if (turn == null) {
      return AiFilmSearchEmpty(
        AiFilmSearch(
          id: session.id,
          query: '',
          createdAt: session.createdAt,
        ),
      );
    }

    final search = AiFilmSearch(
      id: session.id,
      query: turn.search.query,
      onlyNew: turn.search.onlyNew,
      createdAt: turn.search.createdAt,
    );

    if (turn.status == AiSessionTurnStatus.empty || turn.films.isEmpty) {
      return AiFilmSearchEmpty(search);
    }

    return AiFilmSearchLoaded(search, turn.films);
  }

  void _replace(
    Emitter<AiAssistantState> emit,
    AiFilmSearchState replacement,
  ) {
    final searches = _searchesOf(state);
    final index = searches.indexWhere((search) => search.id == replacement.id);

    if (index == -1) {
      return;
    }

    final updatedSearches = <AiFilmSearchState>[...searches];
    updatedSearches[index] = replacement;

    emit(
      AiAssistantFeed(
        searches: updatedSearches,
        expandedSearchId: _expandedSearchIdOf(state),
      ),
    );
  }

  /// id сессии — секунды от epoch.
  ///
  /// Hive принимает int-ключи только в диапазоне `0…0xFFFFFFFF`, а миллисекунды
  /// в него не помещаются; секунды помещаются до 2106 года. Две сессии в одну
  /// секунду разводим инкрементом.
  int _newSessionId(List<AiFilmSearchState> searches) {
    var id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    while (searches.any((search) => search.id == id)) {
      id++;
    }

    return id;
  }

  List<AiFilmSearchState> _searchesOf(AiAssistantState state) {
    return switch (state) {
      AiAssistantInitial() => const <AiFilmSearchState>[],
      AiAssistantHistoryLoading() => const <AiFilmSearchState>[],
      AiAssistantFeed(:final searches) => searches,
    };
  }

  int? _expandedSearchIdOf(AiAssistantState state) {
    return switch (state) {
      AiAssistantInitial() => null,
      AiAssistantHistoryLoading() => null,
      AiAssistantFeed(:final expandedSearchId) => expandedSearchId,
    };
  }

  bool _isClosed(Emitter<AiAssistantState> emit) => isClosed || emit.isDone;
}
