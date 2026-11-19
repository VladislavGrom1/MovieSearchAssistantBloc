import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_search.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_session.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_assistant/ai_assistant_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_assistant/ai_assistant_event.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_assistant/ai_assistant_state.dart';

import '../../helpers/ai_assistant_test_harness.dart';

void main() {
  late AiAssistantHarness harness;
  late List<AiFilmRecommendation> films;

  AiFilmSearch search(int id, String query, {bool onlyNew = false}) {
    return AiFilmSearch(
      id: id,
      query: query,
      onlyNew: onlyNew,
      createdAt: harness.now,
    );
  }

  AiFilmSearchState loadedSearch(int id, String query) {
    return AiFilmSearchLoaded(search(id, query), films);
  }

  AiAssistantBloc buildBloc() => harness.buildBloc();

  setUp(() {
    harness = AiAssistantHarness();
    films = harness.films;
  });

  test('initial state has no searches', () async {
    final bloc = buildBloc();

    expect(bloc.state, isA<AiAssistantInitial>());

    await bloc.close();
  });

  blocTest<AiAssistantBloc, AiAssistantState>(
    'adds a search, expands it and loads films',
    build: () {
      when(() => harness.recommendations('комедия', false)).thenAnswer((_) async => films);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AiAssistantRequested('комедия')),
    expect: () => [
      isA<AiAssistantFeed>()
          .having((state) => state.searches.length, 'searches.length', 1)
          .having(
            (state) => state.searches.first,
            'first',
            isA<AiFilmSearchLoading>(),
          )
          .having(
            (state) => state.searches.first.query,
            'query',
            'комедия',
          )
          .having(
            (state) => state.searches.first.onlyNew,
            'onlyNew',
            false,
          )
          .having(
            (state) => state.expanded?.query,
            'expanded query',
            'комедия',
          ),
      isA<AiAssistantFeed>()
          .having(
            (state) => state.searches.first,
            'first',
            isA<AiFilmSearchLoaded>()
                .having((search) => search.filmCount, 'filmCount', 1),
          )
          .having(
            (state) => state.searches.first.query,
            'query',
            'комедия',
          ),
    ],
    verify: (_) {
      verify(() => harness.recommendations('комедия', false)).called(1);
      final session = verify(() => harness.saveSession(captureAny()))
          .captured
          .single as AiSession;
      expect(session.turns.single.search.query, 'комедия');
      expect(session.turns.single.status, AiSessionTurnStatus.loaded);
      expect(session.turns.single.films, films);
    },
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'passes the only-new mode to the use case',
    build: () {
      when(() => harness.recommendations('комедия', true)).thenAnswer((_) async => films);
      return buildBloc();
    },
    act: (bloc) =>
        bloc.add(const AiAssistantRequested('комедия', onlyNew: true)),
    expect: () => [
      isA<AiAssistantFeed>()
          .having((state) => state.searches.first.onlyNew, 'onlyNew', true)
          .having((state) => state.expanded?.onlyNew, 'expanded', true),
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first,
        'first',
        isA<AiFilmSearchLoaded>(),
      ),
    ],
    verify: (_) => verify(() => harness.recommendations('комедия', true)).called(1),
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'retry reuses the only-new mode of the search',
    seed: () => AiAssistantFeed(
      searches: <AiFilmSearchState>[
        AiFilmSearchFailure(search(0, 'триллер', onlyNew: true), 'нет сети'),
      ],
      expandedSearchId: 0,
    ),
    build: () {
      when(() => harness.recommendations('триллер', true)).thenAnswer((_) async => films);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AiAssistantRetryRequested(0)),
    // Повтор держит загрузку минимум `retryLoadingMinDuration`.
    wait: const Duration(milliseconds: 500),
    expect: () => [
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first,
        'first',
        isA<AiFilmSearchLoading>()
            .having((search) => search.onlyNew, 'onlyNew', true),
      ),
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first,
        'first',
        isA<AiFilmSearchLoaded>(),
      ),
    ],
    verify: (_) => verify(() => harness.recommendations('триллер', true)).called(1),
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'trims the query before sending',
    build: () {
      when(() => harness.recommendations('триллер', false)).thenAnswer((_) async => films);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AiAssistantRequested('  триллер  ')),
    expect: () => [
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first.query,
        'query',
        'триллер',
      ),
      isA<AiAssistantFeed>(),
    ],
    verify: (_) => verify(() => harness.recommendations('триллер', false)).called(1),
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'ignores an empty query',
    build: buildBloc,
    act: (bloc) => bloc.add(const AiAssistantRequested('   ')),
    expect: () => <AiAssistantState>[],
    verify: (_) => verifyNever(() => harness.recommendations(any(), any())),
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'marks the search as empty when nothing was found',
    build: () {
      when(() => harness.recommendations(any(), any()))
          .thenAnswer((_) async => const <AiFilmRecommendation>[]);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AiAssistantRequested('аниме')),
    expect: () => [
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first,
        'first',
        isA<AiFilmSearchLoading>(),
      ),
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first,
        'first',
        isA<AiFilmSearchEmpty>(),
      ),
    ],
    verify: (_) {
      final session = verify(() => harness.saveSession(captureAny()))
          .captured
          .single as AiSession;
      expect(session.turns.single.status, AiSessionTurnStatus.empty);
      expect(session.turns.single.films, isEmpty);
    },
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'keeps the service error message on failure',
    build: () {
      when(() => harness.recommendations(any(), any())).thenThrow(
        AiServiceFailure('Модель не смогла ответить. Попробуйте позже.'),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AiAssistantRequested('ужасы')),
    expect: () => [
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first,
        'first',
        isA<AiFilmSearchLoading>(),
      ),
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first,
        'first',
        isA<AiFilmSearchFailure>().having(
          (search) => search.message,
          'message',
          'Модель не смогла ответить. Попробуйте позже.',
        ),
      ),
    ],
    verify: (_) => verifyNever(() => harness.saveSession(any())),
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'shows the network message when connection is lost',
    build: () {
      when(() => harness.recommendations(any(), any())).thenThrow(NetworkFailure());
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AiAssistantRequested('комедия')),
    expect: () => [
      isA<AiAssistantFeed>(),
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first,
        'first',
        isA<AiFilmSearchFailure>().having(
          (search) => search.message,
          'message',
          contains('Отсутствует интернет-соединение'),
        ),
      ),
    ],
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'retry replaces the failure with loading and then shows films',
    seed: () => AiAssistantFeed(
      searches: <AiFilmSearchState>[
        AiFilmSearchFailure(search(0, 'триллер'), 'нет сети'),
      ],
      expandedSearchId: 0,
    ),
    build: () {
      when(() => harness.recommendations('триллер', false)).thenAnswer((_) async => films);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AiAssistantRetryRequested(0)),
    // Повтор держит загрузку минимум `retryLoadingMinDuration`.
    wait: const Duration(milliseconds: 500),
    expect: () => [
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first,
        'first',
        isA<AiFilmSearchLoading>(),
      ),
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first,
        'first',
        isA<AiFilmSearchLoaded>().having(
          (search) => search.filmCount,
          'filmCount',
          1,
        ),
      ),
    ],
    verify: (_) => verify(() => harness.saveSession(any())).called(1),
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'retry shows loading and then brings the failure back',
    seed: () => AiAssistantFeed(
      searches: <AiFilmSearchState>[
        AiFilmSearchFailure(search(0, 'триллер'), 'нет сети'),
      ],
      expandedSearchId: 0,
    ),
    build: () {
      when(() => harness.recommendations(any(), any())).thenThrow(NetworkFailure());
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AiAssistantRetryRequested(0)),
    // Повтор держит загрузку минимум `retryLoadingMinDuration`.
    wait: const Duration(milliseconds: 500),
    expect: () => [
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first,
        'first',
        isA<AiFilmSearchLoading>(),
      ),
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first,
        'first',
        isA<AiFilmSearchFailure>().having(
          (search) => search.message,
          'message',
          contains('Отсутствует интернет-соединение'),
        ),
      ),
    ],
    verify: (_) => verifyNever(() => harness.saveSession(any())),
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'ignores retry while the retry is already in flight',
    seed: () => AiAssistantFeed(
      searches: <AiFilmSearchState>[
        AiFilmSearchLoading(search(0, 'триллер')),
      ],
      expandedSearchId: 0,
    ),
    build: buildBloc,
    act: (bloc) => bloc.add(const AiAssistantRetryRequested(0)),
    expect: () => <AiAssistantState>[],
    verify: (_) => verifyNever(() => harness.recommendations(any(), any())),
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'ignores retry for unknown or successful search',
    seed: () => AiAssistantFeed(
      searches: <AiFilmSearchState>[loadedSearch(1, 'комедия')],
      expandedSearchId: 1,
    ),
    build: buildBloc,
    act: (bloc) {
      bloc
        ..add(const AiAssistantRetryRequested(99))
        ..add(const AiAssistantRetryRequested(1));
    },
    expect: () => <AiAssistantState>[],
    verify: (_) => verifyNever(() => harness.recommendations(any(), any())),
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'expands an older search',
    seed: () => AiAssistantFeed(
      searches: <AiFilmSearchState>[
        loadedSearch(0, 'комедия'),
        loadedSearch(1, 'триллер'),
      ],
      expandedSearchId: 1,
    ),
    build: buildBloc,
    act: (bloc) => bloc.add(const AiAssistantSearchExpanded(0)),
    expect: () => [
      isA<AiAssistantFeed>()
          .having((state) => state.expandedSearchId, 'expandedSearchId', 0)
          .having((state) => state.expanded?.id, 'expanded id', 0)
          .having(
            (state) => state.expanded?.query,
            'expanded query',
            'комедия',
          ),
    ],
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'drops the oldest search above the limit',
    seed: () => AiAssistantFeed(
      searches: List<AiFilmSearchState>.generate(
        AiAssistantBloc.maxSearches,
        (index) => loadedSearch(100 + index, 'запрос $index'),
      ),
      expandedSearchId: 100 + AiAssistantBloc.maxSearches - 1,
    ),
    build: () {
      when(() => harness.recommendations(any(), any())).thenAnswer((_) async => films);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AiAssistantRequested('новый')),
    expect: () => [
      isA<AiAssistantFeed>()
          .having(
            (state) => state.searches.length,
            'searches.length',
            AiAssistantBloc.maxSearches,
          )
          .having((state) => state.searches.first.query, 'first query', 'новый')
          .having(
            (state) => state.searches.map((search) => search.id).toList(),
            'ids',
            isNot(contains(100 + AiAssistantBloc.maxSearches - 1)),
          )
          .having(
            (state) => state.expanded?.query,
            'expanded',
            'новый',
          ),
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first,
        'first',
        isA<AiFilmSearchLoaded>(),
      ),
    ],
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'restores saved sessions when the screen opens',
    build: () {
      when(() => harness.sessions()).thenAnswer(
        (_) async => <AiSession>[
          AiSession(
            id: 7,
            createdAt: DateTime(2026, 11, 15, 10),
            updatedAt: DateTime(2026, 11, 15, 10),
            turns: <AiSessionTurn>[
              AiSessionTurn(
                search: AiFilmSearch(
                  id: 7,
                  query: 'комедия',
                  createdAt: DateTime(2026, 11, 15, 10),
                ),
                status: AiSessionTurnStatus.loaded,
                films: films,
              ),
            ],
          ),
        ],
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AiAssistantHistoryRequested()),
    expect: () => [
      isA<AiAssistantHistoryLoading>(),
      isA<AiAssistantFeed>()
          .having((state) => state.searches.length, 'searches.length', 1)
          .having((state) => state.expandedSearchId, 'expandedSearchId', 7)
          .having((state) => state.expanded?.query, 'query', 'комедия')
          .having(
            (state) => state.expanded,
            'expanded',
            isA<AiFilmSearchLoaded>(),
          ),
    ],
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'shows the empty state when there is no history',
    build: buildBloc,
    act: (bloc) => bloc.add(const AiAssistantHistoryRequested()),
    expect: () => [
      isA<AiAssistantHistoryLoading>(),
      isA<AiAssistantInitial>(),
    ],
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'deletes a session and expands the next one',
    seed: () => AiAssistantFeed(
      searches: <AiFilmSearchState>[
        loadedSearch(2, 'комедия'),
        loadedSearch(1, 'триллер'),
      ],
      expandedSearchId: 2,
    ),
    build: buildBloc,
    act: (bloc) => bloc.add(const AiAssistantSessionDeleteRequested(2)),
    expect: () => [
      isA<AiAssistantFeed>()
          .having((state) => state.searches.length, 'searches.length', 1)
          .having((state) => state.searches.single.id, 'id', 1)
          .having((state) => state.expandedSearchId, 'expandedSearchId', 1),
    ],
    verify: (_) => verify(() => harness.deleteSession(2)).called(1),
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'returns to the empty state after deleting the last session',
    seed: () => AiAssistantFeed(
      searches: <AiFilmSearchState>[loadedSearch(2, 'комедия')],
      expandedSearchId: 2,
    ),
    build: buildBloc,
    act: (bloc) => bloc.add(const AiAssistantSessionDeleteRequested(2)),
    expect: () => [isA<AiAssistantInitial>()],
    verify: (_) => verify(() => harness.deleteSession(2)).called(1),
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'clears all sessions',
    seed: () => AiAssistantFeed(
      searches: <AiFilmSearchState>[
        loadedSearch(2, 'комедия'),
        loadedSearch(1, 'триллер'),
      ],
      expandedSearchId: 2,
    ),
    build: buildBloc,
    act: (bloc) => bloc.add(const AiAssistantSessionsClearRequested()),
    expect: () => [isA<AiAssistantInitial>()],
    verify: (_) => verify(() => harness.clearSessions()).called(1),
  );

  test('ignores a response that came after close', () async {
    final completer = Completer<List<AiFilmRecommendation>>();

    when(() => harness.recommendations(any(), any())).thenAnswer((_) => completer.future);

    final bloc = buildBloc();

    bloc.add(const AiAssistantRequested('комедия'));
    await Future<void>.delayed(Duration.zero);
    await bloc.close();

    completer.complete(films);
    await Future<void>.delayed(Duration.zero);

    expect(bloc.isClosed, isTrue);
  });
}
