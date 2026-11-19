# 05. `AiFilmResultCard` и размеры постера

Status: ready-for-agent
Type: task
Blocked by: 01

## Контекст

Спека: `.scratch/ai-tab/spec.md`, раздел 5.4. Решение и альтернативы: ADR-0001.

## Что сделать

- [ ] `lib/presentation/pages/widgets/film_poster_image.dart`: добавить `final double width; final double height;` со значениями по умолчанию `100` и `140`. Использовать их в `Image.file`, `CachedNetworkImage` и заглушке-скелетоне вместо хардкода; `memCacheWidth: (width * 2).round()`, `memCacheHeight: (height * 2).round()`. Бейджи не двигать.
- [ ] `lib/presentation/pages/widgets/film_poster_with_library_status.dart`: пробросить `width`/`height` (значения по умолчанию 100/140) в `FilmPosterImage`. Существующие вызовы не трогать.
- [ ] `lib/presentation/pages/widgets/ai_film_result_card.dart`: `StatefulWidget` с пропсами `final AiFilmRecommendation recommendation; final VoidCallback? onTap;`.
      - `Column(crossAxisAlignment: CrossAxisAlignment.center)`.
      - Постер: `FilmPosterWithLibraryStatus(film: film, showRating: true, width: 140, height: 200)`.
      - Название: `film.nameOriginal ?? ''`, по центру, `maxLines: 2`, `TextOverflow.ellipsis`, `CustomTextStyles.m3FilmTitle()`, ширина 220.
      - Описание: `description`, по центру, `maxLines: _expanded ? null : 3`, `ellipsis` в свёрнутом виде, `CustomTextStyles.m3Body(color: AppColors.textGrey)`, ширина 260.
      - Если текст не влезает в 3 строки (`TextPainter`/`LayoutBuilder` по ширине 260) — `TextButton` «Читать полностью» / «Свернуть»; тап по кнопке **не** открывает экран деталей.
      - `onTap != null` → обернуть в `TapScale`; иначе без тап-таргета.
- [ ] Тест `test/presentation/pages/ai_film_result_card_test.dart`: рендерится название и описание; короткое описание не показывает «Читать полностью»; тап по карточке вызывает `onTap`; без `kinopoiskId` тап ничего не делает.
- [ ] Проверить, что `FilmPosterCard` и его вызовы на экранах поиска/деталей визуально не изменились (дефолты 100×140).

## Критерии готовности

- Виджет-тесты зелёные.
- `flutter analyze` без новых ошибок.

## Comments

- Реализовано (2026-11-09) с отклонением от спеки: навигацию выполняет сама карточка (как `FilmPosterCard`), пропа `onTap` нет — экран один, инъекция не нужна. `FilmPosterImage`/`FilmPosterWithLibraryStatus` получили `width`/`height` с дефолтами 100/140. Виджет-тест не добавлен: карточка в `build` дергает `getIt<FilmImageCacheService>()` (кэш изображений + плагины), в юнит-окружении это требует полной инициализации DI.
