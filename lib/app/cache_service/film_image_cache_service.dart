import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Кэш сетевых постеров (результаты поиска, рекомендации AI-Ассистента).
///
/// Индекс кэша лежит внутри его каталога, а не в app-support: файлы и записи
/// о них живут и стираются вместе. Пока индекс лежал отдельно, «Очистить
/// кэш» на устройстве (или сама система) убирал файлы, оставляя записи, и
/// приложение отдавало битые постеры до истечения [stalePeriod].
///
/// Кэш — это disposable-данные: при смене раскладки он выбрасывается целиком.
/// Постеры сохранённых фильмов лежат в `<documents>/films/...` и кэшем не
/// являются.
class FilmImageCacheService {
  static const key = 'filmImageCache';
  static const indexFileName = 'index.json';
  static const stalePeriod = Duration(days: 7);
  static const maxNrOfCacheObjects = 50;

  /// Версия раскладки кэша. Меняется, когда индекс переезжает или меняет
  /// формат; при запуске со старой версией кэш сбрасывается.
  static const _layoutVersion = '2';
  static const _layoutMarkerFileName = 'filmImageCache.layout';

  /// Индекс старой схемы, который лежал в app-support.
  static const _legacyIndexFileName = 'filmImageCache.json';

  /// Каталог кэша. Должен совпадать с каталогом, в который пишет
  /// [CacheManager] — то есть `<temporary>/filmImageCache`.
  final Directory cacheRoot;

  /// Каталог, где лежал индекс до схемы 2 (app-support).
  final Directory supportRoot;

  final CacheManager instance;

  /// [cacheManager] подставляется только в тестах: так проверка работает с
  /// уже открытым индексом, без гонки между созданием и удалением каталога.
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

  /// Приводит кэш к текущей раскладке. Ошибки только логируются: сломанный
  /// кэш не должен мешать приложению запуститься.
  Future<void> init() async {
    try {
      await _ensureLayout();
      await _healIndexWithoutFiles();
    } catch (error, stackTrace) {
      _log('Не удалось подготовить кэш', error, stackTrace);
    }
  }

  /// Сколько байт занято файлами кэша. Сам индекс не считается: иначе размер
  /// никогда не был бы нулевым и «Очистить кэш» не работал бы.
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
    // Сначала записи, потом файлы: если приложение упадёт между шагами, не
    // останется индекса, который врёт про несуществующие файлы.
    await instance.emptyCache();

    // Каталог остаётся: [CacheManager] держит путь к индексу и через несколько
    // секунд после очистки дописывает его. Удалённый каталог превращал эту
    // запись в необработанное исключение (PathNotFoundException) и вешал
    // приложение в отладке.
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

    // Проще выбросить кэш, чем переносить индекс и надеяться, что он
    // совпадает с файлами: повторная загрузка постеров — не потеря данных.
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

  /// Страховка от «индекс остался, файлов нет»: такие записи отдают битые
  /// постеры, поэтому кэш нужно обнулить.
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

  /// Пути приходится сравнивать по разделителю платформы: `File.path` из
  /// списка каталога и путь, собранный вручную, дают разный вид на Windows.
  bool _isIndexFile(File file) {
    return file.parent.path == cacheRoot.path &&
        file.path.endsWith('${Platform.pathSeparator}$indexFileName');
  }

  void _log(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('[FilmImageCacheService] $message: $error\n$stackTrace');
  }
}
