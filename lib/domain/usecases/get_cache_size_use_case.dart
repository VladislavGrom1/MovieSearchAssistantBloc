import 'package:movie_search_assistant_bloc/app/cache_service/film_image_cache_service.dart';

class GetCacheSizeUseCase {
  final FilmImageCacheService filmImageCacheService;

  GetCacheSizeUseCase({required this.filmImageCacheService});

  Future<double> call() async {
    try{
      final cacheSize = await filmImageCacheService.getCacheSizeInMB();
      return cacheSize;
    } catch(e){
      rethrow;
    }
  }
}