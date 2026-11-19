# Спека: AiAssistantScreen — режим «Только новое»

Status: ready-for-agent
Дата: 2026-11-15
Дополняет: `.scratch/ai-assistant-feed/spec.md` — лента, композер и карточка результата описаны там; эта спека их не переписывает, а добавляет к ним фильтр по сохранённой библиотеке.

## 1. Задача

`GetAiFilmRecommendationsUseCase` и AI-API уже умеют отсекать фильмы, которые пользователь сохранил в библиотеку: `call(String query, bool onlyNew)` при `onlyNew == true` читает `filmRepository.getSavedIdsAndTitles()` и передаёт воркеру id и оригинальные названия (`lib/domain/usecases/get_ai_film_recommendations_use_case.dart:11-19`). Но экран до этой возможности не дотягивается: BLoC звал use case с одним аргументом, а в UI нечем задать режим.

Нужно:

- в `_loadFilms` передавать `onlyNew` в use case;
- дать пользователю переключатель, который задаёт режим для следующего поиска;
- сохранять выбранный режим в записи поиска, чтобы уже отправленный поиск и его «Повторить» не зависели от текущего положения переключателя.

Режим — **не** вкусовой сигнал и не «только новинки»: он отсекает то, что у пользователя уже есть, и не смотрит на дату выхода (см. `GLOSSARY.md`, «Только новое»).

Решения зафиксированы в [ADR-0006](../../docs/adr/0006-only-new-is-per-search.md).

## 2. Пользовательский сценарий

1. Пользователь открывает экран. В карточке композера, над полем ввода, слева стоит пилюля «Только новое» — выключена: фон `primaryThemeGrey`, рамка `Colors.white.withValues(alpha: 0.12)`, иконка `filter_alt_outlined`. Это стандарт: поиск показывает всё.
2. Тапает по пилюле — она становится акцентной: заливка `primaryScheme`, иконка `check_circle_outline`, текст `textWhite`. Долгое нажатие/ховер показывает подсказку «Не рекомендовать фильмы, которые уже есть в библиотеке».
3. Отправляет запрос — в BLoC уходит `AiAssistantRequested(query, onlyNew: true)`, use case получает `onlyNew: true` и id сохранённых фильмов; воркер исключает их из ответа.
4. Меняет положение переключателя после отправки. Уже отправленный поиск не перезапрашивается и не меняется: переключатель влияет только на следующие запросы. Положение запоминается до конца визита (см. §3).
5. Разворачивает поиск, отправленный в режиме «Только новое». Рядом с датой виден бейдж «Только новое» (`primaryScheme@0.16`, текст `cardAccentText`). Свёрнутые пилюли в ленте не помечаются.
6. Поиск упал с ошибкой. «Повторить» переотправляет его с тем режимом, с которым он был отправлен, а не с текущим положением переключателя.
7. Уходит с экрана — визит заканчивается, следующий вход снова начинается с выключенного переключателя (блок `registerFactory`, лента не персистится).

## 3. Границы

**Входит:**

- `onlyNew` в сущности поиска и в событии отправки; передача в use case;
- переключатель в композере: состояние, внешний вид, доступность (`Semantics(toggled:)`, тултип);
- бейдж режима у развёрнутого поиска;
- защита `getSavedIdsAndTitles()` от закрытого/недоступного Hive-бокса;
- тесты блока, источника данных, репозитория и виджета.

**Не входит:**

- сохранение положения переключателя между визитами и между запусками приложения: блок остаётся `registerFactory`, Hive-настройки не заводятся;
- перезапрос уже отправленных поисков при смене режима;
- отдельный экран настроек и глобальный «режим по умолчанию»;
- изменения на стороне воркера: `onlyNew` он уже принимает;
- пометка свёрнутых пилюль: режим виден только у развёрнутого поиска;
- чипы «Уточнить», ряд подсказок и прочие правки ленты — их по-прежнему описывает `.scratch/ai-assistant-feed/spec.md`.

## 4. API

Контракт не меняется, меняется только значение поля. Тело запроса (`lib/data/data_sources/remote/ai_film_remote_data_source.dart:20-26`):

