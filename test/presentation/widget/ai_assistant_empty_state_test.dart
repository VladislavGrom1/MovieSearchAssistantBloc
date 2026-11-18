import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_session.dart';
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

class MockWatchSavedFilmsStatusUseCase extends Mock
    implements WatchSavedFilmsStatusUseCase {}

class MockGetAiSessionsUseCase extends Mock implements GetAiSessionsUseCase {}

class MockSaveAiSessionUseCase extends Mock implements SaveAiSessionUseCase {}

class MockDeleteAiSessionUseCase extends Mock implements DeleteAiSessionUseCase {}

class MockClearAiSessionsUseCase extends Mock implements ClearAiSessionsUseCase {}

void main() {
  late MockGetAiFilmRecommendationsUseCase useCase;
  late MockGetAiSessionsUseCase getSessionsUseCase;
  late MockSaveAiSessionUseCase saveAiSessionUseCase;
  late MockDeleteAiSessionUseCase deleteAiSessionUseCase;
  late MockClearAiSessionsUseCase clearAiSessionsUseCase;
  late MockWatchSavedFilmsStatusUseCase watchSavedFilmsStatusUseCase;

  final DateTime now = DateTime(2026, 11, 14, 15, 30);

  setUp(() async {
    await getIt.reset();

    useCase = MockGetAiFilmRecommendationsUseCase();
    getSessionsUseCase = MockGetAiSessionsUseCase();
    saveAiSessionUseCase = MockSaveAiSessionUseCase();
    deleteAiSessionUseCase = MockDeleteAiSessionUseCase();
    clearAiSessionsUseCase = MockClearAiSessionsUseCase();
    watchSavedFilmsStatusUseCase = MockWatchSavedFilmsStatusUseCase();

    registerFallbackValue(
      AiSession(
        id: 0,
        createdAt: now,
        updatedAt: now,
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
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('shows the empty state without recent queries', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AiAssistantScreen()));
    await tester.pump();

    expect(find.text('AI-Ассистент'), findsOneWidget);
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
    await tester.pumpWidget(const MaterialApp(home: AiAssistantScreen()));
    await tester.pump();

    await tester.tap(find.text('Аниме про путешествия'));
    await tester.pump();
    // TapScale вызывает onTap с задержкой 200 мс.
    await tester.pump(const Duration(milliseconds: 250));

    final TextField field = tester.widget<TextField>(find.byType(TextField));

    expect(field.controller?.text, 'Аниме про путешествия');
    expect(find.text('21/200'), findsOneWidget);
  });

  testWidgets('does not submit an empty query', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AiAssistantScreen()));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();

    verifyNever(() => useCase(any(), any()));
    expect(find.text('Что хочется посмотреть?'), findsOneWidget);
  });

  testWidgets('shows the only-new toggle off by default', (tester) async {
    when(() => useCase('комедия', false))
        .thenAnswer((_) async => const <AiFilmRecommendation>[]);

    await tester.pumpWidget(const MaterialApp(home: AiAssistantScreen()));
    await tester.pump();

    expect(find.byKey(const Key('aiOnlyNewToggle')), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);

    await tester.enterText(find.byType(TextField), 'комедия');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(() => useCase('комедия', false)).called(1);
    expect(find.byKey(const Key('aiOnlyNewBadge')), findsNothing);
  });

  testWidgets('the toggle sends the next search in the only-new mode',
      (tester) async {
    when(() => useCase('комедия', true))
        .thenAnswer((_) async => const <AiFilmRecommendation>[]);

    await tester.pumpWidget(const MaterialApp(home: AiAssistantScreen()));
    await tester.pump();

    await tester.tap(find.byKey(const Key('aiOnlyNewToggle')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'комедия');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(() => useCase('комедия', true)).called(1);
    expect(find.byKey(const Key('aiOnlyNewBadge')), findsOneWidget);
  });
}
