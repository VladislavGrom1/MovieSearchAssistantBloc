# 0003. `FilmSearchResponseFilms.year` — строка, а не число

- **Статус:** Принято (правка вендоренного пакета `generated`)
- **Дата:** 2026-11-13

## Контекст

Поиск фильмов по ключевому слову (`SearchedFilmsBloc` → `SearchFilmsByKeywordUseCase` → `FilmRemoteDataSource.getSearchFilmsByKeyword` → `/api/v2.1/films/search-by-keyword`) после подключения падал на **любом** запросе: экран показывал «Неизвестная ошибка».

Причина — не в BLoC. Спека [swaggers/kinopoiskunofficial_openapi.json](../../swaggers/kinopoiskunofficial_openapi.json) описывает год как строку:

```json
"year": { "type": "string", "example": "2012" }
```

и сервис действительно присылает `"year": "1999"`, а у невышедшего фильма — `"year": "null"`. Модель же в пакете `generated` (`openapi-generator 7.9.0`, коммит `e714960`) объявляла `int? year`, поэтому built_value не мог десериализовать ответ, бросал исключение внутри `apiV21FilmsSearchByKeywordGet`, оно превращалось в `DioException(type: unknown)` и затем в `UnknownFailure` через `ExceptionMapper`.

Заодно в маппинге `ratingKinopoisk: int.tryParse(film.rating ?? "-")` терялись дробные оценки: `"8.5"` давало `null`, и бейдж рейтинга пропадал.

Варианты:

1. Поправить тип в `generated`, чтобы модель совпала со спекой.
2. Читать эндпоинт сырым `dio.get` и разбирать `Map<String, dynamic>` вручную.
3. Оставить `int` и написать кастомный `Serializer`, приводящий `"1999"` к числу.

## Решение

Вариант 1. В `generated` поле объявлено строкой — как в спеке:

- [`film_search_response_films.dart`](../../generated/lib/src/model/film_search_response_films.dart): `String? get year`, `FullType(String)` в сериализаторе и `as String` в десериализаторе;
- [`film_search_response_films.g.dart`](../../generated/lib/src/model/film_search_response_films.g.dart): тип поля и builder'а;
- [`doc/FilmSearchResponseFilms.md`](../../generated/doc/FilmSearchResponseFilms.md): тип в автодоке.

Приведение к домену остаётся в слое моделей: `year: int.tryParse(film.year ?? '')`, `ratingKinopoisk: num.tryParse((film.rating ?? '').replaceAll(',', '.'))`.

## Последствия

- `"1999"` → `1999`, `"null"` → `null`, `"8.5"` → `8.5` (раньше терялось), `8.0` → `8`.
- Регрессия закрыта тестом [`test/data/film_remote_data_source_keyword_test.dart`](../../test/data/film_remote_data_source_keyword_test.dart): он прогоняет реальное тело ответа через публичный метод и падает, если `generated` снова разойдётся со спекой.
- Файлы в `generated` помечены «AUTO-GENERATED FILE, DO NOT MODIFY». Если пакет будут перегенерировать, делать это нужно из `swaggers/kinopoiskunofficial_openapi.json` (openapi-generator 7.9.0) и после регенерации прогнать keyword-тест: при спеке с `"type": "string"` модель останется правильной, при спеке с числом — правку придётся вернуть.
- Правка не влияет на эндпоинт v2.2 `/api/v2.2/films`: там `FilmSearchByFiltersResponseItems.year` объявлен как `num?` и с реальным числовым ответом работает.
- Подключение keyword-поиска к `SearchedFilmsBloc` потребовало развилки «какой эндпоинт звать»; её правила и регрессию «Показать без фильтров» фиксирует [ADR 0004](0004-search-endpoint-by-keyword.md).

## Отклонённые альтернативы

- **Ручной разбор `Map<String, dynamic>` в data source** — обходит кодогенерацию, которую в проекте используют как основной способ описания контрактов; отвергнуто владельцем проекта.
- **Кастомный `Serializer<int>` в `generated`** — рабочий, но заметно больший объём правки в автогенерируемом коде, чем смена одного типа на тип из спеки.