```json
{
  "query": "фильм про ограбление казино",
  "savedKinopoiskIds": [472, 1234],
  "savedTitles": ["Одиннадцать друзей Оушена", null],
  "onlyNew": true
}
```

- при `onlyNew == false` оба списка пусты: use case не читает хранилище вовсе (это дешевле и не зависит от Hive);
- ошибки источника не меняются: `404` → пустой результат, `502` → «Модель не смогла ответить. Попробуйте позже.», `500` → «Сервис подбора временно недоступен. Попробуйте позже.»;
- если локальное хранилище недоступно, поиск **не падает**: `getSavedIdsAndTitles()` возвращает пустые списки, запрос уходит без фильтра (§6).

## 5. UI

### 5.1 Переключатель в композере

Пилюля «Только новое» — первый ряд карточки композера, над полем ввода:

```
Column(mainAxisSize: min, crossAxisAlignment: start)
  ├─ _OnlyNewToggle
  ├─ SizedBox(10)
  └─ Row(TextField, SizedBox(8), _SendButton)
```

- Контейнер композера не меняется: margin `16, 8, 16, 12`, padding `16, 12, 12, 8`, `primaryThemeGrey`, рамка `white@0.12`, radius 16.
- Выключено: фон `primaryThemeGrey`, рамка `white@0.12`, иконка и текст `textDarkGrey`.
- Включено: фон и рамка `primaryScheme`, иконка и текст `textWhite`.
- Геометрия: padding `12×6`, radius 14, иконка 14, зазор 6, текст `CustomTextStyles.m3FilmTitle`.
- Анимация смены — `AnimatedContainer` 150 мс; тап — через `TapScale(animateOnTap: false)`, чтобы в тестах не ждать задержку нажатия.
- `Key('aiOnlyNewToggle')` — для тестов и виджет-тестов.
- Доступность: `Semantics(toggled: enabled, button: true, label: 'Только новое')`; пояснение — `Tooltip('Не рекомендовать фильмы, которые уже есть в библиотеке')`.
- Виджет stateless: положение хранит `_AiAssistantViewState._onlyNew`, переключатель только сообщает о тапе.

### 5.2 Бейдж развёрнутого поиска

В шапке `_ExpandedSearch` дата и бейдж стоят в одном `Row` по центру:

```
Row(mainAxisAlignment: center)
  ├─ Text('Сегодня, 15:37')
  └─ if (search.onlyNew) ...[ SizedBox(8), _OnlyNewBadge ]
```

Бейдж: `Key('aiOnlyNewBadge')`, padding `8×3`, radius 10, фон `primaryScheme@0.16`, иконка `filter_alt_outlined` 11 и текст «Только новое» цветом `cardAccentText`. Свёрнутая пилюля поиска не меняется.

### 5.3 Стили

Только `AppColors` и `CustomTextStyles`; новых цветов и шрифтов не заводится. `SnackBar`, диалогов и отдельных экранов у режима нет.

## 6. Слои и файлы

### 6.1 Домен

- `lib/domain/entities/ai_film_search.dart:15,23,27` — `final bool onlyNew;` (по умолчанию `false`), входит в `props` после `query`.
- `lib/domain/usecases/get_ai_film_recommendations_use_case.dart:11-16` — без изменений: при `onlyNew == true` читает сохранённые id.
- `lib/domain/repository/film_repository.dart:19` — `getSavedIdsAndTitles()`: одним чтением бокса отдаёт и id, и оригинальные названия.

### 6.2 BLoC

- `lib/presentation/bloc/ai_assistant/ai_assistant_event.dart:16-21` — `AiAssistantRequested(query, {onlyNew = false})`, `props => [query, onlyNew]`.
- `lib/presentation/bloc/ai_assistant/ai_assistant_bloc.dart:37` — `AiFilmSearch(..., onlyNew: event.onlyNew, ...)`.
- `lib/presentation/bloc/ai_assistant/ai_assistant_bloc.dart:118` — `getAiFilmRecommendationsUseCase(search.query, search.onlyNew)`: и первый запрос, и retry читают режим из самой записи, поэтому переключение тумблера их не меняет.
- `lib/presentation/bloc/ai_assistant/ai_assistant_state.dart:64` — геттер `onlyNew` у `AiFilmSearchState` рядом с `query`/`createdAt`.

