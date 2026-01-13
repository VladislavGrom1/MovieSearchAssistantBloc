import 'package:auto_route/auto_route.dart';
import 'package:movie_search_assistant_bloc/core/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/features/filter_film/presentation/pages/filter_film_screen.dart';

abstract class SearchFilmRoutes {
  static final routes = AutoRoute(
    page: SearchFilmWrapperRoute.page,
    children: [
      AutoRoute(
        page: SearchFilmRoute.page, 
        initial: true, 
      ),
      AutoRoute(page: FilterFilmRoute.page),
      AutoRoute(page: FilterListRoute.page),
      AutoRoute(page: SearchedFilmsRoute.page),
      AutoRoute(page: FilmInformationRoute.page),
    ],
  );
}