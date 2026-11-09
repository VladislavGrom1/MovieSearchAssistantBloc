# Спека: AI-вкладка — подбор фильмов по описанию

Status: ready-for-agent
Дата: 2026-11-09

## 1. Задача

Пользователь не знает, что посмотреть, но может описать желаемое словами. Нужен экран, где он пишет запрос («фильм про ограбление казино»), нажимает кнопку и получает 5 фильмов с постерами и кратким описанием сюжета. Тап по фильму открывает существующий экран деталей.

Экран — отдельная вкладка **AI**, вторая по счёту в нижней навигации.

## 2. Пользовательский сценарий

1. Пользователь открывает вкладку AI.
2. Видит поле ввода, подсказку и примеры запросов; при желании нажимает пример — текст подставляется в поле.
3. Вводит запрос (до 200 символов) и нажимает «Подобрать фильмы».
4. Кнопка блокируется, старые результаты заменяются пятью скелетонами.
5. При успехе появляются 5 карточек: постер, рейтинг, название, описание (3 строки, раскрывается).
6. При пустом ответе — «Ничего не нашлось» и совет переформулировать.
7. При ошибке — компактный блок с сообщением и кнопкой «Повторить», которая повторяет последний запрос.
8. Тап по карточке фильма открывает экран деталей. Фильм без `kinopoiskId` не кликабелен.

## 3. Границы

- Нет истории запросов и сохранения рекомендаций: всё живёт в памяти, пропадает при перезапуске приложения, переживает переключение вкладок.
- `description` виден **только на AI-вкладке**: не пишется в `FilmEntity`, не попадает в Hive/коллекции/экспорт, не передаётся на экран деталей (передаём только `filmId` и `filmName`).
- Нет пагинации, бесконечной ленты и повторной генерации без явного действия пользователя.
- Нет стриминга и частичных ответов.
- Нет локализации: тексты — русские строки в коде, как во всём приложении.
- `FilmPosterCard` не меняется (см. ADR-0001).

## 4. API

База: `https://ai-movie-assistant.vladislav-vaganov-dev.workers.dev/`
Эндпоинт: `POST /`
Заголовок: `Content-Type: application/json`
Тело: `{"query": "..."}` — строка, русский, ≤200 символов.

Успех `200`:

```json
{
  "movies": [
    {
      "title": "Ocean's Eleven",
      "year": 2001,
      "reason": "Дэнни Оушен собирает команду из одиннадцати профессионалов...",
      "kinopoiskId": 526,
      "posterUrl": "https://...",
      "rating": "8.1"
    }
  ]
}
```

| Поле | Тип | Что это |
|---|---|---|
| `title` | `string` | Оригинальное английское название. Показываем как есть, `nameRu` не догружаем. |
| `year` | `number \| null` | Год. На карточке не показываем (см. ADR-0001), кладём в `FilmEntity.year`. |
| `reason` | `string` | Русское описание сюжета с Кинопоиска. Это **не** обоснование выбора. |
| `kinopoiskId` | `number \| null` | ID для перехода на экран деталей. |
| `posterUrl` | `string \| null` | Постер. Пишем и в `posterUrl`, и в `posterUrlPreview` — `FilmPosterImage` рисует только preview. |
| `rating` | `string \| null` | Рейтинг Кинопоиска строкой (`"8.1"`). Парсим в `num?`; целые значения отдаём как `int`, чтобы бейдж не показывал `8.0`. |

Ошибки: тело `{"error": "..."}`.

| Статус | Текст сервера | Что показываем |
|---|---|---|
| `400` | Поле 'query' обязательно | «Сервис подбора временно недоступен. Попробуйте позже.» (недостижимо: пустой запрос не отправляется) |
| `404` | Фильмы не найдены на Кинопоиске. | «Фильмы не найдены. Попробуйте описать иначе.» |
| `405` | Используйте POST | «Сервис подбора временно недоступен. Попробуйте позже.» |
| `500` | AI binding не настроен | «Сервис подбора временно недоступен. Попробуйте позже.» |
| `502` | Ошибка модели. Возможно, лимит нейронов исчерпан. | «Модель не смогла ответить. Попробуйте позже.» |
| сеть/таймаут | — | Тексты из `ExceptionMapper` (`NetworkFailure`, `ServerFailure`) |
| прочее | `error` из тела, если есть | Иначе «Неизвестная ошибка. Попробуйте ещё раз.» |

Лимиты сервиса (для понимания, в UI не показываем): ~10 000 нейронов в сутки, ~3.2 нейрона на запрос, ~3100 запросов в сутки, 5 запросов к Кинопоиску на один запрос пользователя.

