import 'package:get_it/get_it.dart';
import 'package:movie_search_assistant_bloc/app/api/dio_api_client.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/user_local_data_source.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/film_remote_data_source.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/user_remote_data_source.dart';
import 'package:movie_search_assistant_bloc/data/repository_impl/film_repository_impl.dart';
import 'package:movie_search_assistant_bloc/data/repository_impl/user_repository_impl.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/user_repository.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/authentication_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/display_film_collections_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/display_film_information_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/search_collection_films_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/search_filter_films_use_case.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/film_information/film_information_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/filter_film/filter_film_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/search_films_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/searched_films/searched_films_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/user_authentication/authentication_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
    // API Client
    getIt.registerSingleton(DioApiClient());
    getIt.registerSingleton(getIt<DioApiClient>().dio);

    // LocalDataSource
    getIt.registerSingleton(UserLocalDataSource());
    await getIt.registerSingleton(getIt<UserLocalDataSource>().init());

    // RemoteDataSources
    getIt.registerLazySingleton(() => UserRemoteDataSource(dio: getIt()));
    getIt.registerLazySingleton(() => FilmRemoteDataSource(dio: getIt()));

    // Repositories
    getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(userApiService: getIt(), userLocalStorage: getIt()));
    getIt.registerLazySingleton<FilmRepository>(() => FilmRepositoryImpl(filmRemoteDataSource: getIt()));

    // UseCases
    getIt.registerLazySingleton(() => AuthenticationUseCase(userRepository: getIt(), apiClient: getIt()));
    getIt.registerLazySingleton(() => DisplayFilmCollectionsUseCase(userRepository: getIt(), filmRepository: getIt(), apiClient: getIt()));
    getIt.registerLazySingleton(() => SearchFilterFilmsUseCase(userRepository: getIt(), filmRepository: getIt(), apiClient: getIt()));
    getIt.registerLazySingleton(() => SearchCollectionFilmsUseCase(userRepository: getIt(), filmRepository: getIt(), apiClient: getIt()));
    getIt.registerLazySingleton(() => DisplayFilmInformationUseCase(userRepository: getIt(), filmRepository: getIt(), apiClient: getIt()));

    // Blocs
    getIt.registerFactory(() => AuthenticationBloc(authenticationUseCase: getIt()));
    getIt.registerFactory(() => SearchFilmsBloc(displayFilmCollectionsUseCase: getIt()));
    getIt.registerFactory(() => SearchedFilmsBloc(searchFilterFilmsUseCase: getIt(), searchCollectionFilmsUseCase: getIt()));
    getIt.registerFactory(() => FilterFilmBloc());
    getIt.registerFactory(() => FilmInformationBloc(displayFilmInformationUseCase: getIt()));
}