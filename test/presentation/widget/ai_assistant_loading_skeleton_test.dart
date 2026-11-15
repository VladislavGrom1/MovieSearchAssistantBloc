import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/cache_service/film_image_cache_service.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_ai_film_recommendations_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_saved_films_status_use_case.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_assistant/ai_assistant_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/cubit/watch_saved_films_status_cubit.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/ai_assistant_screen.dart';

class MockGetAiFilmRecommendationsUseCase extends Mock
    implements GetAiFilmRecommendationsUseCase {}

class MockWatchSavedFilmsStatusUseCase extends Mock
    implements WatchSavedFilmsStatusUseCase {}

void main() {
  late MockGetAiFilmRecommendationsUseCase useCase;
  late MockWatchSavedFilmsStatusUseCase watchSavedFilmsStatusUseCase;
  late List<AiFilmRecommendation> films;

  setUp(() async {
    await getIt.reset();

    useCase = MockGetAiFilmRecommendationsUseCase();
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

    when(() => watchSavedFilmsStatusUseCase())
        .thenAnswer((_) => const Stream<Map<int, int?>>.empty());

    getIt.registerFactory(() => AiAssistantBloc(useCase));
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
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Повторить'), findsNothing);
    expect(find.text('Нашёл 1 фильм.'), findsOneWidget);
    expect(find.text('Одиннадцать друзей Оушена'), findsOneWidget);
  });
}
