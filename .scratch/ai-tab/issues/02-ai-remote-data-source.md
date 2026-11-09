# 02. Источник данных: `POST` в AI-воркер и маппинг ошибок

Status: ready-for-agent
Type: task
Blocked by: 01

## Контекст

Спека: `.scratch/ai-tab/spec.md`, разделы 4, 6.3, 6.5. Решение по транспорту: ADR-0002.

## Что сделать

- [ ] В `lib/app/exceptions/remote_data_source_exception.dart` добавить:
      ```dart
      class AiServiceFailure extends RemoteDataSourceException {
        AiServiceFailure(super.message);
      }
      ```
- [ ] Создать `lib/data/data_sources/remote/ai_film_remote_data_source.dart`:
      ```dart
      class AiFilmRemoteDataSource {
        final Dio dio;
        AiFilmRemoteDataSource({required this.dio});

        Future<List<AiFilmRecommendationModel>> getRecommendations(String query);
      }
      ```
- [ ] Хост — константа в этом файле: `const aiFilmsEndpoint = 'https://ai-movie-assistant.vladislav-vaganov-dev.workers.dev/';`. `baseUrl` в `DioApiClient` не менять.
- [ ] Запрос: `dio.post(aiFilmsEndpoint, data: {'query': query})`. `Content-Type: application/json` выставит `Dio` сам.
- [ ] Разбор: `response.data['movies'] as List<dynamic>? ?? const []` → `AiFilmRecommendationModel.fromJson` (тикет 01). Пустой список возвращать как пустой список, не `null`.
- [ ] `on DioException catch (e) { throw _mapError(e); }`, где:
      - `404` → `AiServiceFailure("Фильмы не найдены. Попробуйте описать иначе.")`
      - `502` → `AiServiceFailure("Модель не смогла ответить. Попробуйте позже.")`
      - `400`, `405`, `500` → `AiServiceFailure("Сервис подбора временно недоступен. Попробуйте позже.")`
      - иначе: если в `e.response?.data` есть строковое поле `error` и статус незнакомый — текст сервера; иначе `ExceptionMapper.mapDioException(e).message`; если и его нет — `"Неизвестная ошибка. Попробуйте ещё раз."`
- [ ] Тест `test/data/ai_film_remote_data_source_test.dart` (mocktail + `Dio` с мок-адаптером или подменой `Dio`): `200` с двумя фильмами; `200` с `movies: []`; `404` и `502` дают разные `AiServiceFailure.message`; `connectionError` даёт текст `NetworkFailure`.

## Критерии готовности

- `flutter test test/data/ai_film_remote_data_source_test.dart` — зелёный.
- Ни один запрос не уходит на кинопрокси: URL абсолютный.

## Comments

- Реализовано (2026-11-09): `AiFilmRemoteDataSource` (абсолютный URL, POST через общий `Dio`), `AiServiceFailure`, маппинг 400/404/405/500/502 и fallback на текст сервера. Тесты: `test/data/ai_film_remote_data_source_test.dart` — 7 зелёных.
