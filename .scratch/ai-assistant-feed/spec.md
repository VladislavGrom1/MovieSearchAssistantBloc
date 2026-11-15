# Спека: AiAssistantScreen — лента AI-поисков

Status: implemented
Дата: 2026-11-14
Обновлено: 2026-11-15 — сверено с кодом после переезда экрана и добавления режима «Только новое».
Заменяет: `.scratch/ai-tab/spec.md` (описывал AI как четвёртую вкладку и запрещал историю).

Режим «Только новое» описан отдельно: `.scratch/only-new/spec.md` и [ADR-0006](../../docs/adr/0006-only-new-is-per-search.md). Здесь он упоминается только там, где меняет раскладку экрана.

## 1. Задача

`AiAssistantScreen` — мессенджероподобная лента AI-поисков: запрос уходит пузырём вправо, ответ приходит строкой ассистента, ниже — карточки фильмов, а прошлые поиски сворачиваются в пилюли над развёрнутым. Раньше экран был формой «ввёл запрос → получил один список фильмов» с полем ввода сверху.

Экран открывается пушем с вкладки поиска (`CustomSearchBar`, иконка `auto_awesome`, `lib/app/router/navigation_tabs/search_film/search_film_routes.dart:12`), а не вкладкой.

Лента не персистится: блок остаётся `registerFactory` (`lib/injection_container.dart`), умирает вместе с `pop`, и новый визит начинается с пустого состояния. Это зафиксированное ограничение, а не недоработка; персистентность — следующая итерация (см. §3).

## 2. Пользовательский сценарий

1. Пользователь открывает экран. Ленты нет → заголовок «Что хочется посмотреть?», подпись «Опишите настроение, жанр или фильм-ориентир.», блок «С чего начать» с шестью готовыми запросами и композер снизу. В композере, над полем ввода, — выключенный переключатель «Только новое».
2. Тапает по пилюле «Фильмы про ограбления банков» — текст подставляется в поле, фокус переходит в него, клавиатура открывается; запрос не отправляется.
3. Отправляет запрос. Композер очищается, фокус снимается; в ленте появляется развёрнутый поиск: дата («Сегодня, 15:37»), фиолетовый пузырь с запросом справа, строка ассистента «Подбираю фильмы под ваш запрос...» и пять скелетонов карточек.
4. Приходит ответ: вместо спиннера — «Нашёл 5 фильмов.» и горизонтальные карточки. Ряда «Уточнить:» нет — чипы в этой итерации не реализованы.
5. Вводит второй запрос. Первый поиск сворачивается в пилюлю (запрос слева, «Сегодня, 15:12 · 5 фильмов» справа), второй разворачивается ниже. Тап по пилюле разворачивает тот поиск и сворачивает текущий.
6. Тап по карточке фильма → `FilmInformationRoute` (как в поиске).
7. Уход с экрана уничтожает ленту и положение переключателя: следующий вход снова начинается с пустого состояния.

## 3. Границы

**Входит:**

- layout экрана: пустое состояние, лента поисков, композер снизу;
- состояние-лента в BLoC: список поисков, какой развёрнут, у какого идёт загрузка;
- сворачивание/разворачивание поисков (аккордеон внутри визита), лимит 20;
- горизонтальная карточка результата со строкой «год · жанры» и описанием;
- `genres` из ответа воркера в `FilmEntity.genres`;
- 404 от воркера = пустой результат, а не ошибка;
- инлайновые ошибки с «Повторить»;
- скелетоны формы карточки;
- форматтеры относительной даты и строки «год · жанры»;
- переключатель «Только новое» в композере и бейдж режима у развёрнутого поиска.

**Не входит:**

- сохранение ленты между перезаходами и между запусками: блок остаётся `registerFactory`, никакого `lazySingleton`, `AutomaticKeepAliveClientMixin`, `IndexedStack` или `PageStorageKey`;
- Hive-хранилище поисков, а значит и секция «Недавние запросы»;
- чипы «Уточнить: Новее · Короче · Без жестокости» из макета — не реализованы вовсе (ни виджета, ни ряда);
- кнопка отмены запроса;
- оффлайн-кэш и повторная отправка при восстановлении сети;
- изменение эндпоинта, репозитория и use case помимо параметров `onlyNew`/`savedKinopoiskIds`/`savedTitles`;
- локализация — тексты остаются русскими строками в коде, как во всём приложении.

## 4. API

