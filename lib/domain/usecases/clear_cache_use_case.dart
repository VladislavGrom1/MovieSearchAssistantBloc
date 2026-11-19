import 'package:movie_search_assistant_bloc/app/cache_service/film_image_cache_service.dart';

class ClearCacheUseCase {
  final FilmImageCacheService filmImageCacheService;

  const ClearCacheUseCase({required this.filmImageCacheService});

  Future<void> call() => filmImageCacheService.clearCache();
}
