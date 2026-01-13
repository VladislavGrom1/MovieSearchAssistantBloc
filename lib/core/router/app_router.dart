import 'package:auto_route/auto_route.dart';
import 'package:movie_search_assistant_bloc/core/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/core/router/search_film/search_film_routes.dart';
import 'package:movie_search_assistant_bloc/core/router/user_profile/user_profile_routes.dart';
import 'package:movie_search_assistant_bloc/core/router/watched_collection/watched_collection_routes.dart';
import 'package:movie_search_assistant_bloc/core/router/will_watch_collection/will_watch_collection_routes.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter{

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: UserAuthenticationRoute.page, 
      path: '/',
    ),
    AutoRoute(
      page: HomeRoute.page, 
      path: '/home',
      children: [
        SearchFilmRoutes.routes,
        WillWatchCollectionRoutes.routes,
        WatchedCollectionRoutes.routes,
        UserProfileRoutes.routes
      ]
    ),
  ];
}