Эндпоинт: `POST https://ai-movie-assistant.vladislav-vaganov-dev.workers.dev/` (`lib/data/data_sources/remote/ai_film_remote_data_source.dart:6`), тело:

```json
{
  "query": "фильм про ограбление казино",
  "savedKinopoiskIds": [],
  "savedTitles": [],
  "onlyNew": false
}
```

`query` ≤ 200 символов; `savedKinopoiskIds` и `savedTitles` пусты, пока режим «Только новое» выключен (тогда use case вообще не читает хранилище); `onlyNew` — положение переключателя на момент отправки. `savedTitles` — оригинальные названия сохранённых фильмов (`FilmDetailModel.filmBaseModel.nameOriginal`), могут содержать `null`; воркер использует их вместе с id, чтобы не рекомендовать то, что уже есть в библиотеке.

Ответ — объект с `movies`; в объекте фильма есть поле `genres`:

```json
{
  "movies": [
    {
      "nameEn": "Ocean's Eleven",
      "nameRu": "Одиннадцать друзей Оушена",
      "year": 2001,
      "reason": "Команда мастеров готовит ограбление сразу трёх казино Лас-Вегаса...",
      "kinopoiskId": 472,
      "posterUrl": "https://...",
      "rating": "8.1",
      "genres": [{ "genre": "криминал" }, { "genre": "комедия" }]
    }
  ]
}
```

`genres` — массив объектов с единственным ключом `genre`; элементы могут отсутствовать или приходить пустым массивом. Парсинг переживает и массив строк (на случай, если воркер вернётся к простому виду).

Ошибки (`_mapError`):

| Код / причина | Поведение |
| --- | --- |
| 404 | **пустой результат**, не ошибка: `getRecommendations` возвращает `const []` |
| 502 | `AiServiceFailure('Модель не смогла ответить. Попробуйте позже.')` |
| 400 / 405 / 500 | `AiServiceFailure('Сервис подбора временно недоступен. Попробуйте позже.')` |
| тело с `error` | текст сервера как есть |
| нет сети / `connectionTimeout` / `sendTimeout` | `NetworkFailure` → «Отсутствует интернет-соединение. Проверьте подключение к интернету и попробуйте снова.» |
| `receiveTimeout` | `ServerFailure` |

Недоступное локальное хранилище (закрытый Hive-бокс, `HiveError`) не ломает поиск: `getSavedIdsAndTitles()` возвращает `(<int>[], <String?>[])`, запрос уходит без фильтра.

## 5. UI

### 5.1 Композиция

```
Scaffold(backgroundColor: primaryThemeBlack)
└ AppBar: back, заголовок «AI-Ассистент» по центру (m3ActionText, textWhite), без actions
└ SafeArea → BlocConsumer → Column
   ├ Expanded: switch по состоянию — _EmptyState | _Feed
   └ _Composer — закреплён снизу
```

`resizeToAvoidBottomInset` по умолчанию (`true`) — композер поднимается над клавиатурой. Отдельного ряда чипов между лентой и композером нет.

### 5.2 Пустое состояние

Показывается, когда состояние `AiAssistantInitial` (поисков ещё нет). Это `ListView` с padding `16, 16, 16, 8`:

- «Что хочется посмотреть?» — `m3Title(color: textWhite)`;
- `SizedBox(height: 8)`;
- «Опишите настроение, жанр или фильм-ориентир.» — `m3Body(color: textGrey)`. Второго предложения про историю в тексте нет;
- `SizedBox(height: 20)`;
- «С чего начать» — `m3FilmTitle(color: textDarkGrey)`;
- `SizedBox(height: 12)`;
- `Wrap(spacing: 8, runSpacing: 8)` из шести пилюль `_StartQueryPill`: `TapScale` → `SoftGradientCard` → padding `12×8` → текст `m3ActionText(color: cardAccentText)`.

Тексты пилюль (`_startQueries`, `ai_assistant_screen.dart:18-25`): «Добрая комедия на вечер», «Аниме про путешествия», «Фильмы про ограбления банков», «Триллер с неожиданной развязкой», «Мультик для всей семьи», «Лёгкое кино после работы».

Тап → `_fillQuery`: текст в контроллер, курсор в конец, `requestFocus`; отправки нет. Секции «Недавние запросы» нет.

### 5.3 Композер

`Container` (margin `16, 8, 16, 12`, padding `16, 12, 12, 8`, `primaryThemeGrey`, рамка `Colors.white.withValues(alpha: 0.12)`, radius 16) → `Column(mainAxisSize: min, crossAxisAlignment: start)`:

