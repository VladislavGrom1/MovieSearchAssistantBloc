# Спека: сохранение сессий AI-Ассистента

Status: implemented
Дата: 2026-11-18
Обновлено: 2026-11-18 — реализовано: Hive, BLoC, лента, меню, очистка, тесты.
Заменяет: ограничение «лента не персистится» из `.scratch/ai-assistant-feed/spec.md` (§1, §3).

Решение о хранении: [ADR-0007](../../docs/adr/0007-ai-sessions-storage.md).

## 1. Задача

Сейчас `AiAssistantScreen` живёт одним визитом: `AiAssistantBloc` — `registerFactory`, лента AI-поисков умирает при `pop`, и следующий вход начинается с пустого состояния. Нужно сохранять сессии локально, чтобы при перезаходе — в том числе без интернета — пользователь видел историю промптов и рекомендованных фильмов с постерами.

Сессия — это диалог с моделью: сейчас один ход (промпт + рекомендации), но модель данных рассчитана на несколько ходов, потому что следующим шагом подключается модель, умеющая вести диалог.

## 2. Пользовательский сценарий

1. Пользователь отправляет промпт. Пока идёт запрос — загрузка (спиннер, «Подбираю фильмы под ваш запрос...», скелетоны). Пришёл ответ — сессия автоматически сохраняется: промпт, фильмы, описания, постеры.
2. Пришла ошибка — сессия не сохраняется; в памяти она остаётся с сообщением и «Повторить», как раньше.
3. Пользователь уходит с экрана и возвращается (или перезапускает приложение). Лента восстанавливается: сверху — самая свежая сессия, развёрнута она же, остальные — свёрнутые пилюли. Ничего не докачивается из сети.
4. Тап по пилюле разворачивает сессию; тап по фильму открывает `FilmInformationScreen` как обычно (офлайн он покажет свою ошибку).
5. На пилюле и в шапке развёрнутой сессии — меню «Удалить сессию» с подтверждением. В `AppBar` — кнопка «Очистить все сессии» с подтверждением.
6. Больше 20 сессий: при сохранении новой самая старая по `updatedAt` удаляется вместе с папкой постеров.
7. Если постер не скачался, карточка показывает плейсхолдер; при открытии сессии постер заново не запрашивается.

## 3. Границы

**Входит:**

- доменные сущности `AiSession`, `AiSessionTurn`, `AiSessionTurnStatus`;
- Hive-модели сессии, хода и снимка фильма + адаптеры;
- бокс `aiSessionModelBox` в `hive_init.dart` и ключ в `hive_storage_keys.dart`;
- local data source, репозиторий и use cases (get/save/delete/clear);
- гидратация ленты при открытии экрана (событие `AiAssistantHistoryRequested`, состояние `AiAssistantHistoryLoading`);
- автосохранение после успешного ответа (`loaded`/`empty`), лимит 20 с вытеснением;
- удаление сессии и очистка всех сессий с подтверждением;
- постеры сессий в `images/sessions/<sessionId>/<kinopoiskId>/poster.jpg` и категория `sessions` в виджетах постера;
- тесты блока, экрана и виджетов.

**Не входит:**

- продолжение диалога из истории («Повторить»/отправка второго промпта в старую сессию) — модель готова, UI нет;
- включение сессий в `ExportDataModel`/экспорт данных;
- докачивание постеров при открытии сессии;
- изменение `FilmInformationScreen` и его офлайн-поведения;
- миграция `AppConfig.localStorageVersion` — версия хранится полем `schemaVersion` внутри записи;
- история поисков вне AI-Ассистента.

## 4. Модель данных

Hive, бокс `aiSessionModelBox`, ключ — `int` id сессии.

`AiSessionModel` (typeId 5, `currentSchemaVersion = 1`):

- `id` (`@HiveField(0)`);
- `createdAt`, `updatedAt` (`DateTime`);
- `schemaVersion` (`int`);
- `turns` (`List<AiSessionTurnModel>`).

`AiSessionTurnModel` (typeId 6):

- `id`, `query`, `onlyNew`, `createdAt`;
- `status` — строка `loaded` или `empty`;
- `films` — `List<AiFilmSnapshotModel>`.

`AiFilmSnapshotModel` (typeId 7):

- `kinopoiskId`, `nameRu`, `nameOriginal`, `year`, `genres`, `ratingKinopoisk`, `description`;
- `posterPath` — относительный путь от documents, `null` если постер не скачался.

