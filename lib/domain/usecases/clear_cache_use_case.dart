import 'package:movie_search_assistant_bloc/app/cache_service/film_image_cache_service.dart';

class ClearCacheUseCase {
  final FilmImageCacheService filmImageCacheService;

  ClearCacheUseCase({required this.filmImageCacheService});

  Future<void> call() async {
    try{
      await filmImageCacheService.clearCache();
    } catch(e){
      rethrow;
    }
  }
}