## 5. UI

### 5.1 Композиция экрана

`AiFilmsScreen` (`@RoutePage`), без `AppBar`, фон — `AppColors.primaryThemeBlack`. Один `ListView` c `padding: EdgeInsets.fromLTRB(16, 16, 16, 24)`, дети сверху вниз:

1. Заголовок «Что посмотреть?» — `CustomTextStyles.m3Headline()`.
2. Подпись «Опишите настроение, сюжет или жанр — подберём 5 фильмов.» — `m3Body(color: AppColors.textGrey)`.
3. Поле ввода (см. 5.2).
4. Примеры запросов, `Wrap(spacing: 8, runSpacing: 8)` из `ActionChip`:
   - «Фильм про ограбление казино»
   - «Добрая комедия на вечер»
   - «Фантастика с неожиданным финалом»
   - «Триллер в замкнутом пространстве»
   Тап по чипу заполняет поле (курсор в конец), отправку не запускает.
5. Кнопка «Подобрать фильмы» — `FilledButton` на всю ширину, фон `AppColors.primaryScheme`, `foregroundColor` `AppColors.textWhite`.
6. Блок результатов — по состоянию (см. 5.3).

Вся страница скроллится одним `ListView`, чтобы клавиатура не ломала раскладку.

### 5.2 Поле ввода

- `TextEditingController` в `State` экрана, `FocusNode` тоже.
- `minLines: 3`, `maxLines: 5`, `keyboardType: TextInputType.multiline`, `textInputAction: TextInputAction.newline`.
- `maxLength: 200` — штатный счётчик `0/200` под полем.
- Оформление по образцу `CustomSearchBar` (`custom_search_bar.dart:65-95`): скругление 14, заливка `AppColors.primaryThemeGrey.withValues(alpha: 0.55)`, рамка `Colors.white.withValues(alpha: 0.12)`, при фокусе — `AppColors.primaryScheme` шириной 1.4 и свечение `primaryScheme.withValues(alpha: 0.35)`, blur 14.
- Hint: «Например: фильм про ограбление казино».
- Кнопка активна, только если `controller.text.trim().isNotEmpty` и состояние не `AiFilmsLoading` и не `isRetrying`.
- По нажатию: `FocusScope.of(context).unfocus()`, запрос с `trim()`.
- «Сбросить» — `TextButton.icon` с `Icons.restart_alt` справа от заголовка «AI-подбор». Видна, только когда есть что сбрасывать: состояние не `AiFilmsInitial` **или** поле непустое. Нажатие очищает контроллер, снимает фокус и добавляет `AiFilmsResetRequested` (см. 5.5).

### 5.3 Состояния блока результатов

| Состояние | Что рисуем |
|---|---|
| `AiFilmsInitial` | `Icon(Icons.movie_filter_outlined, size: 72, color: AppColors.primaryThemeGrey)`, заголовок «Здесь появятся 5 фильмов», подпись «Опишите, что хочется посмотреть — сюжет, настроение или жанр.» |
| `AiFilmsLoading` | 5 скелетон-карточек внутри `Skeletonizer(enabled: true)`: прямоугольник 140×200 (скругление 16), две строки заголовка и три строки описания (`AppColors.primaryThemeGrey`). Старые результаты не остаются. |
| `AiFilmsLoaded` | Заголовок «Подборка по запросу «{query}»» (`m3Title`), затем 5 `AiFilmResultCard` с отступом 24 между ними. |
| `AiFilmsEmpty` | `Icon(Icons.search_off, size: 72, color: AppColors.primaryThemeGrey)`, «Ничего не нашлось», «Попробуйте описать иначе — другими словами, жанром или настроением.», `TextButton` «Повторить» (во время повтора — вместо кнопки спиннер 20×20). |
| `AiFilmsFailure` | Компактный блок по образцу `film_information_screen.dart:729-757`: `Icon(Icons.error_outline, color: AppColors.primaryScheme)`, текст `message` (`m3Body`), `TextButton` «Повторить» (во время повтора — вместо кнопки спиннер 20×20). |

«Повторить» повторяет последний запрос из состояния (состояния несут `query`). Повтор **не** эмитит `AiFilmsLoading`: `AiFilmsFailure`/`AiFilmsEmpty` получают `isRetrying: true`, блок остаётся на экране, иначе заглушки карточек мелькают на один кадр при быстром отказе (баг найден и закрыт 2026-11-09, регрессия — `test/presentation/widget/ai_films_retry_flash_test.dart`). Общая `ErrorMessageWidget` не используется: у неё нет ретрая.

