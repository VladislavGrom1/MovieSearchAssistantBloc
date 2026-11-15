import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_search.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_ai_film_recommendations_use_case.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_assistant/ai_assistant_event.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_assistant/ai_assistant_state.dart';


class AiAssistantBloc extends Bloc<AiAssistantEvent, AiAssistantState> {
  static const int maxSearches = 20;

  static const String unknownErrorMessage = 'Неизвестная ошибка. Попробуйте ещё раз.';

  final GetAiFilmRecommendationsUseCase getAiFilmRecommendationsUseCase;

  int _nextSearchId = 0;

  AiAssistantBloc(this.getAiFilmRecommendationsUseCase)
      : super(const AiAssistantInitial()) {
    on<AiAssistantRequested>(_onRequested);
    on<AiAssistantRetryRequested>(_onRetryRequested);
    on<AiAssistantSearchExpanded>(_onSearchExpanded);
  }

  Future<void> _onRequested(
    AiAssistantRequested event,
    Emitter<AiAssistantState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      return;
    }

    final search = AiFilmSearch(
      id: _nextSearchId,
      query: query,
      onlyNew: event.onlyNew,
      createdAt: DateTime.now(),
    );
    _nextSearchId++;

    final searches = <AiFilmSearchState>[
      ..._searchesOf(state),
      AiFilmSearchLoading(search),
    ];
    final visibleSearches = searches.length > maxSearches
        ? searches.sublist(searches.length - maxSearches)
        : searches;

    emit(
      AiAssistantFeed(
        searches: visibleSearches,
        expandedSearchId: search.id,
      ),
    );

    await _loadFilms(search, emit);
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

    await _loadFilms(failed.search, emit);
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

  Future<void> _loadFilms(
    AiFilmSearch search,
    Emitter<AiAssistantState> emit,
  ) async {
    try {
      final films = await getAiFilmRecommendationsUseCase(
        search.query,
        search.onlyNew,
      );
      if (_isClosed(emit)) {
        return;
      }

      _replace(
        emit,
        films.isEmpty
            ? AiFilmSearchEmpty(search)
            : AiFilmSearchLoaded(search, films),
      );
    } on RemoteDataSourceException catch (e) {
      if (_isClosed(emit)) {
        return;
      }

      _replace(emit, AiFilmSearchFailure(search, e.message));
    } catch (_) {
      if (_isClosed(emit)) {
        return;
      }

      _replace(emit, AiFilmSearchFailure(search, unknownErrorMessage));
    }
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

  List<AiFilmSearchState> _searchesOf(AiAssistantState state) {
    return switch (state) {
      AiAssistantInitial() => const <AiFilmSearchState>[],
      AiAssistantFeed(:final searches) => searches,
    };
  }

  int? _expandedSearchIdOf(AiAssistantState state) {
    return switch (state) {
      AiAssistantInitial() => null,
      AiAssistantFeed(:final expandedSearchId) => expandedSearchId,
    };
  }

  bool _isClosed(Emitter<AiAssistantState> emit) => isClosed || emit.isDone;
}
