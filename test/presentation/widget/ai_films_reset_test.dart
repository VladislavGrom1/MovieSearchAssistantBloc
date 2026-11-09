import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_ai_film_recommendations_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_saved_films_status_use_case.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_films/ai_films_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/cubit/watch_saved_films_status_cubit.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/ai_films_screen.dart';

class _MockGetAiFilmRecommendationsUseCase extends Mock
    implements GetAiFilmRecommendationsUseCase {}

class _MockWatchSavedFilmsStatusUseCase extends Mock
    implements WatchSavedFilmsStatusUseCase {}

void main() {
  late _MockGetAiFilmRecommendationsUseCase useCase;

  setUp(() async {
    await getIt.reset();

    useCase = _MockGetAiFilmRecommendationsUseCase();
    when(() => useCase.call(any())).thenAnswer(
      (_) async => const <AiFilmRecommendation>[],
    );

    final watchUseCase = _MockWatchSavedFilmsStatusUseCase();
    when(() => watchUseCase()).thenAnswer((_) => const Stream.empty());

    getIt.registerFactory(() => AiFilmsBloc(useCase));
    getIt.registerFactory(() => WatchSavedFilmsStatusCubit(watchUseCase));
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('в Initial кнопки «Сбросить» нет', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AiFilmsScreen()));

    expect(find.text('С чего начать'), findsOneWidget);
    expect(find.text('Сбросить'), findsNothing);
  });

  testWidgets('после ввода текста «Сбросить» появляется', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AiFilmsScreen()));

    await tester.enterText(find.byType(TextField), 'комедия');
    await tester.pump();

    expect(find.text('Сбросить'), findsOneWidget);
  });

  testWidgets(
    'сброс после ошибки возвращает Initial и чистое поле',
    (tester) async {
      when(() => useCase.call(any())).thenAnswer(
        (_) async => throw NetworkFailure(),
      );

      await tester.pumpWidget(const MaterialApp(home: AiFilmsScreen()));

      await tester.enterText(find.byType(TextField), 'комедия');
      await tester.pump();
      await tester.tap(find.text('Подобрать'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.text('Не получилось подобрать'), findsOneWidget);

      await tester.tap(find.text('Сбросить'));
      await tester.pump();

      expect(find.text('Не получилось подобрать'), findsNothing);
      expect(find.text('С чего начать'), findsOneWidget);
      expect(find.text('Сбросить'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty,
      );
    },
  );

  testWidgets(
    'сброс во время загрузки отбрасывает ответ устаревшего запроса',
    (tester) async {
      final completer = Completer<List<AiFilmRecommendation>>();
      when(() => useCase.call(any())).thenAnswer((_) => completer.future);

      await tester.pumpWidget(const MaterialApp(home: AiFilmsScreen()));

      await tester.enterText(find.byType(TextField), 'комедия');
      await tester.pump();
      await tester.tap(find.text('Подобрать'));
      await tester.pump();

      await tester.tap(find.text('Сбросить'));
      await tester.pump();

      completer.complete(const <AiFilmRecommendation>[]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.text('С чего начать'), findsOneWidget);
      expect(find.text('Ничего не нашлось'), findsNothing);
    },
  );
}