### 5.5 Сброс

`AiFilmsResetRequested` возвращает экран в `AiFilmsInitial`: результаты, ошибка и пустой ответ убираются, поле очищается, снова видны чипы-примеры.

- Сброс доступен из любого состояния, включая `Loading` и повтор.
- Ответ запроса, который ещё летел в момент сброса, **отбрасывается**: `AiFilmsBloc` держит счётчик `_requestToken`, сброс его увеличивает, и `_load` после `await` проверяет `token == _requestToken` (вместе с `isClosed`/`emit.isDone`). Иначе сброс во время загрузки через мгновение вернул бы `Loaded`.

```dart
bool _isActual(int token, Emitter<AiFilmsState> emit) =>
    !isClosed && !emit.isDone && token == _requestToken;
```

### 5.4 Карточка `AiFilmResultCard`

Файл: `lib/presentation/pages/widgets/ai_film_result_card.dart` (см. ADR-0001).

- Пропсы: `final AiFilmRecommendation recommendation; final VoidCallback? onTap;`.
- `StatefulWidget` (локальный `_expanded`), ключ в списке — `ValueKey(recommendation.film.kinopoiskId)`.
- `Padding(vertical: 8)` внутри `InkWell`/`TapScale` (если `onTap != null`) → `Column(crossAxisAlignment: CrossAxisAlignment.center)`:
  1. `FilmPosterWithLibraryStatus(film: film, showRating: true, width: 140, height: 200)`.
  2. `SizedBox(height: 8)`.
  3. Название: `Text(film.nameOriginal ?? '', textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: CustomTextStyles.m3FilmTitle())` в `SizedBox(width: 220)`.
  4. `SizedBox(height: 6)`.
  5. Описание: `Text(description, textAlign: TextAlign.center, maxLines: _expanded ? null : 3, overflow: _expanded ? TextOverflow.clip : TextOverflow.ellipsis, style: CustomTextStyles.m3Body(color: AppColors.textGrey))` в `SizedBox(width: 260)`.
  6. Если описание длиннее трёх строк — `TextButton` «Читать полностью» / «Свернуть» (`primaryScheme`). Тап по кнопке не должен открывать экран деталей.
- `onTap` = `null`, если `kinopoiskId == null`; иначе `context.router.push(FilmInformationRoute(filmId: kinopoiskId, filmName: film.nameOriginal ?? ''))`.
- Год, рейтинг отдельным текстом и кнопки «Сохранить» на карточке не показываем; бейдж рейтинга и иконка «в библиотеке» приходят из постера.

### 5.5 Навигация

- Новый раздел: `lib/app/router/navigation_tabs/ai_films/ai_films_routes.dart` по образцу `search_film_routes.dart:4-18`:

  ```dart
  abstract class AiFilmsRoutes {
    static final routes = AutoRoute(
      page: AiFilmsWrapperRoute.page,
      children: [
        AutoRoute(page: AiFilmsRoute.page, initial: true),
        AutoRoute(page: FilmInformationRoute.page),
      ],
    );
  }
  ```

- `AiFilmsWrapperScreen` — копия `search_film_wrapper_screen.dart:4-17` (`implements AutoRouteWrapper`, `build => const AutoRouter()`, `wrappedRoute => this`).
- `app_router.dart`: `AiFilmsRoutes.routes` вставляется в `children` между `SearchFilmRoutes.routes` и `CollectionsRoutes.routes`.
- `home_screen.dart:22-26`: `AiFilmsWrapperRoute()` вставляется второй, до `CollectionsRoute()`.
- Нижняя навигация (`home_screen.dart:43-68`): у всех четырёх табов убираем подписи — `showSelectedLabels: false`, `showUnselectedLabels: false`, `label: null` в `BottomNavigationBarItem` (или пустая строка). Иконка AI — `Icons.auto_awesome`, подсказка `Tooltip(message: "AI")`.
- Итоговый порядок: Поиск, AI, Коллекции, Профиль.

## 6. Слои и файлы

