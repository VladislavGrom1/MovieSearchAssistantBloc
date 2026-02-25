import 'package:auto_route/auto_route.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';

abstract class LibraryRoutes {
  static final routes = AutoRoute(
    page: LibraryWrapperRoute.page,
    children: [
      AutoRoute(page: LibraryRoute.page, initial: true),
      AutoRoute(page: FilmInformationRoute.page),
    ],
  );
}