import 'package:auto_route/auto_route.dart';
import 'package:movie_search_assistant_bloc/core/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/core/router/user_profile/user_profile_wrapper_screen.dart';

abstract class UserProfileRoutes {
  static final routes = AutoRoute(
    page: UserProfileWrapperRoute.page,
    children: [
      AutoRoute(
        page: UserProfileRoute.page, 
        initial: true, 
      ),
      AutoRoute(page: ChangeApiKeyRoute.page),
    ],
  );
}