import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';


class FilmImageCacheService {
  static const key = 'filmImageCache';
  static const indexFileName = 'index.json';
  static const stalePeriod = Duration(days: 7);
  static const maxNrOfCacheObjects = 50;

  static const _layoutVersion = '2';
  static const _layoutMarkerFileName = 'filmImageCache.layout';

  static const _legacyIndexFileName = 'filmImageCache.json';

  final Directory cacheRoot;

  final Directory supportRoot;

  final CacheManager instance;

  FilmImageCacheService({
    required this.cacheRoot,
    required this.supportRoot,
    @visibleForTesting CacheManager? cacheManager,
  }) : instance = cacheManager ??
            CacheManager(
              Config(
                key,
                stalePeriod: stalePeriod,
                maxNrOfCacheObjects: maxNrOfCacheObjects,
                repo: JsonCacheInfoRepository(
                  path: '${cacheRoot.path}/$indexFileName',
                ),
                fileService: HttpFileService(),
              ),
            );

  File get _indexFile => File('${cacheRoot.path}/$indexFileName');

  Future<void> init() async {
    try {
      await _ensureLayout();
      await _healIndexWithoutFiles();
    } catch (error, stackTrace) {
      _log('Не удалось подготовить кэш', error, stackTrace);
    }
  }

  Future<int> getCacheSizeBytes() async {
    if (!await cacheRoot.exists()) return 0;

    int totalSize = 0;

    await for (final entity in cacheRoot.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File || _isIndexFile(entity)) continue;
      totalSize += await entity.length();
    }

    return totalSize;
  }

  Future<void> clearCache() async {
    await instance.emptyCache();
    await _deleteCacheContents();
  }

  Future<void> _deleteCacheContents() async {
    if (!await cacheRoot.exists()) return;

    await for (final entity in cacheRoot.list(followLinks: false)) {
      await entity.delete(recursive: true);
    }
  }

  Future<void> _ensureLayout() async {
    final marker = File('${supportRoot.path}/$_layoutMarkerFileName');

    if (await marker.exists() && await marker.readAsString() == _layoutVersion) {
      return;
    }

    if (await cacheRoot.exists()) {
      await cacheRoot.delete(recursive: true);
    }

    final legacyIndex = File('${supportRoot.path}/$_legacyIndexFileName');
    if (await legacyIndex.exists()) {
      await legacyIndex.delete();
    }

    if (!await supportRoot.exists()) {
      await supportRoot.create(recursive: true);
    }
    await marker.writeAsString(_layoutVersion);
  }

  @visibleForTesting
  Future<bool> shouldResetIndex() async {
    if (!await _indexFile.exists()) return false;
    return !await _hasAnyCachedFile();
  }

  Future<void> _healIndexWithoutFiles() async {
    if (!await shouldResetIndex()) return;

    await instance.emptyCache();
  }

  Future<bool> _hasAnyCachedFile() async {
    if (!await cacheRoot.exists()) return false;

    await for (final entity in cacheRoot.list(followLinks: false)) {
      if (entity is File && !_isIndexFile(entity)) return true;
    }
    return false;
  }

  bool _isIndexFile(File file) {
    return file.parent.path == cacheRoot.path &&
        file.path.endsWith('${Platform.pathSeparator}$indexFileName');
  }

  void _log(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('[FilmImageCacheService] $message: $error\n$stackTrace');
  }
}
