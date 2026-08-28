import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/clear_cache_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/clear_library_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/export_library_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_api_key_info_from_storage_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_app_info_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_cache_size_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/import_library_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/import_old_library_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/open_url_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/share_library_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/update_user_api_key_info_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/use_shared_api_key_use_case.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetApiKeyInfoFromStorageUseCase getApiKeyInfoFromStorageUseCase;
  final UpdateUserApiKeyInfoUseCase updateUserApiKeyInfoUseCase;
  final ImportLibraryUseCase importLibraryUseCase;
  final ImportOldLibraryUseCase importOldLibraryUseCase;
  final ExportLibraryUseCase exportLibraryUseCase;
  final ClearLibraryUseCase clearLibraryUseCase;
  final GetCacheSizeUseCase getCacheSizeUseCase;
  final ClearCacheUseCase clearCacheUseCase;
  final OpenUrlUseCase openUrlUseCase;
  final GetAppInfoUseCase getAppInfoUseCase;
  final ShareLibraryUseCase shareLibraryUseCase;
  final UseSharedApiKeyUseCase useSharedApiKeyUseCase;

  Timer? _cacheTimer;

  UserProfileBloc({
    required this.getApiKeyInfoFromStorageUseCase,
    required this.updateUserApiKeyInfoUseCase,
    required this.importLibraryUseCase,
    required this.importOldLibraryUseCase,
    required this.exportLibraryUseCase,
    required this.clearLibraryUseCase,
    required this.getCacheSizeUseCase,
    required this.clearCacheUseCase,
    required this.openUrlUseCase,
    required this.getAppInfoUseCase,
    required this.shareLibraryUseCase,
    required this.useSharedApiKeyUseCase
  }) : super(UserProfileInitial()) {
    on<GetUserProfileInfo>(_getUserProfileInfo);
    on<UpdateApiKey>(_updateApiKey);
    on<UseSharedApiKey>(_useSharedApiKey);
    on<ClearCacheDirectory>(_clearCacheDirectory);
    on<ClearLibrary>(_clearLibrary);
    on<ExportLibrary>(_exportLibrary);
    on<ImportLibrary>(_importLibrary);
    on<ImportOldLibrary>(_importOldLibrary);
    on<LaunchApiKeyUrl>(_launchApiKeyUrl);
    on<UpdateCacheSize>(_updateCacheSize);
    on<ShareLibrary>(_shareLibrary);
  }

  void _startCacheMonitoring() {
    _cacheTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      add(UpdateCacheSize());
    });
  }

  Future<void> _updateCacheSize(UpdateCacheSize event, Emitter emit) async {
    final currentState = state;
    if (currentState is! UserProfileLoaded) return;
    try{
      final size = await getCacheSizeUseCase.call();
      if (size != currentState.cacheSizeMB) {
        emit(currentState.copyWith(cacheSizeMB: size));
      }
    } catch(e){
      emit(UserProfileActionFailure(message: e.toString()));
      emit(currentState);
    }
  }

  Future<void> _getUserProfileInfo(GetUserProfileInfo event, Emitter emit) async {
    emit(UserProfileLoading());
    try{
      UserEntity? userEntity = await getApiKeyInfoFromStorageUseCase.call();
      double? cacheSizeMb = await getCacheSizeUseCase.call();
      Map<String, String>? appInfo = await getAppInfoUseCase.call();
      emit(UserProfileLoaded(userEntity: userEntity, cacheSizeMB: cacheSizeMb, appInfo: appInfo));
      _startCacheMonitoring();
    } on LocalDataSourceException {
      emit(UserProfileActionFailure(message: "Не удалось загрузить информацию о пользователе"));
      emit(UserProfileLoaded(userEntity: null, cacheSizeMB: null));
    } catch(e){
      emit(UserProfileActionFailure(message: e.toString()));
      emit(UserProfileLoaded(userEntity: null, cacheSizeMB: null));
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

  Future<void> _useSharedApiKey(UseSharedApiKey event, Emitter emit) async {
    final currentState = state;
    if(currentState is! UserProfileLoaded) return;
    try{
      UserEntity updatedUserEntity = await useSharedApiKeyUseCase.call();
      emit(UserProfileActionSuccess(message: "Вы вернулись на стандартный план"));
      emit(currentState.copyWith(userEntity: updatedUserEntity));
    } on LocalDataSourceException catch(e) {
      emit(UserProfileActionFailure(message: e.message));
      emit(currentState);
    } catch(e){
      emit(UserProfileActionFailure(message: "Не удалось переключиться на стандартный план"));
      emit(currentState);
    }
  }

  Future<void> _clearCacheDirectory(ClearCacheDirectory event, Emitter emit) async {
    final currentState = state;
    if(currentState is! UserProfileLoaded) return;
    try{
      final currentCache = await getCacheSizeUseCase.call();
      if(currentCache == 0){
        emit(UserProfileActionSuccess(message: "Кэш отсутствует"));
        emit(currentState);
        return;
      }
      await clearCacheUseCase.call();
      final sizeMB = await getCacheSizeUseCase.call();
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
      final result = await exportLibraryUseCase.call();
      
      if(result == "Нет сохранённых фильмов"){
        emit(UserProfileActionFailure(message: "Добавьте хотя бы 1 фильм в коллекцию"));
        emit(currentState);
        return;
      }

      if(result == ""){
        emit(UserProfileActionFailure(message: "Операция экспорта отменена"));
      } else{
        if(defaultTargetPlatform == TargetPlatform.android){
          emit(UserProfileActionSuccess(message: "Библиотека успешно сохранена в папку \"Загрузки\""));
        } else {
          emit(UserProfileActionSuccess(message: "Библиотека успешно сохранена"));
        }
      }
      emit(currentState);
    } catch(e){
      emit(UserProfileActionFailure(message: "Ошибка экспорта: ${e.toString()}"));
      emit(currentState);
    }
  }

  Future<void> _shareLibrary(ShareLibrary event, Emitter emit) async {
    final currentState = state;
    if(currentState is! UserProfileLoaded) return;
    emit(ExportInProgress());
    try{
      final result = await shareLibraryUseCase.call();

      if(result == "Нет сохранённых фильмов"){
        emit(UserProfileActionFailure(message: "Добавьте хотя бы 1 фильм в коллекцию"));
        emit(currentState);
        return;
      }

      if(result == ""){
        emit(UserProfileActionFailure(message: "Операция отменена"));
      } else{
        emit(UserProfileActionSuccess(message: "Библиотека успешно отправлена"));
      }

      emit(currentState);
    }
    catch(e){
      emit(UserProfileActionFailure(message: "Ошибка отправки: ${e.toString()}"));
      emit(currentState);
    }
  }

  Future<void> _importLibrary(ImportLibrary event, Emitter emit) async {
    final currentState = state;
    if(currentState is! UserProfileLoaded) return;
    try{
      final result = await importLibraryUseCase.call(
        onProgress: (current, total) {
          emit(ImportInProgress(current: current, total: total));
        }
      );

      if(result == null){
        emit(UserProfileActionFailure(message: "Операция импорта отменена"));
        emit(currentState);
        return;
      }
      emit(UserProfileActionSuccess(message: "Данные успешно импортированы"));
      emit(currentState);
    } on RemoteDataSourceException{
      emit(UserProfileActionFailure(message: "Операция импорта прервана, требуется стабильное интернет-соединение"));
      emit(currentState);
    } on LocalDataSourceException{
      emit(UserProfileActionFailure(message: "Не удалось импортировать данные"));
      emit(currentState);
    } catch(e){
      emit(UserProfileActionFailure(message: "Не удалось импортировать данные"));
      emit(currentState);
    }
  }

  Future<void> _importOldLibrary(ImportOldLibrary event, Emitter emit) async {
    final currentState = state;
    if(currentState is! UserProfileLoaded) return;
    try{
      final result = await importOldLibraryUseCase.call(
        onProgress: (current, total) {
          emit(ImportInProgress(current: current, total: total));
        },
      );

      if(result == null){
        emit(UserProfileActionFailure(message: "Операция импорта отменена"));
        emit(currentState);
        return;
      }
      emit(UserProfileActionSuccess(message: "Данные успешно импортированы"));
      emit(currentState);
    } on RemoteDataSourceException {
      emit(UserProfileActionFailure(message: "Операция импорта прервана, требуется стабильное интернет-соединение"));
      emit(currentState);
    } on LocalDataSourceException{
      emit(UserProfileActionFailure(message: "Не удалось импортировать данные"));
      emit(currentState);
    } catch(e){
      emit(UserProfileActionFailure(message: "Не удалось импортировать данные"));
      emit(currentState);
    }
  }

  Future<void> _launchApiKeyUrl(LaunchApiKeyUrl event, Emitter emit) async {
    final currentState = state;
    try{
      final isSuccess = await openUrlUseCase.call("https://kinopoiskapiunofficial.tech/?ysclid=mo5wqs4v48720285068");
      if(!isSuccess){
        emit(UserProfileActionFailure(message: "Не удалось перейти по ссылке"));
        emit(currentState);
      }
    } catch(e){
      emit(UserProfileActionFailure(message: "Не удалось перейти по ссылке"));
      emit(currentState);
    }
  }

  @override
  Future<void> close() {
    _cacheTimer?.cancel();
    return super.close();
  }

}


