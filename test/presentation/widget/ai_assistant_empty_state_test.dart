import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';

import '../../helpers/ai_assistant_test_harness.dart';

void main() {
  late AiAssistantHarness harness;

  setUp(() async {
    harness = AiAssistantHarness();
    await harness.registerInGetIt();
  });

  tearDown(() => harness.resetGetIt());

  testWidgets('shows the empty state without recent queries', (tester) async {
    await harness.pumpScreen(tester);

    expect(find.text('AI Ассистент'), findsOneWidget);
    expect(find.text('Что хочется посмотреть?'), findsOneWidget);
    expect(
      find.text('Опишите настроение, жанр или фильм-ориентир.'),
      findsOneWidget,
    );
    expect(find.text('С чего начать'), findsOneWidget);
    expect(find.text('Добрая комедия на вечер'), findsOneWidget);
    expect(find.text('Аниме про путешествия'), findsOneWidget);
    expect(find.text('Триллер с неожиданной развязкой'), findsOneWidget);
    expect(find.text('Недавние запросы'), findsNothing);
    expect(find.text('0/200'), findsOneWidget);
    expect(find.text('Запрос на поиск фильмов...'), findsOneWidget);
  });

  testWidgets('fills the composer when a start query is tapped',
      (tester) async {
    await harness.pumpScreen(tester);

    await tester.tap(find.text('Аниме про путешествия'));
    await tester.pump();
    // TapScale вызывает onTap с задержкой 200 мс.
    await tester.pump(const Duration(milliseconds: 250));

    final TextField field = tester.widget<TextField>(find.byType(TextField));

    expect(field.controller?.text, 'Аниме про путешествия');
    expect(find.text('21/200'), findsOneWidget);
  });

  testWidgets('does not submit an empty query', (tester) async {
    await harness.pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();

    verifyNever(() => harness.recommendations(any(), any()));
    expect(find.text('Что хочется посмотреть?'), findsOneWidget);
  });

  testWidgets('shows the only-new toggle off by default', (tester) async {
    when(() => harness.recommendations('комедия', false))
        .thenAnswer((_) async => const <AiFilmRecommendation>[]);

    await harness.pumpScreen(tester);

    expect(find.byKey(const Key('aiOnlyNewToggle')), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);

    await tester.enterText(find.byType(TextField), 'комедия');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(() => harness.recommendations('комедия', false)).called(1);
    expect(find.byKey(const Key('aiOnlyNewBadge')), findsNothing);
  });

  testWidgets('the toggle sends the next search in the only-new mode',
      (tester) async {
    when(() => harness.recommendations('комедия', true))
        .thenAnswer((_) async => const <AiFilmRecommendation>[]);

    await harness.pumpScreen(tester);

    await tester.tap(find.byKey(const Key('aiOnlyNewToggle')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'комедия');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(() => harness.recommendations('комедия', true)).called(1);
    expect(find.byKey(const Key('aiOnlyNewBadge')), findsOneWidget);
  });
}
