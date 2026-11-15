import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_search.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_ai_film_recommendations_use_case.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_assistant/ai_assistant_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_assistant/ai_assistant_event.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_assistant/ai_assistant_state.dart';

class MockGetAiFilmRecommendationsUseCase extends Mock
    implements GetAiFilmRecommendationsUseCase {}

void main() {
  late MockGetAiFilmRecommendationsUseCase useCase;
  late List<AiFilmRecommendation> films;

  final DateTime createdAt = DateTime(2026, 11, 14, 15, 30);

  AiFilmSearch search(int id, String query, {bool onlyNew = false}) {
    return AiFilmSearch(
      id: id,
      query: query,
      onlyNew: onlyNew,
      createdAt: createdAt,
    );
  }

  AiFilmSearchState loadedSearch(int id, String query) {
    return AiFilmSearchLoaded(search(id, query), films);
  }

  setUp(() {
    useCase = MockGetAiFilmRecommendationsUseCase();
    films = <AiFilmRecommendation>[
      const AiFilmRecommendation(
        film: FilmEntity(
          kinopoiskId: 472,
          nameRu: 'Одиннадцать друзей Оушена',
          year: 2001,
          genres: <String>['криминал', 'комедия'],
        ),
        description: 'Команда мастеров готовит ограбление трёх казино.',
      ),
    ];
  });

  test('initial state has no searches', () async {
    final bloc = AiAssistantBloc(useCase);

    expect(bloc.state, isA<AiAssistantInitial>());

    await bloc.close();
  });

  blocTest<AiAssistantBloc, AiAssistantState>(
    'adds a search, expands it and loads films',
    build: () {
      when(() => useCase('комедия', false)).thenAnswer((_) async => films);
      return AiAssistantBloc(useCase);
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
    verify: (_) => verify(() => useCase('комедия', false)).called(1),
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'passes the only-new mode to the use case',
    build: () {
      when(() => useCase('комедия', true)).thenAnswer((_) async => films);
      return AiAssistantBloc(useCase);
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
    verify: (_) => verify(() => useCase('комедия', true)).called(1),
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
      when(() => useCase('триллер', true)).thenAnswer((_) async => films);
      return AiAssistantBloc(useCase);
    },
    act: (bloc) => bloc.add(const AiAssistantRetryRequested(0)),
    expect: () => [
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first.onlyNew,
        'onlyNew',
        true,
      ),
      isA<AiAssistantFeed>().having(
        (state) => state.searches.first,
        'first',
        isA<AiFilmSearchLoaded>(),
      ),
    ],
    verify: (_) => verify(() => useCase('триллер', true)).called(1),
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'trims the query before sending',
    build: () {
      when(() => useCase('триллер', false)).thenAnswer((_) async => films);
      return AiAssistantBloc(useCase);
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
    verify: (_) => verify(() => useCase('триллер', false)).called(1),
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'ignores an empty query',
    build: () => AiAssistantBloc(useCase),
    act: (bloc) => bloc.add(const AiAssistantRequested('   ')),
    expect: () => <AiAssistantState>[],
    verify: (_) => verifyNever(() => useCase(any(), any())),
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'marks the search as empty when nothing was found',
    build: () {
      when(() => useCase(any(), any()))
          .thenAnswer((_) async => const <AiFilmRecommendation>[]);
      return AiAssistantBloc(useCase);
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
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'keeps the service error message on failure',
    build: () {
      when(() => useCase(any(), any())).thenThrow(
        AiServiceFailure('Модель не смогла ответить. Попробуйте позже.'),
      );
      return AiAssistantBloc(useCase);
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
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'shows the network message when connection is lost',
    build: () {
      when(() => useCase(any(), any())).thenThrow(NetworkFailure());
      return AiAssistantBloc(useCase);
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
    'retry replaces the failure with loading and then films',
    seed: () => AiAssistantFeed(
      searches: <AiFilmSearchState>[
        AiFilmSearchFailure(search(0, 'триллер'), 'нет сети'),
      ],
      expandedSearchId: 0,
    ),
    build: () {
      when(() => useCase('триллер', false)).thenAnswer((_) async => films);
      return AiAssistantBloc(useCase);
    },
    act: (bloc) => bloc.add(const AiAssistantRetryRequested(0)),
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
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'ignores retry for unknown or successful search',
    seed: () => AiAssistantFeed(
      searches: <AiFilmSearchState>[loadedSearch(1, 'комедия')],
      expandedSearchId: 1,
    ),
    build: () => AiAssistantBloc(useCase),
    act: (bloc) {
      bloc
        ..add(const AiAssistantRetryRequested(99))
        ..add(const AiAssistantRetryRequested(1));
    },
    expect: () => <AiAssistantState>[],
    verify: (_) => verifyNever(() => useCase(any(), any())),
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
    build: () => AiAssistantBloc(useCase),
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
      when(() => useCase(any(), any())).thenAnswer((_) async => films);
      return AiAssistantBloc(useCase);
    },
    act: (bloc) => bloc.add(const AiAssistantRequested('новый')),
    expect: () => [
      isA<AiAssistantFeed>()
          .having(
            (state) => state.searches.length,
            'searches.length',
            AiAssistantBloc.maxSearches,
          )
          .having((state) => state.searches.first.id, 'first id', 101)
          .having((state) => state.searches.last.query, 'last query', 'новый')
          .having(
            (state) => state.expanded?.query,
            'expanded',
            'новый',
          ),
      isA<AiAssistantFeed>().having(
        (state) => state.searches.last,
        'last',
        isA<AiFilmSearchLoaded>(),
      ),
    ],
  );

  test('ignores a response that came after close', () async {
    final completer = Completer<List<AiFilmRecommendation>>();

    when(() => useCase(any(), any())).thenAnswer((_) => completer.future);

    final bloc = AiAssistantBloc(useCase);

    bloc.add(const AiAssistantRequested('комедия'));
    await Future<void>.delayed(Duration.zero);
    await bloc.close();

    completer.complete(films);
    await Future<void>.delayed(Duration.zero);

    expect(bloc.isClosed, isTrue);
  });
}
