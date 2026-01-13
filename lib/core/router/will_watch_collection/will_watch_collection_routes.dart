import 'package:auto_route/auto_route.dart';
import 'package:movie_search_assistant_bloc/core/router/app_router.gr.dart';

abstract class WillWatchCollectionRoutes {
  static final routes = AutoRoute(
    page: WillWatchCollectionWrapperRoute.page,
    children: [
      AutoRoute(page: WillWatchCollectionRoute.page, initial: true),
      AutoRoute(page: FilmInformationRoute.page),
    ],
  );
}