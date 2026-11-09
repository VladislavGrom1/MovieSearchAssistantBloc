# 04. `AiFilmsBloc`: события, состояния и тесты

Status: ready-for-agent
Type: task
Blocked by: 03

## Контекст

Спека: `.scratch/ai-tab/spec.md`, раздел 6.4. Стиль — `lib/presentation/bloc/searched_films/` (sealed + Equatable + `part`-файлы, без freezed).

## Что сделать

- [ ] `lib/presentation/bloc/ai_films/ai_films_event.dart`:
      ```dart
      sealed class AiFilmsEvent extends Equatable { ... }

      final class AiFilmsRequested extends AiFilmsEvent {
        final String query;
        const AiFilmsRequested(this.query);
        @override
        List<Object?> get props => [query];
      }

      final class AiFilmsRetryRequested extends AiFilmsEvent { ... }
      ```
- [ ] `lib/presentation/bloc/ai_films/ai_films_state.dart`:
      ```dart
      sealed class AiFilmsState extends Equatable { final String? query; }

      final class AiFilmsInitial extends AiFilmsState { const AiFilmsInitial(); }
      final class AiFilmsLoading extends AiFilmsState { const AiFilmsLoading({String? query}); }
      final class AiFilmsLoaded extends AiFilmsState {
        final List<AiFilmRecommendation> recommendations;
      }
      final class AiFilmsEmpty extends AiFilmsState { ... }
      final class AiFilmsFailure extends AiFilmsState { final String message; }
      ```
      Все не-начальные состояния несут последний `query` для «Повторить».
- [ ] `lib/presentation/bloc/ai_films/ai_films_bloc.dart`: конструктор `AiFilmsBloc(this._useCase)`, `on<AiFilmsRequested>` и `on<AiFilmsRetryRequested>`.
- [ ] `AiFilmsRequested`: `query.trim()`; пустой — игнор (страховка к disabled-кнопке). Дальше `AiFilmsLoading(query:)` → `Loaded` или `Empty`.
- [ ] `AiFilmsRetryRequested`: берёт `query` из текущего состояния, без запроса — игнор.
- [ ] Ошибки: `RemoteDataSourceException` → `AiFilmsFailure(message: e.message)`; прочее → `AiFilmsFailure(message: "Неизвестная ошибка. Попробуйте ещё раз.")`.
- [ ] Повторный запрос во время загрузки: старые результаты не эмитятся, эмиты после закрытия блока игнорируются (`if (isClosed) return;`).
- [ ] Тесты `test/presentation/bloc/ai_films_bloc_test.dart` (`bloc_test` + `mocktail`, мок use case):
      - `Requested` → `[Loading, Loaded]` с 5 рекомендациями;
      - use case бросает `AiServiceFailure` → `Failure` с её текстом;
      - пустой список → `Empty`;
      - `RetryRequested` после `Failure` вызывает use case с исходным `query`;
      - `RetryRequested` в `Initial` не вызывает use case;
      - пустой/пробельный `Requested` не вызывает use case.

## Критерии готовности

- `flutter test test/presentation/bloc/ai_films_bloc_test.dart` — зелёный.
- В `injection_container.dart` добавлен `registerFactory(() => AiFilmsBloc(getIt()))`.

## Comments

- Реализовано (2026-11-09): `AiFilmsBloc` + events/states, retry переиспользует `state.query`. Тесты: `test/presentation/bloc/ai_films_bloc_test.dart` — 8 зелёных.
