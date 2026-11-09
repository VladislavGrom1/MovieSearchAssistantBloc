# 01. Домен: `AiFilmRecommendation` и парсинг ответа AI-сервиса

Status: ready-for-agent
Type: task

## Контекст

Спека: `.scratch/ai-tab/spec.md`, разделы 4 (API), 6.1–6.2. Термины: `GLOSSARY.md` («AI-рекомендация», «Описание»).

## Что сделать

- [ ] Создать `lib/domain/entities/ai_film_recommendation.dart`: `AiFilmRecommendation extends Equatable` с полями `final FilmEntity film; final String description;`, конструктор `const AiFilmRecommendation({required this.film, required this.description})`, `props => [film, description]`.
- [ ] Создать `lib/data/models/ai_film_recommendation_model.dart`: ручной `fromJson(Map<String, dynamic>)` (в проекте нет `json_serializable`), поля `title`, `year`, `reason`, `kinopoiskId`, `posterUrl`, `rating` и метод `toEntity()`.
- [ ] `toEntity()` собирает `FilmEntity(kinopoiskId:, nameOriginal: title, year: year?.toInt(), posterUrl: posterUrl, posterUrlPreview: posterUrl, ratingKinopoisk: parsedRating)`. Остальные поля `FilmEntity` — `null`.
- [ ] Рейтинг: `num.tryParse(value.replaceAll(',', '.'))`; целые значения приводить к `int` (`8.0` → `8`), чтобы бейдж не показывал `8.0`.
- [ ] `reason` → `description` как есть; `null`/отсутствующее поле → пустая строка.
- [ ] `posterUrl` писать и в `posterUrl`, и в `posterUrlPreview` — `FilmPosterImage` рисует только preview.
- [ ] Тест `test/data/ai_film_recommendation_model_test.dart`: полный ответ; `null` в `year`/`kinopoiskId`/`posterUrl`/`rating`; `rating: "8.0"` → `int 8`; `movies: []` → пустой список.

## Важно

`FilmEntity` не трогать: ни новых полей, ни Hive-изменений. `description` живёт только в `AiFilmRecommendation`.

## Критерии готовности

- `flutter test test/data/ai_film_recommendation_model_test.dart` — зелёный.
- `flutter analyze` не даёт новых `error •`.

## Comments

- Реализовано (2026-11-09): `AiFilmRecommendation`, `AiFilmRecommendationModel.fromJson/toEntity` с парсингом рейтинга `8.0` -> `int`, `7,9` -> `7.9`, `—` -> `null`. Тесты: `test/data/ai_film_recommendation_model_test.dart` — 6 зелёных.
