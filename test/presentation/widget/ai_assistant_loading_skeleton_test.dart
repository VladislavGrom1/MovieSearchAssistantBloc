import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/retry_loading.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_session.dart';

import '../../helpers/ai_assistant_test_harness.dart';

void main() {
  late AiAssistantHarness harness;

  setUp(() async {
    harness = AiAssistantHarness();
    await harness.registerInGetIt();
  });

  tearDown(() => harness.resetGetIt());

  Future<void> submitQuery(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();
  }

  testWidgets('shows the user bubble, skeletons, then the results',
      (tester) async {
    final completer = Completer<List<AiFilmRecommendation>>();
    when(() => harness.recommendations(any(), any()))
        .thenAnswer((_) => completer.future);

    await harness.pumpScreen(tester);
    await submitQuery(tester, 'Фильм про ограбление казино');

    expect(find.text('Фильм про ограбление казино'), findsOneWidget);
    expect(find.text('Подбираю фильмы под ваш запрос...'), findsOneWidget);
    expect(find.byKey(const Key('aiSkeletonResults')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(harness.films);
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
    when(() => harness.recommendations(any(), any()))
        .thenAnswer((_) async => harness.films);

    await harness.pumpScreen(tester);
    await submitQuery(tester, 'комедия');
    await tester.pump(const Duration(milliseconds: 300));

    final TextField field = tester.widget<TextField>(find.byType(TextField));

    expect(field.controller?.text, isEmpty);
    expect(find.text('Запрос на поиск фильмов...'), findsOneWidget);
    expect(find.text('0/200'), findsOneWidget);
  });

  testWidgets('shows the failure inline and retries in place', (tester) async {
    usePhoneViewport(tester);
    when(() => harness.recommendations(any(), any())).thenThrow(NetworkFailure());

    await harness.pumpScreen(tester);
    await submitQuery(tester, 'комедия');

    expect(
      find.textContaining('Отсутствует интернет-соединение'),
      findsOneWidget,
    );
    expect(find.text('Повторить'), findsOneWidget);
    expect(find.byKey(const Key('aiSkeletonResults')), findsNothing);

    when(() => harness.recommendations(any(), any()))
        .thenAnswer((_) async => harness.films);

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

    when(() => harness.recommendations(any(), any())).thenAnswer((_) {
      calls++;

      if (calls == 1) {
        throw NetworkFailure();
      }

      return retryCompleter.future;
    });

    await harness.pumpScreen(tester);
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

    retryCompleter.complete(harness.films);
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

    when(() => harness.recommendations(any(), any())).thenAnswer((_) {
      calls++;

      if (calls == 1) {
        throw NetworkFailure();
      }

      return retryCompleter.future;
    });

    await harness.pumpScreen(tester);
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
    when(() => harness.sessions()).thenAnswer(
      (_) async => <AiSession>[harness.session(id: 7, query: 'комедия')],
    );

    await harness.pumpScreen(tester);

    expect(find.text('Нашёл 1 фильм.'), findsOneWidget);
    expect(find.text('комедия'), findsOneWidget);
    expect(find.text('Что хочется посмотреть?'), findsNothing);
  });

  testWidgets('deletes a session from the feed menu', (tester) async {
    when(() => harness.sessions()).thenAnswer(
      (_) async => <AiSession>[
        harness.session(id: 2, query: 'комедия', at: DateTime(2026, 11, 15, 12)),
        harness.session(id: 1, query: 'триллер', at: DateTime(2026, 11, 14, 12)),
      ],
    );

    await harness.pumpScreen(tester);

    // Свёрнутая сессия (вторая в ленте) удаляется через меню на пилюле.
    await tester.tap(find.byIcon(Icons.more_vert).last);
    await pumpFor(tester);
    await tester.tap(find.text('Удалить сессию'));
    await pumpFor(tester);
    await tester.tap(find.text('Удалить'));
    await pumpFor(tester);

    expect(verify(() => harness.deleteSession(1)).callCount, 1);
    expect(find.text('триллер'), findsNothing);
    expect(find.text('комедия'), findsOneWidget);
  });

  testWidgets('clears all sessions from the app bar', (tester) async {
    when(() => harness.sessions()).thenAnswer(
      (_) async => <AiSession>[harness.session(id: 7, query: 'комедия')],
    );

    await harness.pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
    await pumpFor(tester);
    await tester.tap(find.text('Очистить'));
    await pumpFor(tester);

    expect(verify(() => harness.clearSessions()).callCount, 1);
    expect(find.text('Что хочется посмотреть?'), findsOneWidget);
  });
}
