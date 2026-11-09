# 08. Кодогенерация и финальная проверка

Status: ready-for-agent
Type: task
Blocked by: 06, 07

## Контекст

Спека: `.scratch/ai-tab/spec.md`, раздел 8. `auto_route_generator` закомментирован в `pubspec.yaml:14-18`, поэтому маршруты `AiFilmsRoute`/`AiFilmsWrapperRoute` сами не появятся.

## Что сделать

Генерацию запускает пользователь, агент только готовит источники и проверяет результат.

- [ ] Убедиться, что все аннотированные `@RoutePage()` файлы на месте (`AiFilmsScreen`, `AiFilmsWrapperScreen`).
- [ ] Выдать пользователю точную последовательность:
      1. закомментировать в `pubspec.yaml` строки `flutter_bloc`, `flutter_test`, `hive_generator`;
      2. `dart run build_runner build --delete-conflicting-outputs --build-filter="lib/app/router/*.dart"`;
      3. вернуть `pubspec.yaml` в исходное состояние (`git diff pubspec.yaml` должен быть пуст).
- [ ] После генерации проверить, что `lib/app/router/app_router.gr.dart` содержит `AiFilmsRoute` и `AiFilmsWrapperRoute`.
- [ ] Прогнать `scripts/flutter_analyze.sh` (или `flutter analyze`) — новых `error •` нет.
- [ ] Прогнать `flutter test` — все тесты из тикетов 01–07 зелёные.
- [ ] Ручная проверка по чек-листу спеки, раздел 9: пустой ввод, загрузка, успех, пустой ответ, `404`, `502`, обрыв сети, переключение вкладок, тап по карточке, фильм без `kinopoiskId`.

## Критерии готовности

- `app_router.gr.dart` обновлён и закоммичен вместе с фичей.
- `pubspec.yaml` без диффа.
- Чек-лист спеки пройден целиком.

## Comments

- Готово к запуску (2026-11-09): анализ `lib` даёт только 3 ожидаемые ошибки `undefined_identifier`/`undefined_method` для `AiFilmsRoute`/`AiFilmsWrapperRoute`. Юнит-тесты 01–04 (23 шт.) зелёные. Кодогенерацию запускает пользователь.
- Реализовано (2026-11-09): пользователь прогнал кодогенерацию; `app_router.gr.dart` содержит `AiFilmsRoute`, `AiFilmsWrapperRoute`, `OnboardingRoute`. Побочный эффект: устаревший `UserAuthenticationRoute` из старого сгенерированного файла исчез — все ссылки переведены на `OnboardingRoute` (см. тикет 06). `flutter analyze lib test` → 0 ошибок, только 2 info про deprecated `translate`/`scale` в `film_information_screen.dart:1107-1108`. `flutter test` → 78/78 passed.
