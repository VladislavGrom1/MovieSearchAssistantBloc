import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/cache_service/film_image_cache_service.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/retry_loading.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_search.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_session.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/clear_ai_sessions_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/delete_ai_session_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_ai_film_recommendations_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_ai_sessions_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/save_ai_session_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_saved_films_status_use_case.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_assistant/ai_assistant_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/cubit/watch_saved_films_status_cubit.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/ai_assistant_screen.dart';

class MockGetAiFilmRecommendationsUseCase extends Mock
    implements GetAiFilmRecommendationsUseCase {}

class MockGetAiSessionsUseCase extends Mock implements GetAiSessionsUseCase {}

class MockSaveAiSessionUseCase extends Mock implements SaveAiSessionUseCase {}

class MockDeleteAiSessionUseCase extends Mock implements DeleteAiSessionUseCase {}

class MockClearAiSessionsUseCase extends Mock implements ClearAiSessionsUseCase {}

class MockWatchSavedFilmsStatusUseCase extends Mock
    implements WatchSavedFilmsStatusUseCase {}

void main() {
  late MockGetAiFilmRecommendationsUseCase useCase;
  late MockGetAiSessionsUseCase getSessionsUseCase;
  late MockSaveAiSessionUseCase saveAiSessionUseCase;
  late MockDeleteAiSessionUseCase deleteAiSessionUseCase;
  late MockClearAiSessionsUseCase clearAiSessionsUseCase;
  late MockWatchSavedFilmsStatusUseCase watchSavedFilmsStatusUseCase;
  late List<AiFilmRecommendation> films;

  final DateTime createdAt = DateTime(2026, 11, 14, 15, 30);

  AiSession session({
    required int id,
    required String query,
    DateTime? at,
  }) {
    final DateTime moment = at ?? createdAt;

    return AiSession(
      id: id,
      createdAt: moment,
      updatedAt: moment,
      turns: <AiSessionTurn>[
        AiSessionTurn(
          search: AiFilmSearch(id: id, query: query, createdAt: moment),
          status: AiSessionTurnStatus.loaded,
          films: films,
        ),
      ],
    );
  }

  setUp(() async {
    await getIt.reset();

    useCase = MockGetAiFilmRecommendationsUseCase();
    getSessionsUseCase = MockGetAiSessionsUseCase();
    saveAiSessionUseCase = MockSaveAiSessionUseCase();
    deleteAiSessionUseCase = MockDeleteAiSessionUseCase();
    clearAiSessionsUseCase = MockClearAiSessionsUseCase();
    watchSavedFilmsStatusUseCase = MockWatchSavedFilmsStatusUseCase();
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

    registerFallbackValue(
      AiSession(
        id: 0,
        createdAt: createdAt,
        updatedAt: createdAt,
        turns: const <AiSessionTurn>[],
      ),
    );

    when(() => getSessionsUseCase()).thenAnswer((_) async => const <AiSession>[]);
    when(() => saveAiSessionUseCase(any())).thenAnswer((_) async {});
    when(() => deleteAiSessionUseCase(any())).thenAnswer((_) async {});
    when(() => clearAiSessionsUseCase()).thenAnswer((_) async {});
    when(() => watchSavedFilmsStatusUseCase())
        .thenAnswer((_) => const Stream<Map<int, int?>>.empty());

    getIt.registerFactory(
      () => AiAssistantBloc(
        getAiFilmRecommendationsUseCase: useCase,
        getAiSessionsUseCase: getSessionsUseCase,
        saveAiSessionUseCase: saveAiSessionUseCase,
        deleteAiSessionUseCase: deleteAiSessionUseCase,
        clearAiSessionsUseCase: clearAiSessionsUseCase,
      ),
    );
    getIt.registerFactory(
      () => WatchSavedFilmsStatusCubit(watchSavedFilmsStatusUseCase),
    );
    getIt.registerLazySingleton(() => FilmImageCacheService());
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> submitQuery(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();
  }

  // Экран ошибки высокий: на дефолтном тестовом окне 800×600 кнопка
  // «Повторить» оказывается ниже фолда. Телефонный размер делает сценарий
  // реалистичным, и кнопка доступна для тапа.
  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('shows the user bubble, skeletons, then the results',
      (tester) async {
    final completer = Completer<List<AiFilmRecommendation>>();

    when(() => useCase(any(), any())).thenAnswer((_) => completer.future);

    await tester.pumpWidget(const MaterialApp(home: AiAssistantScreen()));
    await submitQuery(tester, 'Фильм про ограбление казино');

    expect(find.text('Фильм про ограбление казино'), findsOneWidget);
    expect(find.text('Подбираю фильмы под ваш запрос...'), findsOneWidget);
    expect(find.byKey(const Key('aiSkeletonResults')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(films);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('aiSkeletonResults')), findsNothing);
    expect(find.text('Нашёл 1 фильм.'), findsOneWidget);
    expect(find.text('Одиннадцать друзей Оушена'), findsOneWidget);
    expect(find.text('2001 · Криминал, комедия'), findsOneWidget);
    expect(
      find.text('Команда мастеров готовит ограбление трёх казино.'),
      findsOneWidget,
    );
  });

  testWidgets('keeps the composer empty and ready for the next query',
      (tester) async {
    when(() => useCase(any(), any())).thenAnswer((_) async => films);

    await tester.pumpWidget(const MaterialApp(home: AiAssistantScreen()));
    await submitQuery(tester, 'комедия');
    await tester.pump(const Duration(milliseconds: 300));

    final TextField field = tester.widget<TextField>(find.byType(TextField));

    expect(field.controller?.text, isEmpty);
    expect(find.text('Запрос на поиск фильмов...'), findsOneWidget);
    expect(find.text('0/200'), findsOneWidget);
  });

  testWidgets('shows the failure inline and retries in place', (tester) async {
    usePhoneViewport(tester);
    when(() => useCase(any(), any())).thenThrow(NetworkFailure());

    await tester.pumpWidget(const MaterialApp(home: AiAssistantScreen()));
    await submitQuery(tester, 'комедия');

    expect(
      find.textContaining('Отсутствует интернет-соединение'),
      findsOneWidget,
    );
    expect(find.text('Повторить'), findsOneWidget);
    expect(find.byKey(const Key('aiSkeletonResults')), findsNothing);

    when(() => useCase(any(), any())).thenAnswer((_) async => films);

    await tester.tap(find.text('Повторить'));
    await tester.pump();
    await tester.pump(retryLoadingMinDuration);
    await tester.pump();

    expect(find.text('Повторить'), findsNothing);
    expect(find.text('Нашёл 1 фильм.'), findsOneWidget);
    expect(find.text('Одиннадцать друзей Оушена'), findsOneWidget);
  });

  testWidgets('shows the loading answer while the retry is in flight',
      (tester) async {
    usePhoneViewport(tester);
    var calls = 0;
    final retryCompleter = Completer<List<AiFilmRecommendation>>();

    when(() => useCase(any(), any())).thenAnswer((_) {
      calls++;

      if (calls == 1) {
        throw NetworkFailure();
      }

      return retryCompleter.future;
    });

    await tester.pumpWidget(const MaterialApp(home: AiAssistantScreen()));
    await submitQuery(tester, 'комедия');

    expect(find.text('Что-то пошло не так'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
    expect(find.byKey(const Key('aiSkeletonResults')), findsNothing);

    await tester.tap(find.text('Повторить'));

    // Пока повтор не завершился, на экране та же загрузка, что и при
    // первом запросе: спиннер, строка и скелетоны. Ошибка ушла.
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byKey(const Key('aiSkeletonResults')), findsOneWidget);
      expect(find.text('Подбираю фильмы под ваш запрос...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Что-то пошло не так'), findsNothing);
      expect(find.text('Повторить'), findsNothing);
    }
    expect(calls, 2);

    retryCompleter.complete(films);
    await tester.pump();

    // Минимальная длительность загрузки ещё не истекла.
    expect(find.byKey(const Key('aiSkeletonResults')), findsOneWidget);

    await tester.pump(retryLoadingMinDuration);
    await tester.pump();

    expect(find.byKey(const Key('aiSkeletonResults')), findsNothing);
    expect(find.text('Нашёл 1 фильм.'), findsOneWidget);
    expect(find.text('Что-то пошло не так'), findsNothing);
  });

  testWidgets('shows the loading answer and returns to the error afterwards',
      (tester) async {
    usePhoneViewport(tester);
    var calls = 0;
    final retryCompleter = Completer<List<AiFilmRecommendation>>();

    when(() => useCase(any(), any())).thenAnswer((_) {
      calls++;

      if (calls == 1) {
        throw NetworkFailure();
      }

      return retryCompleter.future;
    });

    await tester.pumpWidget(const MaterialApp(home: AiAssistantScreen()));
    await submitQuery(tester, 'комедия');

    await tester.tap(find.text('Повторить'));
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byKey(const Key('aiSkeletonResults')), findsOneWidget);
    expect(find.text('Повторить'), findsNothing);

    retryCompleter.completeError(NetworkFailure());
    await tester.pump();

    // Загрузка держится ещё минимум `retryLoadingMinDuration`.
    expect(find.byKey(const Key('aiSkeletonResults')), findsOneWidget);
    expect(find.text('Что-то пошло не так'), findsNothing);

    await tester.pump(retryLoadingMinDuration);
    await tester.pump();

    expect(find.byKey(const Key('aiSkeletonResults')), findsNothing);
    expect(find.text('Что-то пошло не так'), findsOneWidget);
    expect(
      find.textContaining('Отсутствует интернет-соединение'),
      findsOneWidget,
    );
    expect(find.text('Повторить'), findsOneWidget);
    expect(
      tester
          .widget<InkWell>(
            find
                .ancestor(
                  of: find.text('Повторить'),
                  matching: find.byType(InkWell),
                )
                .first,
          )
          .onTap,
      isNotNull,
    );
  });

  testWidgets('restores saved sessions when the screen opens', (tester) async {
    when(() => getSessionsUseCase()).thenAnswer(
      (_) async => <AiSession>[session(id: 7, query: 'комедия')],
    );

    await tester.pumpWidget(const MaterialApp(home: AiAssistantScreen()));
    await tester.pump();

    expect(find.text('Нашёл 1 фильм.'), findsOneWidget);
    expect(find.text('комедия'), findsOneWidget);
    expect(find.text('Что хочется посмотреть?'), findsNothing);
  });

  testWidgets('deletes a session from the feed menu', (tester) async {
    when(() => getSessionsUseCase()).thenAnswer(
      (_) async => <AiSession>[
        session(id: 2, query: 'комедия', at: DateTime(2026, 11, 15, 12)),
        session(id: 1, query: 'триллер', at: DateTime(2026, 11, 14, 12)),
      ],
    );

    await tester.pumpWidget(const MaterialApp(home: AiAssistantScreen()));
    await tester.pump();

    // Свёрнутая сессия (вторая в ленте) удаляется через меню на пилюле.
    await tester.tap(find.byIcon(Icons.more_vert).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Удалить сессию'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Удалить'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(verify(() => deleteAiSessionUseCase(1)).callCount, 1);
    expect(find.text('триллер'), findsNothing);
    expect(find.text('комедия'), findsOneWidget);
  });

  testWidgets('clears all sessions from the app bar', (tester) async {
    when(() => getSessionsUseCase()).thenAnswer(
      (_) async => <AiSession>[session(id: 7, query: 'комедия')],
    );

    await tester.pumpWidget(const MaterialApp(home: AiAssistantScreen()));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Очистить'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(verify(() => clearAiSessionsUseCase()).callCount, 1);
    expect(find.text('Что хочется посмотреть?'), findsOneWidget);
  });
}
