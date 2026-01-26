import 'package:get_it/get_it.dart';
import 'package:movie_search_assistant_bloc/app/api/dio_api_client.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/user_local_data_source.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/user_remote_data_source.dart';
import 'package:movie_search_assistant_bloc/data/repository_impl/user_repository_impl.dart';
import 'package:movie_search_assistant_bloc/domain/repository/user_repository.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/authentication_use_case.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/user_authentication/bloc/authentication_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
    // API Client
    getIt.registerSingleton(DioApiClient());
    getIt.registerSingleton(getIt<DioApiClient>().dio);

    getIt.registerSingleton(UserLocalDataSource());
    await getIt.registerSingleton(getIt<UserLocalDataSource>().init());

    // DataSources
    getIt.registerLazySingleton(() => UserRemoteDataSource(dio: getIt()));

    // Repositories
    getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(userApiService: getIt(), userLocalStorage: getIt()));

    // UseCases
    getIt.registerLazySingleton(() => AuthenticationUseCase(userRepository: getIt(), apiClient: getIt()));

    // Blocs
    getIt.registerFactory(() => AuthenticationBloc(authenticationUseCase: getIt()));
}