1. `_OnlyNewToggle` — пилюля «Только новое» (см. `.scratch/only-new/spec.md` §5.1);
2. `SizedBox(height: 10)`;
3. `Row(crossAxisAlignment: end)`:
   - `Expanded(TextField)`: `minLines: 1`, `maxLines: 3`, `maxLength: 200`, `keyboardType: multiline`, `textInputAction: go`, `textCapitalization: sentences`, `cursorColor: primaryScheme`, `border: InputBorder.none`, `isDense: true`, `contentPadding: zero`, стиль `m3Content(color: textWhite)`;
     hint одинаковый в обоих состояниях — «Запрос на поиск фильмов...» (`m3Content(textDarkGrey)` с `w400`);
     `counterStyle` — `m3Body(color: textDarkGrey)` с размером 11 и весом 400; счётчик показывает «27/200» и «0/200», как в макете;
   - `SizedBox(width: 8)`;
   - `_SendButton`: круглая 40×40, `Material` + `InkWell`; поле пустое → `white@0.08`, иконка `Icons.arrow_upward` 20 цвета `textDarkGrey`, `onTap: null`; поле не пустое → `primaryScheme`, иконка `textWhite`.

Отправка: `query.trim()`, при пустой строке ничего не происходит; после отправки контроллер очищается и фокус снимается. Отправка разрешена и при `NetworkStatus.disconnected`: проверка сети в `NetworkService` идёт по DNS `google.com`/`yandex.ru` (`lib/app/network_service/network_service.dart:14-17`) и за VPN/корпоративным DNS даёт ложное «нет сети»; блокировать рабочий запрос нельзя. Пользователь получит инлайновую ошибку сети и «Повторить». Кнопки отмены нет.

### 5.4 Лента и аккордеон

`ListView.separated` (padding `16, 12, 16, 8`, разделитель 12) по списку `searches` в порядке добавления: новые поиски в конце списка. Развёрнут ровно один поиск (`expandedSearchId`); остальные — пилюли.

**Свёрнутый поиск** — пилюля на всю ширину, высота 52, `primaryThemeGrey`, рамка `white@0.12`, radius 16, padding по горизонтали 16:

- слева `query` — `m3ActionText(color: textWhite)`, одна строка, `ellipsis`;
- `SizedBox(width: 12)`;
- справа — `«${DataFormatter.formatRelativeDay(createdAt)} · ${<счётчик>}»` — `m3Body(color: textDarkGrey)`:
  - загружен → `formatFilmWordDeclension(n)` («5 фильмов», «1 фильм», «2 фильма»);
  - пусто → «0 фильмов»;
  - ошибка → «ошибка»;
  - загрузка → «загружается»;
- тап → `AiAssistantSearchExpanded(id)`.

**Развёрнутый поиск** — `Column(crossAxisAlignment: stretch)`:

- `Row(mainAxisAlignment: center)`: дата «Сегодня, 15:37» — `m3FilmTitle(color: textDarkGrey)`, `formatRelativeDayTime(createdAt)`; если поиск отправлен с `onlyNew` — `SizedBox(width: 8)` и бейдж «Только новое»;
- `SizedBox(height: 10)`;
- пузырь пользователя: `Align(centerRight)`, ширина ≤ 80 % экрана, `primaryScheme`, radius 20, padding `16×12`, `m3ActionText(color: textWhite)`;
- `SizedBox(height: 12)`;
- тело ответа — `switch` по типу `AiFilmSearchState`:
  - `AiFilmSearchLoading` — `Row`: `CircularProgressIndicator(strokeWidth: 2, primaryScheme, 16×16)` + «Подбираю фильмы под ваш запрос...» (`m3Body(textGrey)`); ниже `SizedBox(12)` и пять скелетонов карточек;
  - `AiFilmSearchLoaded` — «Нашёл N фильмов.» через `formatFilmWordDeclension`, дальше каждая карточка с отступом 12;
  - `AiFilmSearchEmpty` — «По вашему запросу не удалось подобрать подходящие фильмы. Попробуйте изменить запрос.» (`m3Body(textGrey)`), без кнопки;
  - `AiFilmSearchFailure` — `message` как есть (`m3Body(textGrey)`), ниже `TextButton` «Повторить» (`m3ActionText(color: primaryScheme)`, padding 0, минимальная высота 36, `shrinkWrap`) → `AiAssistantRetryRequested(id)`. Своих снэкбаров об ошибке нет: о потере сети уже сообщает глобальный `NetworkListener` (`lib/app/network_service/network_listener.dart:17-26`).

