
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/user_local_data_source.dart';

class AuthenticationGuard extends AutoRouteGuard{
  
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final userLocalDataSource = GetIt.instance<UserLocalDataSource>();
    try{
      final apiKeyInfo = userLocalDataSource.getUserApiKeyInfo();
      if(apiKeyInfo?.apiKey != null){
        resolver.next(true);
      } else{
        resolver.redirectUntil(
          UserAuthenticationRoute(),
        );
      }
    } on LocalDataSourceException {
      resolver.redirectUntil(
        UserAuthenticationRoute(),
      );
    } catch(e){
      resolver.redirectUntil(
        UserAuthenticationRoute(),
      );
    }
    
  }
}