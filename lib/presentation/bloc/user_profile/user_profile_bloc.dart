import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/cache_service/film_image_cache_service.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/clear_library_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/export_library_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_api_key_info_from_storage_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_collections_films_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/update_user_api_key_info_use_case.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetApiKeyInfoFromStorageUseCase getApiKeyInfoFromStorageUseCase;
  final UpdateUserApiKeyInfoUseCase updateUserApiKeyInfoUseCase;
  final ExportLibraryUseCase exportLibraryUseCase;
  final ClearLibraryUseCase clearLibraryUseCase;

  UserProfileBloc({
    required this.getApiKeyInfoFromStorageUseCase,
    required this.updateUserApiKeyInfoUseCase,
    required this.exportLibraryUseCase,
    required this.clearLibraryUseCase
  }) : super(UserProfileInitial()) {
    on<GetUserProfileInfo>(_getUserProfileInfo);
    on<UpdateUserProfileInfo>(_updateUserProfileInfo);
    on<UpdateApiKey>(_updateApiKey);
    on<ClearCacheDirectory>(_clearCacheDirectory);
    on<ClearLibrary>(_clearLibrary);
    on<ExportLibrary>(_exportLibrary);
  }

  Future<void> _getUserProfileInfo(GetUserProfileInfo event, Emitter emit) async {
    emit(UserProfileLoading());
    try{
      UserEntity? userEntity = await getApiKeyInfoFromStorageUseCase.call();
      double? cacheSizeMb = await FilmImageCacheService.getCacheSizeInMB();
      emit(UserProfileLoaded(userEntity: userEntity, cacheSizeMB: cacheSizeMb));
    } on LocalDataSourceException {
      emit(UserProfileActionFailure(message: "Не удалось загрузить информацию о пользователе"));
      emit(UserProfileLoaded(userEntity: null, cacheSizeMB: null));
    } catch(e){
      emit(UserProfileActionFailure(message: e.toString()));
      emit(UserProfileLoaded(userEntity: null, cacheSizeMB: null));
    }
  }

  Future<void> _updateUserProfileInfo(UpdateUserProfileInfo event, Emitter emit) async {
    final currentState = state;
    if(currentState is! UserProfileLoaded) return;
    emit(UserProfileLoading());
    try{
      UserEntity? updatedUserEntity = await updateUserApiKeyInfoUseCase.call(apiKey: currentState.userEntity?.apiKey ?? "");
      double? cacheSizeMb = await FilmImageCacheService.getCacheSizeInMB();
      emit(currentState.copyWith(userEntity: updatedUserEntity, cacheSizeMB: cacheSizeMb)); 
    } on RemoteDataSourceException catch(e) {
      emit(UserProfileActionFailure(message: e.message));
      emit(currentState);
    } on LocalDataSourceException {
      emit(UserProfileActionFailure(message: "Не удалось обновить информацию о пользователе"));
      emit(currentState);
    } catch(e){
      emit(UserProfileActionFailure(message: e.toString()));
      emit(currentState);
    }
  }

  Future<void> _updateApiKey(UpdateApiKey event, Emitter emit) async {
    final currentState = state;
    if(currentState is! UserProfileLoaded) return;
    try{
      UserEntity? updatedUserEntity = await updateUserApiKeyInfoUseCase.call(apiKey: event.updatedApiKey);
      emit(UserProfileActionSuccess(message: "API Key успешно обновлён"));
      emit(currentState.copyWith(userEntity: updatedUserEntity));
    } on RemoteDataSourceException catch(e) {
      emit(UserProfileActionFailure(message: e.message));
      emit(currentState);
    } on LocalDataSourceException catch(e) {
      emit(UserProfileActionFailure(message: e.toString()));
      emit(currentState);
    } catch(e){
      emit(UserProfileActionFailure(message: e.toString()));
      emit(currentState);
    }
  }

  Future<void> _clearCacheDirectory(ClearCacheDirectory event, Emitter emit) async {
    final currentState = state;
    if(currentState is! UserProfileLoaded) return;
    emit(UserProfileLoading());
    try{
      final currentCache = await FilmImageCacheService.getCacheSizeInMB();
      if(currentCache == 0){
        emit(UserProfileActionSuccess(message: "Кэш отсутствует"));
        emit(currentState);
        return;
      }
      await FilmImageCacheService.clearCache();
      final sizeMB = await FilmImageCacheService.getCacheSizeInMB();
      emit(UserProfileActionSuccess(message: "Очищено ${currentCache.toStringAsFixed(1)} МБ"));
      emit(currentState.copyWith(cacheSizeMB: sizeMB));
    } catch(e){
      emit(UserProfileActionFailure(message: "Не удалось очистить кэш"));
      emit(currentState);
    }
  }

  Future<void> _clearLibrary(ClearLibrary event, Emitter emit) async {
    final currentState = state;
    if(currentState is! UserProfileLoaded) return;
    emit(UserProfileLoading());
    try{
      await clearLibraryUseCase.call();
      emit(UserProfileActionSuccess(message: "Библиотека очищена"));
      emit(currentState);
    } on LocalDataSourceException{
      emit(UserProfileActionFailure(message: "Не удалось очистить библиотеку"));
      emit(currentState);
    } catch(e){
      emit(UserProfileActionFailure(message: "Не удалось очистить библиотеку"));
      emit(currentState);
    }
  }

  Future<void> _exportLibrary(ExportLibrary event, Emitter emit) async {
    final currentState = state;
    if(currentState is! UserProfileLoaded) return;
    emit(ExportInProgress());
    try{
      final path = await exportLibraryUseCase.call();
      
      if(path == "Нет сохранённых фильмов"){
        emit(UserProfileActionFailure(message: "Добавьте хотя бы 1 фильм в коллекцию"));
        emit(currentState);
        return;
      }

      if(path == "" || path == null){
        emit(UserProfileActionFailure(message: "Операция экспорта отменена"));
      } else{
        emit(UserProfileActionSuccess(message: "Библиотека успешно экспортирована в $path"));
      }
      emit(currentState);
    } catch(e){
      emit(UserProfileActionFailure(message: "Ошибка экспорта: ${e.toString()}"));
      emit(currentState);
    }
  }
}