**Скелетон** — 5 карточек внутри `Skeletonizer(key: Key('aiSkeletonResults'), ShimmerEffect(baseColor: primaryThemeBlack, highlightColor: primaryThemeGrey, 4s))`: `Container(padding 8, primaryThemeGrey, рамка white@0.12, radius 16)` → `Row`: `Bone(100×140)`, `SizedBox(12)`, колонка из шести `Bone`: 160×16, 110×12, 70×12, две полосы на всю ширину по 12, 120×12.

**Автоскролл.** Срабатывает, когда состояние впервые становится `AiAssistantFeed`, меняется число поисков, меняется `expandedSearchId` или тип ответа развёрнутого поиска (loading → loaded). После кадра вызывается `animateTo(minScrollExtent)` 250 мс, `Curves.easeOut`, то есть скролл к началу списка. Поскольку новые поиски добавляются в конец, развёрнутый поиск при этом остаётся ниже видимой области — известное расхождение с ожидаемым поведением («показать активный поиск»), зафиксировано здесь, но не исправлено.

### 5.5 Карточка результата

`TapScale` → `SoftGradientCard` (та же градиентная поверхность, что у карточек поиска; не `primaryThemeGrey`) → `Row(crossAxisAlignment: start)`:

- слева `FilmPosterWithLibraryStatus(film: film)` — дефолтные 100×140, вместе с бейджем рейтинга снизу справа;
- `SizedBox(width: 10)`;
- справа `Expanded → Column(crossAxisAlignment: start)`:
  - `SizedBox(height: 10)`;
  - название — `nameRu ?? nameOriginal ?? '-'`, `m3Title(color: textWhite)` с `fontSize: 16`, до 2 строк, `ellipsis`;
  - если `nameOriginal` есть и отличается от названия — `SizedBox(10)` и вторая строка `nameOriginal` (`m3Body(color: cardSecondaryText)`, `w400`, одна строка, `ellipsis`);
  - `SizedBox(height: 2)`;
  - «2001 · Криминал, комедия» — `m3Body(color: cardAccentText)`, `DataFormatter.formatYearWithGenres`, одна строка, `ellipsis`;
  - `SizedBox(height: 4)`;
  - `description` — `m3Body(color: cardAccentText)`, **до 2 строк**, `ellipsis`; подписи «О фильме» в карточке нет;
- `SizedBox(width: 7)` справа.

Вся карточка ведёт на `FilmInformationRoute(filmId:, filmName: nameOriginal ?? nameRu ?? '')`; при `kinopoiskId == null` — снэкбар «Не удалось получить информацию о фильме».

### 5.6 Ошибки и пустой результат

- Ошибка не удаляет поиск из ленты: он остаётся, в пилюле помечается «ошибка», в развёрнутом виде — текст ошибки и «Повторить».
- «Повторить» переводит этот поиск в `loading` (скелетоны перерисовываются) и повторяет запрос с тем же `query` и тем же `onlyNew`; другие поиски не трогаются. Для не-`failure` поиска и для неизвестного id событие игнорируется.
- «Повторить» доступно только у развёрнутого поиска (остальные свёрнуты).
- Пустой результат «Повторить» не показывает.
- Автоматического повтора при восстановлении сети нет.

### 5.7 Стили

Только `AppColors` и `CustomTextStyles` (`lib/app/theme/app_colors.dart`, `lib/app/theme/custom_text_styles.dart`); локальные `copyWith` допускаются (размер заголовка карточки, размер счётчика).

| Элемент | Стиль |
| --- | --- |
| Заголовок пустого состояния | `m3Title(color: textWhite)` |
| Подзаголовок, строка ассистента, мета пилюли | `m3Body` (`textGrey` / `textDarkGrey`) |
| Подписи секций, дата, счётчик композера | `m3FilmTitle(color: textDarkGrey)` |
| Пилюли «С чего начать» | `SoftGradientCard` + `m3ActionText(color: cardAccentText)` |
| Пузырь, активная кнопка отправки, «Повторить», переключатель | `primaryScheme` |
| Название фильма в карточке | `m3Title`, `fontSize: 16`, `textWhite` |
| Мета и описание в карточке | `m3Body(color: cardAccentText)`, оригинальное название — `cardSecondaryText` |
| Поверхности пилюль поиска, композера, скелетонов | `primaryThemeGrey` + рамка `Colors.white.withValues(alpha: 0.12)` |

