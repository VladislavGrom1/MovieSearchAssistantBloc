import 'package:auto_route/auto_route.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';

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