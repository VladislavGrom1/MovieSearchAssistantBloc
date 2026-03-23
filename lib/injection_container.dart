import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_search_assistant_bloc/app/api/dio_api_client.dart';
import 'package:movie_search_assistant_bloc/app/util/cache_manager/film_image_cache_manager.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/collection_local_data_source.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/film_collection_link_local_data_source.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/flim_local_data_source.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/hive_init.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/user_local_data_source.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/film_remote_data_source.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/user_remote_data_source.dart';
import 'package:movie_search_assistant_bloc/data/repository_impl/collection_repository_impl.dart';
import 'package:movie_search_assistant_bloc/data/repository_impl/film_collection_repository_impl.dart';
import 'package:movie_search_assistant_bloc/data/repository_impl/film_repository_impl.dart';
import 'package:movie_search_assistant_bloc/data/repository_impl/user_repository_impl.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/user_repository.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/add_film_to_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/authentication_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/add_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/clear_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_collections_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_collections_films_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_film_images_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_film_information_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_saved_film_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_saved_films_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_film_from_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/rename_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/search_collection_films_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/search_filter_films_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/update_saved_film_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_collections_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_collection_films_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_links_by_film_use_case.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collection_films/collection_films_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collections/collections_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/film_information/film_information_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/filter_film/filter_film_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/search_films_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/searched_films/searched_films_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/user_authentication/authentication_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/user_profile/user_profile_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {

    await HiveInit.init();

    // LocalDataSources
    getIt.registerLazySingleton(() => UserLocalDataSource());
    getIt.registerLazySingleton(() => FilmLocalDataSource());
    getIt.registerLazySingleton(() => CollectionLocalDataSource());
    getIt.registerLazySingleton(() => FilmCollectionLinkLocalDataSource());
    
    // API Client
    getIt.registerSingleton(DioApiClient());
    getIt.registerSingleton(getIt<DioApiClient>().dio);

    // RemoteDataSources
    getIt.registerLazySingleton(() => UserRemoteDataSource(dio: getIt()));
    getIt.registerLazySingleton(() => FilmRemoteDataSource(dio: getIt()));

    // Repositories
    getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(userApiService: getIt(), userLocalStorage: getIt()));
    getIt.registerLazySingleton<FilmRepository>(() => FilmRepositoryImpl(filmRemoteDataSource: getIt(), filmLocalDataSource: getIt()));
    getIt.registerLazySingleton<CollectionRepository>(() => CollectionRepositoryImpl(collectionLocalDataSource: getIt()));
    getIt.registerLazySingleton<FilmCollectionRepository>(() => FilmCollectionRepositoryImpl(filmCollectionLinkLocalDataSource: getIt()));

    // UseCases
    getIt.registerLazySingleton(() => AuthenticationUseCase(userRepository: getIt(), apiClient: getIt()));
    getIt.registerLazySingleton(() => GetCollectionsFilmsUseCase(userRepository: getIt(), filmRepository: getIt(), apiClient: getIt()));
    getIt.registerLazySingleton(() => SearchFilterFilmsUseCase(userRepository: getIt(), filmRepository: getIt(), apiClient: getIt()));
    getIt.registerLazySingleton(() => SearchCollectionFilmsUseCase(userRepository: getIt(), filmRepository: getIt(), apiClient: getIt()));
    getIt.registerLazySingleton(() => GetFilmInformationUseCase(userRepository: getIt(), filmRepository: getIt(), filmCollectionRepository: getIt(), apiClient: getIt()));
    getIt.registerLazySingleton(() => GetFilmImagesUseCase(userRepository: getIt(), filmRepository: getIt(), apiClient: getIt()));
    getIt.registerLazySingleton(() => GetSavedFilmsUseCase(filmRepository: getIt(), filmCollectionRepository: getIt()));
    getIt.registerLazySingleton(() => GetSavedFilmUseCase(filmRepository: getIt(), filmCollectionRepository: getIt()));
    getIt.registerLazySingleton(() => AddFilmToCollectionUseCase(filmRepository: getIt(), filmCollectionRepository: getIt()));
    getIt.registerLazySingleton(() => UpdateSavedFilmUseCase(filmRepository: getIt()));
    getIt.registerLazySingleton(() => RemoveFilmFromCollectionUseCase(filmRepository: getIt(), filmCollectionRepository: getIt()));
    getIt.registerLazySingleton(() => GetCollectionsUseCase(collectionRepository: getIt()));
    getIt.registerLazySingleton(() => AddCollectionUseCase(collectionRepository: getIt()));
    getIt.registerLazySingleton(() => RemoveCollectionUseCase(collectionRepository: getIt(), filmRepository: getIt(), filmCollectionRepository: getIt()));
    getIt.registerLazySingleton(() => ClearCollectionUseCase(filmRepository: getIt(), filmCollectionRepository: getIt()));
    getIt.registerLazySingleton(() => RenameCollectionUseCase(collectionRepository: getIt()));
    getIt.registerLazySingleton(() => WatchLinksByFilmUseCase(filmCollectionRepository: getIt()));
    getIt.registerLazySingleton(() => WatchCollectionFilmsUseCase(filmRepository: getIt(), filmCollectionRepository: getIt()));
    getIt.registerLazySingleton(() => WatchCollectionsUseCase(collectionRepository: getIt(), filmCollectionRepository: getIt()));

    // Blocs
    getIt.registerFactory(() => AuthenticationBloc(authenticationUseCase: getIt()));
    getIt.registerFactory(() => SearchFilmsBloc(displayFilmCollectionsUseCase: getIt()));
    getIt.registerFactory(() => SearchedFilmsBloc(searchFilterFilmsUseCase: getIt(), searchCollectionFilmsUseCase: getIt()));
    getIt.registerFactory(() => FilterFilmBloc());
    getIt.registerFactory(() => FilmInformationBloc(
      getFilmInformationUseCase: getIt(),
      getSavedFilmUseCase: getIt(), 
      getFilmImagesUseCase: getIt(),
      addFilmToCollectionUseCase: getIt(),
      updateSavedFilmUseCase: getIt(),
      removeFilmFromCollectionUseCase: getIt(),
      watchLinksByFilmUseCase: getIt()
    ));
    getIt.registerFactory(() => CollectionsBloc(
      getCollectionsUseCase: getIt(), 
      addCollectionUseCase: getIt(), 
      removeCollectionUseCase: getIt(),
      watchCollectionsUseCase: getIt(),
      clearCollectionUseCase: getIt(),
      renameCollectionUseCase: getIt()
    ));
    getIt.registerFactory(() => CollectionFilmsBloc(
      getSavedFilmsUseCase: getIt(),
      removeFilmFromCollectionUseCase: getIt(), 
      watchFilmsUseCase: getIt()
    ));
    getIt.registerFactory(() => UserProfileBloc());
}