`posterUrl`/`posterUrlPreview` в снимок не попадают: повторная докачка исключена намеренно.

Диск: `images/sessions/<sessionId>/<kinopoiskId>/poster.jpg` (удаляется вместе с сессией и при вытеснении).

## 5. UI

- Вход на экран: `AiAssistantHistoryLoading` — центрированный спиннер; затем лента (новые сверху, раскрыта самая свежая) или пустое состояние, если сессий нет.
- Свёрнутая сессия (`_SearchPill`): запрос, дата и счётчик, в конце `Row` — `PopupMenuButton` с пунктом «Удалить сессию».
- Развёрнутая сессия: шапка — дата по центру, справа в `Stack` то же меню; ниже — пузырь промпта, ответ и карточки.
- `AppBar.actions`: `IconButton(Icons.delete_sweep_outlined)` с подсказкой «Очистить все сессии», видна только когда лента не пуста.
- Оба удаления идут через `ConfirmAlertDialog` («Удалить сессию?» / «Очистить все сессии?»).
- Постер в карточке — `FilmPosterWithLibraryStatus(localImagePath: film.localPosterImagePath, localImageCategory: 'sessions')`; без локального файла — обычный `CachedNetworkImage`-плейсхолдер.
- Ошибка API — прежнее поведение: сообщение и «Повторить»; сессия не сохраняется.

## 6. Слои и файлы

- `lib/domain/entities/ai_session.dart` — `AiSession`, `AiSessionTurn`, `AiSessionTurnStatus`.
- `lib/data/models/ai_session_model.dart` (+ `.g.dart`) — Hive-модели и адаптеры.
- `lib/data/data_sources/local/ai_session_local_data_source.dart` — бокс, лимит `maxSessions = 20`, сортировка, вытеснение.
- `lib/domain/repository/ai_session_repository.dart`, `lib/data/repository_impl/ai_session_repository_impl.dart` — постеры и папки, вытеснение.
- `lib/domain/usecases/{get,save,delete,clear}_ai_session(s)_use_case.dart`.
- `lib/data/data_sources/local/image_storage_service.dart` — `saveSessionPoster`, `deleteSessionImages`, `deleteAllSessionImages`.
- `lib/presentation/bloc/ai_assistant/ai_assistant_bloc.dart` — гидратация, сохранение, удаление, очистка, id по времени, новые сессии сверху.
- `lib/presentation/pages/ai_assistant_screen.dart` — `AiAssistantHistoryLoading`, меню, очистка, удаление.
- `lib/presentation/pages/widgets/film_poster_image.dart`, `film_poster_with_library_status.dart`, `ai_film_result_card.dart` — категория постера.
- `lib/injection_container.dart` — data source, репозиторий, use cases, 5 аргументов `AiAssistantBloc`.

## 7. Тесты

- `test/presentation/bloc/ai_assistant_bloc_test.dart` — сохранение после `loaded`/`empty`, отсутствие сохранения при ошибке, гидратация, удаление, очистка, лимит 20 (новый поиск первым, старейший вытеснен).
- `test/presentation/widget/ai_assistant_loading_skeleton_test.dart` — восстановление сессий при открытии, удаление из меню пилюли, очистка из `AppBar`, прежние сценарии загрузки/повтора.
- `test/presentation/widget/ai_assistant_empty_state_test.dart` — пустое состояние при отсутствии истории.
- Тест модели `ai_session_model.dart` — маппинг полей и `schemaVersion` (при добавлении моделей).

## 8. Критерии приёмки

1. После ответа сессия сохраняется: повторный вход показывает её в ленте без сети.
2. Сессия с ошибкой не сохраняется; после «Повторить» и успеха — сохраняется.
3. Постеры читаются из `images/sessions/...`; при `posterPath = null` показывается плейсхолдер и ничего не докачивается.
4. Удаление сессии убирает её из ленты, из Hive и с диска; после удаления последней — пустое состояние.
5. «Очистить все сессии» очищает бокс и папки, экран возвращается к пустому состоянию.
6. Больше 20 сессий не хранится: вытесняется самая старая по `updatedAt`, её папка удаляется.
7. Сессии не попадают в экспорт, `AppConfig.localStorageVersion` не меняется.
8. `flutter analyze` без новых замечаний, все тесты зелёные.
