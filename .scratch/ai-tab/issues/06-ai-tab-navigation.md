# 06. Вкладка AI: роутинг и нижняя навигация без подписей

Status: ready-for-agent
Type: task

## Контекст

Спека: `.scratch/ai-tab/spec.md`, раздел 5.5. Образец: `lib/app/router/navigation_tabs/search_film/`.

## Что сделать

- [ ] `lib/app/router/navigation_tabs/ai_films/ai_films_wrapper_screen.dart`: копия `search_film_wrapper_screen.dart:4-17` — `@RoutePage() class AiFilmsWrapperScreen extends StatelessWidget implements AutoRouteWrapper`, `build => const AutoRouter()`, `wrappedRoute => this`.
- [ ] `lib/app/router/navigation_tabs/ai_films/ai_films_routes.dart`:
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
- [ ] `lib/app/router/app_router.dart`: `AiFilmsRoutes.routes` между `SearchFilmRoutes.routes` и `CollectionsRoutes.routes`.
- [ ] `lib/presentation/pages/home_screen.dart:22-26`: `AiFilmsWrapperRoute()` вторым элементом, до `CollectionsRoute()`.
- [ ] Нижняя навигация (`home_screen.dart:43-68`): у всех четырёх элементов убрать подписи — `showSelectedLabels: false`, `showUnselectedLabels: false`, `label: null`. Иконка AI — `Icons.auto_awesome`, обёрнутая в `Tooltip(message: "AI")`; у остальных оставить текущие иконки и тоже обернуть в `Tooltip` («Поиск», «Коллекции», «Профиль»).
- [ ] `@RoutePage()` у `AiFilmsScreen` появится в тикете 07; до этого роутер компилироваться не будет — это ожидаемо, кодовую генерацию запускать после 07.

## Критерии готовности

- Порядок табов: Поиск, AI, Коллекции, Профиль.
- Подписей нет ни у выбранного, ни у невыбранных табов.
- После генерации (тикет 08) приложение собирается и AI-таб открывается без `BlocProvider`-ошибок на карточках (`WatchSavedFilmsStatusCubit` подключается в тикете 07).

## Comments

- Реализовано (2026-11-09): `AiFilmsRoutes`, `AiFilmsWrapperScreen`, вкладка вторая в `app_router.dart` и в `home_screen.dart`; все четыре таба без подписей (`showSelectedLabels/showUnselectedLabels: false`), тип переключён на `BottomNavigationBarType.fixed` ради равных иконок. Ждёт кодогенерации авто-роутов.
- Последствие кодогенерации (2026-11-09): `UserAuthenticationRoute` существовал только в устаревшем `app_router.gr.dart` (сгенерирован в коммите `e714960`, когда страница называлась `UserAuthenticationScreen`; в `642d433` переименована в `OnboardingScreen`, но `.gr.dart` не перегенерировали). Новая генерация даёт `OnboardingRoute`, поэтому ссылки заменены: `app_router.dart:27` (`page: OnboardingRoute.page`, path `/authentication` сохранён) и `authentication_guard.dart:19,24,28`.
