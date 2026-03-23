import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class FilmImageCacheManager {
  static const key = 'filmImageCache';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  static Future<int> getCacheSize() async {
    final cacheDir = await _getCacheDirectory();
    return _getDirectorySize(cacheDir);
  }

  static Future<double> getCacheSizeInMB() async {
    final bytes = await getCacheSize();
    return bytes / (1024 * 1024);
  }

  static Future<void> clearCache() async {
    final cacheDir = await _getCacheDirectory();

    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }

    await instance.emptyCache();
  }

  static Future<Directory> _getCacheDirectory() async {
    final dir = await getTemporaryDirectory();
    return Directory('${dir.path}/$key');
  }

  static Future<int> _getDirectorySize(Directory dir) async {
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