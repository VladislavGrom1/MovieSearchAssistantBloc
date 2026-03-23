import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/app/util/cache_manager/film_image_cache_manager.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {

  UserProfileBloc() : super(UserProfileInitial()) {
    on<GetCacheSize>(_getCacheSize);
    on<ClearCacheDirectory>(_clearCacheDirectory);
  }

  Future<void> _getCacheSize(GetCacheSize event, Emitter emit) async {
    emit(UserProfileLoading());
    final sizeMB = await FilmImageCacheManager.getCacheSizeInMB();
    emit(CacheSizeLoaded(sizeMB: sizeMB));
  }

  Future<void> _clearCacheDirectory(ClearCacheDirectory event, Emitter emit) async {
    emit(UserProfileLoading());
    await FilmImageCacheManager.clearCache();
    final sizeMB = await FilmImageCacheManager.getCacheSizeInMB();
    log(sizeMB.toString());
    emit(CacheSizeLoaded(sizeMB: sizeMB));
  }
}


