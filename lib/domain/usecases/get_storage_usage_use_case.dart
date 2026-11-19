import 'package:movie_search_assistant_bloc/app/cache_service/film_image_cache_service.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/image_storage_service.dart';
import 'package:movie_search_assistant_bloc/domain/entities/storage_usage.dart';

class GetStorageUsageUseCase {
  final FilmImageCacheService filmImageCacheService;
  final ImageStorageService imageStorageService;

  const GetStorageUsageUseCase({
    required this.filmImageCacheService,
    required this.imageStorageService,
  });

  Future<StorageUsage> call() async {
    final results = await Future.wait([
      filmImageCacheService.getCacheSizeBytes(),
      imageStorageService.getLibrarySizeInBytes(),
    ]);

    return StorageUsage(
      cacheBytes: results[0],
      libraryBytes: results[1],
    );
  }
}