### 6.3 Данные

- `lib/data/data_sources/remote/ai_film_remote_data_source.dart:13-26` — `getRecommendations(query, onlyNew, savedKinopoiskIds, savedTitles)`, поля `onlyNew`, `savedKinopoiskIds` и `savedTitles` в теле.
- `lib/data/repository_impl/ai_film_repository_impl.dart:11-12` — прокидывает аргументы как есть.
- `lib/data/data_sources/local/flim_local_data_source.dart:70-84` — `getSavedIdsAndTitles()` не бросает исключений: при закрытом боксе (`!Hive.isBoxOpen(HiveStorageKeys.filmDetailModelBox)`) и при `HiveError` возвращает `const (<int>[], <String?>[])`. Названия берутся из `filmBaseModel.nameOriginal` и могут быть `null`. Смысл: недоступное хранилище не должно ломать поиск — лучше показать всё, чем ошибку. Прочие исключения пробрасываются.

### 6.4 Экран

- `lib/presentation/pages/ai_assistant_screen.dart:61,97,104` — `_onlyNew`, `_toggleOnlyNew()`, `AiAssistantRequested(query, onlyNew: _onlyNew)`.
- `:192,619-634,650` — `_Composer` получает `onlyNew` и `onToggleOnlyNew`.
- `:698-756` — `_OnlyNewToggle`; `:759-789` — `_OnlyNewBadge`; `:373-375` — место бейджа.

## 7. Тесты

- `test/presentation/bloc/ai_assistant_bloc_test.dart` — «passes the only-new mode to the use case», «retry reuses the only-new mode of the search», плюс `onlyNew == false` в записи поиска и все стабы на двух аргументах.
- `test/data/ai_film_repository_impl_test.dart` — «пробрасывает режим, сохранённые id и названия в источник».
- `test/data/ai_film_remote_data_source_test.dart` — поля `onlyNew`, `savedKinopoiskIds` и `savedTitles` в теле запроса при `false` (оба списка пусты) и при `true` (непустые id и названия).
- `test/domain/usecases/get_ai_film_recommendations_test.dart` — без режима хранилище не читается, с режимом id и названия уходят в репозиторий.
- `test/presentation/widget/ai_assistant_empty_state_test.dart` — «shows the only-new toggle off by default» и «the toggle sends the next search in the only-new mode».
- Тесты `FilmRepository` на mocktail (`test/domain/usecases/...`) новый метод не ломает.

Прогон: `& .\scripts\agent-flutter.ps1 analyze lib test` и `& .\scripts\agent-flutter.ps1 test` (на момент написания — 126 тестов, зелёные).

## 8. Кодогенерация

Не требуется: новых `@RoutePage()` нет, DI-регистрации не меняются (use case уже получает `filmRepository`).

## 9. Критерии приёмки

1. Переключатель «Только новое» виден в композере и по умолчанию выключен.
2. Тап включает/выключает его, состояние отражается в семантике и подсказке.
3. Следующий запрос уходит в use case с текущим положением переключателя; через `AiAssistantRequested` значение доходит до `getAiFilmRecommendationsUseCase` без потерь.
4. При `onlyNew == true` воркер получает `onlyNew: true` и непустой список сохранённых id; при `false` — `onlyNew: false` и пустой список.
5. Переключение после отправки не меняет уже отправленные поиски; «Повторить» повторяет режим своего поиска.
6. У развёрнутого поиска с `onlyNew == true` виден бейдж; у свёрнутых пилюль и у поисков с `false` его нет.
7. Недоступное локальное хранилище не приводит к ошибке поиска: запрос уходит без фильтра.
8. `analyze lib test` без ошибок; `test` зелёный; `scripts/check_routes_sync.sh` и `scripts/check_vocabulary.sh` проходят.
