import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class FilmImageCacheService {
  static const key = 'filmImageCache';

  final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 50,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  Future<int> getCacheSize() async {
    final cacheDir = await _getCacheDirectory();
    return _getDirectorySize(cacheDir);
  }

  Future<double> getCacheSizeInMB() async {
    final bytes = await getCacheSize();
    return bytes / (1024 * 1024);
  }

  Future<void> clearCache() async {
    final cacheDir = await _getCacheDirectory();

    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }

    await instance.emptyCache();
  }

  Future<Directory> _getCacheDirectory() async {
    final dir = await getTemporaryDirectory();
    return Directory('${dir.path}/$key');
  }

  Future<int> _getDirectorySize(Directory dir) async {
    int totalSize = 0;

    if (await dir.exists()) {
      final files = dir.listSync(recursive: true, followLinks: false);

      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
    }
    return totalSize;
  }

}