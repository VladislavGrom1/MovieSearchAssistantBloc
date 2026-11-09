import 'package:auto_route/auto_route.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';

abstract class AiFilmsRoutes {
  static final routes = AutoRoute(
    page: AiFilmsWrapperRoute.page,
    children: [
      AutoRoute(
        page: AiFilmsRoute.page,
        initial: true,
      ),
      AutoRoute(page: FilmInformationRoute.page),
    ],
  );
}
