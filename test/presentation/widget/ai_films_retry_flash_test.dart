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
import 'package:skeletonizer/skeletonizer.dart';

class _MockGetAiFilmRecommendationsUseCase extends Mock
    implements GetAiFilmRecommendationsUseCase {}

class _MockWatchSavedFilmsStatusUseCase extends Mock
    implements WatchSavedFilmsStatusUseCase {}

void main() {
  late _MockGetAiFilmRecommendationsUseCase useCase;
  late List<Completer<List<AiFilmRecommendation>>> requests;

  setUp(() async {
    await getIt.reset();

    requests = <Completer<List<AiFilmRecommendation>>>[];
    useCase = _MockGetAiFilmRecommendationsUseCase();
    when(() => useCase.call(any())).thenAnswer((_) {
      final completer = Completer<List<AiFilmRecommendation>>();
      requests.add(completer);
      return completer.future;
    });

    final watchUseCase = _MockWatchSavedFilmsStatusUseCase();
    when(() => watchUseCase()).thenAnswer((_) => const Stream.empty());

    getIt.registerFactory(() => AiFilmsBloc(useCase));
    getIt.registerFactory(() => WatchSavedFilmsStatusCubit(watchUseCase));
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets(
    'retry without internet does not flash result skeletons',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AiFilmsScreen()));

      await tester.enterText(find.byType(TextField), 'комедия');
      await tester.pump();

      await tester.tap(find.text('Подобрать'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      // Первая загрузка: заглушки уместны.
      expect(requests, hasLength(1));
      expect(
        find.byWidgetPredicate((widget) => widget is Skeletonizer),
        findsOneWidget,
      );

      requests.first.completeError(NetworkFailure());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.text('Не получилось подобрать'), findsOneWidget);
      expect(find.text('Повторить'), findsOneWidget);

      await tester.tap(find.text('Повторить'));
      await tester.pump();

      // Симптом: на время повторного запроса экран не должен
      // подменяться заглушками — сообщение об ошибке остаётся на месте.
      expect(
        find.byWidgetPredicate((widget) => widget is Skeletonizer),
        findsNothing,
        reason: 'заглушки мелькают при повторном запросе',
      );
      expect(find.text('Не получилось подобрать'), findsOneWidget);
      expect(find.text('Повторить'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );
}
