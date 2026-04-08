import 'package:auto_route/auto_route.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/router/auto_router_guards/authentication_guard.dart';
import 'package:movie_search_assistant_bloc/app/router/navigation_tabs/search_film/search_film_routes.dart';
import 'package:movie_search_assistant_bloc/app/router/navigation_tabs/user_profile/user_profile_routes.dart';
import 'package:movie_search_assistant_bloc/app/router/navigation_tabs/collections/collections_routes.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter{

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page, 
      path: '/',
      guards: [AuthenticationGuard()],
      children: [
        SearchFilmRoutes.routes,
        CollectionsRoutes.routes,
        UserProfileRoutes.routes
      ]
    ),
    AutoRoute(
      page: UserAuthenticationRoute.page, 
      path: '/authentication',
    ),
  ];

  @override
  RouteType get defaultRouteType => RouteType.custom(
    transitionsBuilder: TransitionsBuilders.noTransition,
  );
}