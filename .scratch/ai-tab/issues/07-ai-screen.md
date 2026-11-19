# 07. Экран AI: поле, примеры, кнопка и все состояния

Status: ready-for-agent
Type: task
Blocked by: 04, 05, 06

## Контекст

Спека: `.scratch/ai-tab/spec.md`, разделы 5.1–5.3, 6.7. Термины «AI-запрос», «Пустой результат», «Ошибка подбора» — в `GLOSSARY.md`.

## Что сделать

- [ ] `lib/presentation/pages/ai_films_screen.dart`:
      - публичный `@RoutePage() class AiFilmsScreen` с `MultiBlocProvider`: `BlocProvider(create: (_) => getIt<AiFilmsBloc>())` и **обязательно** `BlocProvider(create: (_) => getIt<WatchSavedFilmsStatusCubit>())` — без него `FilmPosterWithLibraryStatus` падает в `BlocSelector`;
      - приватный `_AiFilmsView` с `ListView(padding: EdgeInsets.fromLTRB(16, 16, 16, 24))`.
- [ ] Шапка: «Что посмотреть?» (`m3Headline`), подпись «Опишите настроение, сюжет или жанр — подберём 5 фильмов.» (`m3Body(color: AppColors.textGrey)`).
- [ ] Поле: `TextEditingController` + `FocusNode` в `State` (сохраняются при переключении вкладок), `minLines: 3`, `maxLines: 5`, `maxLength: 200`, `TextInputAction.newline`, hint «Например: фильм про ограбление казино». Оформление — как `CustomSearchBar` (радиус 14, заливка `primaryThemeGrey` 0.55, рамка 0.12 белого, фокус `primaryScheme` + свечение).
- [ ] Чипы примеров (`Wrap`): «Фильм про ограбление казино», «Добрая комедия на вечер», «Фантастика с неожиданным финалом», «Триллер в замкнутом пространстве». Тап заполняет поле (курсор в конец), запрос не отправляет.
- [ ] Кнопка «Подобрать фильмы» (`FilledButton`, `primaryScheme`, белый текст, на всю ширину). `onPressed: null`, если `controller.text.trim().isEmpty` или состояние `AiFilmsLoading`. По нажатию — `unfocus()` и `add(AiFilmsRequested(text.trim()))`.
- [ ] `BlocBuilder<AiFilmsBloc, AiFilmsState>` для блока результатов:
      - `Initial` — иконка `movie_filter_outlined` 72, «Здесь появятся 5 фильмов», подпись;
      - `Loading` — 5 скелетонов в `Skeletonizer(enabled: true)` (постер 140×200, две строки названия, три строки описания);
      - `Loaded` — «Подборка по запросу «{query}»» (`m3Title`) и 5 `AiFilmResultCard` с `key: ValueKey(kinopoiskId)`, отступ 24; `onTap` → `context.router.push(FilmInformationRoute(filmId:, filmName: film.nameOriginal ?? ''))`, если `kinopoiskId != null`;
      - `Empty` — `search_off` 72, «Ничего не нашлось», совет переформулировать, `TextButton` «Повторить» → `AiFilmsRetryRequested`;
      - `Failure` — компактный блок: `error_outline` (`primaryScheme`), `message`, `TextButton` «Повторить» → `AiFilmsRetryRequested`.
- [ ] Виджет-тесты `test/presentation/pages/ai_films_screen_test.dart` (мок BLoC через `bloc_test`/ручной stub): пустой ввод → кнопка неактивна; у каждого состояния рисуется ожидаемый текст; «Повторить» добавляет `AiFilmsRetryRequested`.

## Критерии готовности

- Все состояния из спеки 5.3 достижимы и выглядят по описанию.
- Переключение на другую вкладку и обратно сохраняет текст поля и результаты.
- `flutter test` по новым тестам зелёный, `flutter analyze` без новых ошибок.

## Comments

- Реализовано (2026-11-09): `AiFilmsScreen` — поле (2–4 строки, счётчик 200), кнопка со спиннером и блокировкой, 5 состояний, скелетоны 5 карточек, чипы-примеры. Виджет-тесты экрана отложены до кодогенерации роутов.
- Багфикс (2026-11-09): при нажатии «Повторить» без интернета экран на один кадр подменялся заглушками (`_load` эмитил `AiFilmsLoading`, `_Results` рисовал по нему скелетоны). Причина подтверждена red-тестом `test/presentation/widget/ai_films_retry_flash_test.dart`. Фикс: `isRetrying` в базовом состоянии, повтор эмитит копию `Failure`/`Empty` с флагом и не эмитит `Loading`; `_MessageArea` показывает спиннер вместо «Повторить», кнопка «Подобрать» блокируется. `flutter analyze` — 0 ошибок, `flutter test` — 80/80.
- Сброс (2026-11-09): в шапке справа появилась `TextButton.icon(Icons.restart_alt, «Сбросить»)`, скрытая в `Initial` с пустым полем. Нажатие чистит контроллер, снимает фокус и шлёт `AiFilmsResetRequested`; BLoC увеличивает `_requestToken` и эмитит `AiFilmsInitial`, поэтому поздний ответ летевшего запроса отбрасывается (`_isActual`). Тесты: 4 bloc + 4 widget (`test/presentation/widget/ai_films_reset_test.dart`), `flutter test` — 88/88, `flutter analyze` — 0 ошибок.