| Слой | Файл |
|---|---|
| Домен | `lib/domain/entities/ai_film_recommendation.dart` |
| Модель | `lib/data/models/ai_film_recommendation_model.dart` |
| Источник | `lib/data/data_sources/remote/ai_film_remote_data_source.dart` |
| Репозиторий | `lib/domain/repository/ai_film_repository.dart`, `lib/data/repository_impl/ai_film_repository_impl.dart` |
| Use case | `lib/domain/usecases/get_ai_film_recommendations_use_case.dart` |
| BLoC | `lib/presentation/bloc/ai_films/ai_films_bloc.dart`, `ai_films_event.dart`, `ai_films_state.dart` |
| Экран | `lib/presentation/pages/ai_films_screen.dart` |
| Карточка | `lib/presentation/pages/widgets/ai_film_result_card.dart` |
| Роутинг | `lib/app/router/navigation_tabs/ai_films/ai_films_routes.dart`, `ai_films_wrapper_screen.dart` |
| DI | `lib/injection_container.dart` |

### 6.1 Домен

```dart
class AiFilmRecommendation extends Equatable {
  final FilmEntity film;
  final String description;

  const AiFilmRecommendation({required this.film, required this.description});

  @override
  List<Object?> get props => [film, description];
}
```

### 6.2 Модель

`AiFilmRecommendationModel` — ручной `fromJson` (в проекте нет `json_serializable`), метод `toEntity()`. Заполняет `FilmEntity(kinopoiskId:, nameOriginal: title, year: year?.toInt(), posterUrl: posterUrl, posterUrlPreview: posterUrl, ratingKinopoisk: parsedRating)`.

`rating` из строки: `num.tryParse(rating.replaceAll(',', '.'))`; если значение целое — приводим к `int` (`8.0` → `8`).

### 6.3 Источник данных

```dart
class AiFilmRemoteDataSource {
  final Dio dio;
  AiFilmRemoteDataSource({required this.dio});

  Future<List<AiFilmRecommendationModel>> getRecommendations(String query) async {
    try {
      final response = await dio.post(
        'https://ai-movie-assistant.vladislav-vaganov-dev.workers.dev/',
        data: {'query': query},
      );
      final movies = response.data['movies'] as List<dynamic>? ?? const [];
      return movies
          .map((e) => AiFilmRecommendationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e); // AiServiceFailure, см. 6.5
    }
  }
}
```

Хост держать константой в этом файле (`const aiFilmsEndpoint = ...`), не в `DioApiClient` (см. ADR-0002).

### 6.4 BLoC

События:

```dart
sealed class AiFilmsEvent extends Equatable {
  const AiFilmsEvent();
  @override
  List<Object?> get props => [];
}

final class AiFilmsRequested extends AiFilmsEvent {
  final String query;
  const AiFilmsRequested(this.query);
  @override
  List<Object?> get props => [query];
}

final class AiFilmsRetryRequested extends AiFilmsEvent {
  const AiFilmsRetryRequested();
}

final class AiFilmsResetRequested extends AiFilmsEvent {
  const AiFilmsResetRequested();
}
```

Состояния (все несут последний `query` для ретрая и флаг `isRetrying`):

```dart
final class AiFilmsInitial extends AiFilmsState;
final class AiFilmsLoading extends AiFilmsState;
final class AiFilmsLoaded extends AiFilmsState { final List<AiFilmRecommendation> recommendations; }
final class AiFilmsEmpty extends AiFilmsState;
final class AiFilmsFailure extends AiFilmsState { final String message; }
```

Поведение:
- `AiFilmsRequested(query)` → `Loading` → use case → `movies.isEmpty ? Empty : Loaded`. Пустой/пробельный запрос игнорируется (страховка в дополнение к disabled-кнопке).
- `AiFilmsRetryRequested` → повторяет `query` из текущего состояния; без сохранённого запроса (или из `Initial`/`Loaded`) игнорируется. Эмитит копию текущего `Empty`/`Failure` с `isRetrying: true` и **не** эмитит `Loading`.
- `RemoteDataSourceException` → `AiFilmsFailure(e.message)`; любое другое исключение → `AiFilmsFailure("Неизвестная ошибка. Попробуйте ещё раз.")`.
- `AiFilmsResetRequested` → увеличивает `_requestToken` и эмитит `AiFilmsInitial`; выход из любого состояния, ответ летящего запроса после этого игнорируется (см. п. 5.5).
- Повторный `AiFilmsRequested` во время загрузки отменяет предыдущий (`_requestToken` + проверка `isClosed`/`emit.isDone`), старые результаты не показываются (см. спеку п. 5.3).

### 6.5 Ошибки

В `lib/app/exceptions/remote_data_source_exception.dart` добавить:

```dart
class AiServiceFailure extends RemoteDataSourceException {
  AiServiceFailure(super.message);
}
```

Маппинг в источнике: `404`, `502`, `400/405/500` → свои тексты из таблицы п. 4; остальное — `ExceptionMapper.mapDioException(e).message`; если в теле есть `error` и статус незнакомый — берём текст сервера, иначе «Неизвестная ошибка. Попробуйте ещё раз.».