## 6. Слои и файлы

**Домен и данные:**

- `lib/domain/entities/ai_film_search.dart` — `AiFilmSearch { int id, String query, bool onlyNew, DateTime createdAt }`, `Equatable`. Ни статуса, ни результатов, ни `copyWith`: это данные, а не UI-состояние.
- `lib/data/models/ai_film_recommendation_model.dart` — поле `genres` (`[{genre}]` и `["..."]`), `toEntity()` кладёт `List<String>` в `FilmEntity.genres`.
- `lib/data/data_sources/remote/ai_film_remote_data_source.dart` — `getRecommendations(query, onlyNew, savedKinopoiskIds, savedTitles)`, 404 → `const []`.
- `lib/domain/usecases/get_ai_film_recommendations_use_case.dart` — при `onlyNew` читает `getSavedIdsAndTitles()` и передаёт id и названия в репозиторий; без режима — пустые списки и хранилище не трогается.
- `lib/domain/repository/film_repository.dart` — `Future<(List<int>, List<String?>)> getSavedIdsAndTitles()`; реализация в `lib/data/repository_impl/film_repository_impl.dart`, источник — `lib/data/data_sources/local/flim_local_data_source.dart`.
- `lib/app/util/data_formatter.dart`:
  - `formatRelativeDayTime(DateTime)` → «Сегодня, 15:37» / «Вчера, 15:37» / «12.11, 15:37» (с годом, если год не текущий);
  - `formatRelativeDay(DateTime)` → «Сегодня» / «Вчера» / «12.11» / «12.11.2025»;
  - `formatYearWithGenres(int? year, List<String>? genres, {int genreLimit = 2})` → «2001 · Криминал, комедия»; первая буква первого жанра заглавная, пустые части не дают висящего разделителя, при отсутствии обоих — `'-'`;
  - «Сегодня»/«Вчера» считаются на момент рендера, таймера нет.

**BLoC** (`lib/presentation/bloc/ai_assistant/`):

- `ai_assistant_state.dart` — sealed-иерархия:
  - `sealed AiAssistantState` → `AiAssistantInitial` (пользователь ещё ничего не спрашивал);
  - `AiAssistantFeed { List<AiFilmSearchState> searches, int? expandedSearchId }`, `AiFilmSearchState? get expanded` (если id не найден — самый свежий поиск), `copyWith`;
  - `sealed AiFilmSearchState { AiFilmSearch search }` с геттерами `id`/`query`/`onlyNew`/`createdAt` → `AiFilmSearchLoading`, `AiFilmSearchLoaded(films)` (+`filmCount`), `AiFilmSearchEmpty`, `AiFilmSearchFailure(message)`.
- `ai_assistant_event.dart` — `AiAssistantRequested(String query, {bool onlyNew})`, `AiAssistantRetryRequested(int searchId)`, `AiAssistantSearchExpanded(int searchId)`.
- `ai_assistant_bloc.dart` — аккумуляция ленты (`maxSearches = 20`, старые вытесняются через `sublist`), загрузка/повтор, разворачивание, `unknownErrorMessage = 'Неизвестная ошибка. Попробуйте ещё раз.'`, защита `_isClosed` от эмита после `close()`. Поздний ответ пишется в свой элемент по `id`; токена запроса нет.

**Экран:**

- `lib/presentation/pages/ai_assistant_screen.dart` — `@RoutePage()` `AiAssistantScreen` (MultiBlocProvider: `AiAssistantBloc`, `WatchSavedFilmsStatusCubit`) → `_AiAssistantView` (StatefulWidget) с `_EmptyState`, `_StartQueryPill`, `_Feed`, `_SearchPill`, `_ExpandedSearch`, `_UserBubble`, `_SearchAnswer` и вариантами ответа, `_SkeletonResults`/`_SkeletonCard`, `_Composer`, `_OnlyNewToggle`, `_OnlyNewBadge`, `_SendButton`, `_searchCountLabel`.
- `lib/presentation/pages/widgets/ai_film_result_card.dart` — горизонтальная карточка (§5.5).

**Удалено:** `lib/presentation/bloc/ai_films/*`, `lib/presentation/pages/ai_films_screen.dart`, `lib/app/router/navigation_tabs/ai_films/*`, тесты `ai_films_*`.

**DI:** `AiAssistantBloc` и `WatchSavedFilmsStatusCubit` — `registerFactory`.

