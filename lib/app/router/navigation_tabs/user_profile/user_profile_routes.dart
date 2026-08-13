import 'package:auto_route/auto_route.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';

abstract class UserProfileRoutes {
  static final routes = AutoRoute(
    page: UserProfileWrapperRoute.page,
    children: [
      AutoRoute(
        page: UserProfileRoute.page, 
        initial: true, 
      )
    ],
  );
}