### 6.6 DI

В `initializeDependencies()` рядом с `FilmRemoteDataSource`:

```dart
getIt.registerLazySingleton(() => AiFilmRemoteDataSource(dio: getIt()));
getIt.registerLazySingleton<AiFilmRepository>(() => AiFilmRepositoryImpl(getIt()));
getIt.registerLazySingleton(() => GetAiFilmRecommendationsUseCase(getIt()));
getIt.registerFactory(() => AiFilmsBloc(getIt()));
```

`Cubit` не нужен: «Повторить» берёт запрос из состояния BLoC.

### 6.7 Экран

```dart
@RoutePage()
class AiFilmsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AiFilmsBloc>()),
        BlocProvider(create: (_) => getIt<WatchSavedFilmsStatusCubit>()),
      ],
      child: const _AiFilmsView(),
    );
  }
}
```

`WatchSavedFilmsStatusCubit` обязателен: `FilmPosterWithLibraryStatus` внутри карточки делает `BlocSelector` по нему и без провайдера упадёт.

## 7. Тесты

- `test/data/ai_film_recommendation_model_test.dart`: полный ответ; `null` в `year`/`kinopoiskId`/`posterUrl`/`rating`; `rating: "8.0"` → `int 8`; пустой `movies` → пустой список.
- `test/presentation/bloc/ai_films_bloc_test.dart` (`bloc_test` + `mocktail`):
  - `AiFilmsRequested` → `[AiFilmsLoading, AiFilmsLoaded]`;
  - use case бросает `AiServiceFailure("...")` → `AiFilmsFailure(message)`;
  - пустой список → `AiFilmsEmpty`;
  - `AiFilmsRetryRequested` после ошибки повторяет исходный запрос (`Failure(isRetrying: false)` → `Failure(isRetrying: true)` → `Loaded`, без `Loading`);
  - повтор из `AiFilmsEmpty` тоже без `Loading`;
  - `AiFilmsResetRequested` из `Loaded`/`Failure` → `AiFilmsInitial`; из `Initial` — безопасен; во время загрузки ответ устаревшего запроса отбрасывается;
  - повторный запрос не показывает старые результаты.
- `test/presentation/widget/ai_films_reset_test.dart`: «Сбросить» скрыта в `Initial`, появляется после ввода, после ошибки возвращает чипы-примеры и чистое поле, сброс во время загрузки не показывает пришедший позже результат.
- `test/presentation/widget/ai_films_retry_flash_test.dart`: при повторе после ошибки сети на экране не мелькают заглушки — блок ошибки остаётся, «Повторить» заменяется спиннером (регрессия на баг с мерцанием, 2026-11-09).
- `flutter analyze` — без новых `error •` (CI смотрит только на них).

## 8. Кодогенерация

`auto_route_generator` закомментирован в `pubspec.yaml` (`:14-18`). Пользователь запускает генерацию сам:

1. Закомментировать `flutter_bloc`, `flutter_test`, `hive_generator`.
2. `dart run build_runner build --delete-conflicting-outputs --build-filter="lib/app/router/*.dart"`.
3. Вернуть `pubspec.yaml` как было.

## 9. Критерии приёмки

- [ ] Вкладка AI стоит второй, все четыре таба — только иконки.
- [ ] Поле: 3–5 строк, счётчик 200, hint, фокус-обводка; пустой/пробельный ввод не отправляется.
- [ ] Примеры заполняют поле, но не отправляют запрос.
- [ ] Во время загрузки кнопка заблокирована, результаты заменены пятью скелетонами.
- [ ] Успех: 5 карточек, постер 140×200 по центру, название, описание в 3 строки с раскрытием.
- [ ] Тап по карточке открывает экран деталей; фильм без `kinopoiskId` не кликабелен.
- [ ] Пустой ответ и ошибка — разные состояния; оба с «Повторить».
- [ ] «Сбросить» возвращает экран в исходное состояние из любого состояния и не даёт позднему ответу вернуть старые результаты.
- [ ] `404`, `502`, `500`, сеть и таймаут дают разные понятные тексты.
- [ ] Рекомендации и описания переживают переключение вкладок и исчезают после перезапуска.
- [ ] `description` нигде не сохраняется и не передаётся на экран деталей.
- [ ] Тесты из п. 7 проходят, `flutter analyze` не даёт новых ошибок.
- [ ] `GLOSSARY.md`, ADR-0001 и ADR-0002 не противоречат реализации.
