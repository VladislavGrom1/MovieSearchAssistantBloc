import 'package:auto_route/auto_route.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';

abstract class CollectionsRoutes {
  static final routes = AutoRoute(
    page: CollectionWrapperRoute.page,
    children: [
      AutoRoute(page: CollectionsRoute.page, initial: true),
      AutoRoute(page: CollectionFilmsRoute.page),
      AutoRoute(page: FilmInformationRoute.page),
    ],
  );
}