## 7. Тесты

- `test/presentation/bloc/ai_assistant_bloc_test.dart`: пустой запрос игнорируется; запрос добавляет `AiFilmSearchLoading` и делает поиск развёрнутым (`onlyNew` попадает в запись, по умолчанию `false`); режим «Только новое» доходит до use case; успех → `AiFilmSearchLoaded` с фильмами; пустой ответ → `AiFilmSearchEmpty`; `AiServiceFailure` → текст сервиса; `NetworkFailure` → текст сети; повтор у упавшего поиска → `AiFilmSearchLoading`, затем `AiFilmSearchLoaded`, другие поиски не меняются, режим берётся из поиска; разворачивание старого поиска; лимит 20 (21-й вытесняет первый); ответ после `close()` — без ошибок.
- `test/presentation/widget/ai_assistant_empty_state_test.dart`: пустая лента показывает «Что хочется посмотреть?», «С чего начать», подсказки, «0/200», неактивную кнопку отправки; тап по подсказке подставляет текст; пустой запрос не отправляется; переключатель «Только новое» выключен по умолчанию, тап включает его и отправка уходит с `onlyNew: true`, у развёрнутого поиска появляется бейдж.
- `test/presentation/widget/ai_assistant_loading_skeleton_test.dart`: при `loading` есть строка «Подбираю фильмы под ваш запрос...» и скелетоны; после ответа — «Нашёл 1 фильм.», мета «2001 · Криминал, комедия», текст описания; ошибка сети инлайн с «Повторить»; композер после отправки пуст.
- `test/data/ai_film_recommendation_model_test.dart`: `genres` как массив объектов, как массив строк, отсутствие поля, пустой массив, неверный тип.
- `test/data/ai_film_remote_data_source_test.dart`: тело POST (`query`, `savedKinopoiskIds`, `savedTitles`, `onlyNew`) при выключенном и включённом режиме; 404 → пустой список; 502/500/503 — тексты из §4.
- `test/data/ai_film_repository_impl_test.dart`: маппинг моделей в сущности, проброс `onlyNew`, id и названий в источник.
- `test/domain/usecases/get_ai_film_recommendations_test.dart`: без режима use case не читает хранилище (`verifyNever(getSavedIdsAndTitles)`); с режимом — передаёт id и названия в репозиторий; пустая библиотека не мешает запросу.
- `test/app/util/data_formatter_test.dart`: `formatRelativeDay`/`formatRelativeDayTime` для сегодня/вчера/старше/другого года, `formatYearWithGenres` для год+жанры, только год, только жанры, пусто, `formatFilmWordDeclension`.

## 8. Кодогенерация

Не требуется при правках UI. Роуты и Hive-адаптеры не меняются; `auto_route_generator` и `hive_generator` остаются закомментированными в `pubspec.yaml:56-58`.

## 9. Критерии приёмки

- [x] Пустой экран: заголовок, подпись, «С чего начать» с шестью пилюлями, композер снизу, счётчик `0/200`, кнопка отправки неактивна.
- [x] Отправка очищает композер, снимает фокус, добавляет поиск в ленту и разворачивает его; старые поиски свёрнуты в пилюли.
- [x] Тап по пилюле разворачивает её и сворачивает текущий поиск.
- [x] Во время загрузки — спиннер, «Подбираю фильмы под ваш запрос...», пять скелетонов; по завершении — «Нашёл N фильмов.» и карточки.
- [x] Карточка горизонтальная: постер 100×140 слева, справа название (и оригинальное), «год · жанры», описание до двух строк; тап открывает экран фильма.
- [x] Ошибка отображается инлайн с «Повторить», поиск остаётся в ленте и помечен в пилюле.
- [x] Пустой ответ (включая 404) даёт текст «По вашему запросу не удалось подобрать подходящие фильмы. Попробуйте изменить запрос.» без «Повторить».
- [x] Переключатель «Только новое» есть в композере, по умолчанию выключен, уходит в запрос и помечает развёрнутый поиск бейджем.
- [x] Блок остаётся `registerFactory`: перезаход начинается с пустого состояния (ожидаемое поведение, а не баг).
- [x] `scripts/agent-flutter.ps1 analyze lib test` и `test` зелёные; `scripts/check_routes_sync.sh`, `scripts/check_vocabulary.sh` проходят.
- [x] `GLOSSARY.md` и ADR-0005/ADR-0006 обновлены.
