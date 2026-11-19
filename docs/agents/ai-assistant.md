# AI-Ассистент

Карта подсистемы: где живёт экран, как идут события, что и где сохраняется.
Читай перед правкой `AiAssistantScreen` или `AiAssistantBloc`.

## Поток

`AiAssistantScreen` (`@RoutePage`) → `MultiBlocProvider(AiAssistantBloc, WatchSavedFilmsStatusCubit)` → `_AiAssistantView`.

- `initState` добавляет `AiAssistantHistoryRequested`: блок эмитит `AiAssistantHistoryLoading`, читает сессии из Hive и отдаёт `AiAssistantFeed` (новые сверху, раскрыта самая свежая) или `AiAssistantInitial`.
- Новый промпт — `AiAssistantRequested`: поиск встаёт в начало ленты (`AiFilmSearchLoading`) → API → `AiFilmSearchLoaded`/`AiFilmSearchEmpty`; после успеха сессия сохраняется в Hive, ошибка не сохраняется.
- `AiAssistantRetryRequested` возвращает упавший поиск в `AiFilmSearchLoading` минимум на `retryLoadingMinDuration` (400 мс, `lib/app/util/constants/retry_loading.dart`) — без этого быстрый ответ мелькает скелетонами.
- `AiAssistantSessionDeleteRequested` и `AiAssistantSessionsClearRequested` — удаление и очистка; оба подтверждаются `ConfirmAlertDialog` в UI.

## Состояния и события

- `lib/presentation/bloc/ai_assistant/ai_assistant_state.dart`: `AiAssistantInitial`, `AiAssistantHistoryLoading`, `AiAssistantFeed(searches, expandedSearchId)`; sealed `AiFilmSearchState` → `AiFilmSearchLoading` | `AiFilmSearchLoaded(films)` | `AiFilmSearchEmpty` | `AiFilmSearchFailure(message)`.
- `ai_assistant_event.dart`: шесть событий из списка выше.
- Новое состояние поиска: класс + ветка в `switch` внутри `_SearchAnswer` и в `_searchCountLabel` (`ai_assistant_screen.dart`).

## Рендер

- `_Feed` — `ListView.separated`: раскрытая сессия `_ExpandedSearch`, остальные — `_SearchPill` с меню `_SessionMenu`.
- `_SearchAnswer` — диспетчер состояния поиска: `_LoadingAnswer` (спиннер + «Подбираю фильмы под ваш запрос...» + `_SkeletonResults` с ключом `aiSkeletonResults`), `_LoadedAnswer` (`AiFilmResultCard`), `_PlainAnswer`, `_SearchFailureWidget`.
- Ошибка в ленте — локальный `_SearchFailureWidget`, а не общий `ErrorMessageWidget`: общий оборачивает контент в `SingleChildScrollView`, а ошибка живёт внутри скроллящейся ленты.
- Постеры: `AiFilmResultCard` передаёт `localImagePath` и `localImageCategory: 'sessions'` в `FilmPosterWithLibraryStatus` (у библиотеки категория по умолчанию — `films`).

## Хранение

- Hive-бокс `aiSessionModelBox`; модели `AiSessionModel` / `AiSessionTurnModel` / `AiFilmSnapshotModel` (typeId 5/6/7, адаптеры написаны вручную) — `lib/data/models/ai_session_model.dart`.
- Постеры — файлами: `images/sessions/<sessionId>/<kinopoiskId>/poster.jpg` (`ImageStorageService.saveSessionPoster`).
- id сессии — секунды epoch: Hive принимает int-ключи только до `0xFFFFFFFF`.
- Слои: `AiSessionLocalDataSource` → `AiSessionRepositoryImpl` → `Get/Save/Delete/ClearAiSession(s)UseCase` → `AiAssistantBloc`; регистрация — `lib/injection_container.dart`.

## Тесты

- `test/presentation/bloc/ai_assistant_bloc_test.dart` — события и состояния блока.
- `test/presentation/widget/ai_assistant_loading_skeleton_test.dart` — загрузка, скелетоны, повтор, меню сессий.
- `test/presentation/widget/ai_assistant_empty_state_test.dart` — пустое состояние и композер.
- `test/data/ai_session_model_test.dart` — round-trip моделей на реальном Hive-боксе.
- Общий стенд: `test/helpers/ai_assistant_test_harness.dart` (`usePhoneViewport`, `pumpFor`, моки и стабы).

## Спеки и ADR

- `.scratch/ai-assistant-feed/spec.md` — лента, композер, состояния.
- `.scratch/ai-sessions/spec.md` — сохранение сессий.
- `docs/adr/0007-ai-sessions-storage.md` — почему Hive и постеры файлами.
