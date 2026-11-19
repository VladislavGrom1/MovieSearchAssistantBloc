// Общий стенд тестов AI-Ассистента.
//
// Экран `AiAssistantScreen` собирает зависимости из `getIt`, поэтому каждый
// виджет-тест повторял одну и ту же регистрацию: блок с пятью use case,
// кубит статусов, кэш постеров, моки и дефолтные стабы. Здесь это одна точка.
//
// Два правила, ради которых стенд существует:
//
// * `usePhoneViewport` — на дефолтном окне теста 800×600 кнопка «Повторить»
//   уходит ниже фолда: `errorIcon.png` 1024×1024 рендерится в 350 px, и блок
//   ошибки выше 600 px. На телефоне 430×932 сценарий реалистичен.
// * `pumpFor` вместо `pumpAndSettle` — плейсхолдеры постеров
//   (`CachedNetworkImage` + `Skeletonizer`/`Shimmer`) анимируются бесконечно,
//   и `pumpAndSettle` не дожидается остановки. Ограниченный pump продвигает
//   время на длительность анимации и возвращает управление.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/cache_service/film_image_cache_service.dart';
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

class MockDeleteAiSessionUseCase extends Mock
    implements DeleteAiSessionUseCase {}

class MockClearAiSessionsUseCase extends Mock
    implements ClearAiSessionsUseCase {}

class MockWatchSavedFilmsStatusUseCase extends Mock
    implements WatchSavedFilmsStatusUseCase {}

/// Моки и дефолтные стабы для AI-Ассистента.
///
/// Блок-тесты создают стенд в `setUp` и зовут [buildBloc]; виджет-тесты
/// дополнительно ждут [registerInGetIt], рисуют экран через [pumpScreen]
/// и убирают за собой [resetGetIt] в `tearDown`.
class AiAssistantHarness {
  AiAssistantHarness({DateTime? now})
      : now = now ?? DateTime(2026, 11, 14, 15, 30) {
    recommendations = MockGetAiFilmRecommendationsUseCase();
    sessions = MockGetAiSessionsUseCase();
    saveSession = MockSaveAiSessionUseCase();
    deleteSession = MockDeleteAiSessionUseCase();
    clearSessions = MockClearAiSessionsUseCase();
    watchStatus = MockWatchSavedFilmsStatusUseCase();

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

    // `saveSession` принимает AiSession, поэтому mocktail нужен образец.
    registerFallbackValue(session(id: 0, query: '', turns: const []));

    when(() => sessions()).thenAnswer((_) async => const <AiSession>[]);
    when(() => saveSession(any())).thenAnswer((_) async {});
    when(() => deleteSession(any())).thenAnswer((_) async {});
    when(() => clearSessions()).thenAnswer((_) async {});
    when(() => watchStatus())
        .thenAnswer((_) => const Stream<Map<int, int?>>.empty());
  }

  /// Время, от которого строятся поиски и сессии в тестах.
  final DateTime now;

  late final MockGetAiFilmRecommendationsUseCase recommendations;
  late final MockGetAiSessionsUseCase sessions;
  late final MockSaveAiSessionUseCase saveSession;
  late final MockDeleteAiSessionUseCase deleteSession;
  late final MockClearAiSessionsUseCase clearSessions;
  late final MockWatchSavedFilmsStatusUseCase watchStatus;

  /// Один фильм, который возвращают стабы по умолчанию.
  late final List<AiFilmRecommendation> films;

  /// Блок с моками стенда — для `blocTest`.
  AiAssistantBloc buildBloc() {
    return AiAssistantBloc(
      getAiFilmRecommendationsUseCase: recommendations,
      getAiSessionsUseCase: sessions,
      saveAiSessionUseCase: saveSession,
      deleteAiSessionUseCase: deleteSession,
      clearAiSessionsUseCase: clearSessions,
    );
  }

  /// Регистрирует зависимости экрана в `getIt`.
  Future<void> registerInGetIt() async {
    await getIt.reset();
    getIt.registerFactory(buildBloc);
    getIt.registerFactory(() => WatchSavedFilmsStatusCubit(watchStatus));
    getIt.registerLazySingleton(() {
      // Каталоги не создаются: тесту достаточно путей, а `path_provider`
      // в виджет-тестах недоступен.
      final root = Directory('${Directory.systemTemp.path}/ai_harness');
      return FilmImageCacheService(
        cacheRoot: Directory('${root.path}/filmImageCache'),
        supportRoot: root,
      );
    });
  }

  /// Чистит `getIt` после виджет-теста.
  Future<void> resetGetIt() => getIt.reset();

  /// Рисует `AiAssistantScreen` и даёт отработать запросу истории.
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AiAssistantScreen()));
    await tester.pump();
  }

  /// Сохранённая сессия для стаба [sessions].
  AiSession session({
    required int id,
    required String query,
    AiSessionTurnStatus status = AiSessionTurnStatus.loaded,
    List<AiFilmRecommendation>? films,
    List<AiSessionTurn>? turns,
    DateTime? at,
  }) {
    final DateTime moment = at ?? now;

    return AiSession(
      id: id,
      createdAt: moment,
      updatedAt: moment,
      turns: turns ??
          <AiSessionTurn>[
            AiSessionTurn(
              search: AiFilmSearch(id: id, query: query, createdAt: moment),
              status: status,
              films: films ?? this.films,
            ),
          ],
    );
  }
}

/// Телефонный вьюпорт: ошибка на экране выше дефолтного окна 800×600.
void usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Продвигает время на [duration] без ожидания полной остановки анимаций.
///
/// Замена `pumpAndSettle`: шиммеры постеров не останавливаются никогда.
Future<void> pumpFor(
  WidgetTester tester, [
  Duration duration = const Duration(milliseconds: 400),
]) async {
  await tester.pump();
  await tester.pump(duration);
}
