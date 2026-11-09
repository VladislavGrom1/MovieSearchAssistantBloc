# 03. Репозиторий, use case и регистрация в DI

Status: ready-for-agent
Type: task
Blocked by: 02

## Контекст

Спека: `.scratch/ai-tab/spec.md`, раздел 6.6. Стиль именования — как у `film_repository.dart` / `get_similar_films_use_case.dart`.

## Что сделать

- [ ] `lib/domain/repository/ai_film_repository.dart`:
      ```dart
      abstract class AiFilmRepository {
        Future<List<AiFilmRecommendation>> getRecommendations(String query);
      }
      ```
- [ ] `lib/data/repository_impl/ai_film_repository_impl.dart`: принимает `AiFilmRemoteDataSource`, маппит модели в сущности через `toEntity()`.
- [ ] `lib/domain/usecases/get_ai_film_recommendations_use_case.dart`: `class GetAiFilmRecommendationsUseCase { Future<List<AiFilmRecommendation>> call(String query) }`, принимает `AiFilmRepository`.
- [ ] `lib/injection_container.dart`, в `initializeDependencies()` рядом с `FilmRemoteDataSource` (`:127`):
      ```dart
      getIt.registerLazySingleton(() => AiFilmRemoteDataSource(dio: getIt()));
      getIt.registerLazySingleton<AiFilmRepository>(() => AiFilmRepositoryImpl(getIt()));
      getIt.registerLazySingleton(() => GetAiFilmRecommendationsUseCase(getIt()));
      getIt.registerFactory(() => AiFilmsBloc(getIt()));
      ```
      Последняя строка появится вместе с тикетом 04 — если BLoC ещё не создан, добавить остальные три.
- [ ] Тест `test/data/ai_film_repository_impl_test.dart`: пустой список моделей → пустой список сущностей, `description` пробрасывается без изменений.

## Критерии готовности

- `flutter test` по затронутым тестам зелёный.
- `getIt<GetAiFilmRecommendationsUseCase>()` резолвится без ошибок в тесте DI (или ручной проверкой `initializeDependencies`).

## Comments

- Реализовано (2026-11-09): `AiFilmRepository`/`AiFilmRepositoryImpl`/`GetAiFilmRecommendationsUseCase`, регистрация в `lib/injection_container.dart`. Тесты: `test/data/ai_film_repository_impl_test.dart` — 2 зелёных.
