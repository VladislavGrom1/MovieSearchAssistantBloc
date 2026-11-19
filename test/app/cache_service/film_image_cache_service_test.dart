import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_assistant_bloc/app/cache_service/film_image_cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  const layoutVersion = '2';

  late Directory tempRoot;
  late Directory cacheRoot;
  late Directory supportRoot;
  late JsonCacheInfoRepository indexRepository;
  late FilmImageCacheService service;

  void mockTemporaryDirectory(Directory directory) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      pathProviderChannel,
      (call) async => directory.path,
    );
  }

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('film_image_cache_test');
    // CacheManager берёт каталог кэша из getTemporaryDirectory(), поэтому
    // подменяем плагин: он должен смотреть в тот же каталог, что и тест.
    mockTemporaryDirectory(tempRoot);
    cacheRoot = Directory('${tempRoot.path}/${FilmImageCacheService.key}');
    supportRoot = Directory('${tempRoot.path}/support');

    // Индекс открываем явно: иначе CacheManager делает это фоном, и закрытие
    // кэша может обогнать открытие.
    indexRepository = JsonCacheInfoRepository(
      path: '${cacheRoot.path}/${FilmImageCacheService.indexFileName}',
    );
    final cacheManager = CacheManager(
      Config(
        FilmImageCacheService.key,
        stalePeriod: FilmImageCacheService.stalePeriod,
        maxNrOfCacheObjects: FilmImageCacheService.maxNrOfCacheObjects,
        repo: indexRepository,
        fileService: HttpFileService(),
      ),
    );
    await indexRepository.open();

    service = FilmImageCacheService(
      cacheRoot: cacheRoot,
      supportRoot: supportRoot,
      cacheManager: cacheManager,
    );
  });

  tearDown(() async {
    // Закрытие сохраняет индекс и останавливает его таймер. Каталог кэша к
    // этому моменту может быть уже удалён — это ожидаемо.
    try {
      await service.instance.dispose();
    } catch (_) {
      // Репозиторий индекса падает, если каталог кэша уже удалён.
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  Future<File> writeFile(String relativePath, String contents) async {
    final file = File('${cacheRoot.path}/$relativePath');
    await file.parent.create(recursive: true);
    await file.writeAsString(contents);
    return file;
  }

  group('getCacheSizeBytes', () {
    test('возвращает ноль, если каталога кэша нет', () async {
      expect(await service.getCacheSizeBytes(), 0);
    });

    test('суммирует файлы вложенных каталогов и пропускает индекс', () async {
      await writeFile('a.jpg', '0123456789');
      await writeFile('nested/b.jpg', '01234');
      await writeFile(
        FilmImageCacheService.indexFileName,
        List<String>.filled(100, '0').join(),
      );

      expect(await service.getCacheSizeBytes(), 15);
    });
  });

  group('init', () {
    test('при старой раскладке выбрасывает кэш и переносит маркер', () async {
      await writeFile('old.jpg', 'poster');
      final legacyIndex =
          File('${supportRoot.path}/filmImageCache.json');
      await legacyIndex.parent.create(recursive: true);
      await legacyIndex.writeAsString('{}');

      await service.init();

      expect(await cacheRoot.exists(), isFalse);
      expect(await legacyIndex.exists(), isFalse);
      expect(
        await File('${supportRoot.path}/filmImageCache.layout').readAsString(),
        layoutVersion,
      );
    });

    test('с текущей раскладкой кэш не трогает', () async {
      await service.init();
      final cachedFile = await writeFile('kept.jpg', 'poster');

      await service.init();

      expect(await cachedFile.exists(), isTrue);
    });
  });

  group('shouldResetIndex', () {
    test('индекс без файлов — повод обнулить кэш', () async {
      await File('${cacheRoot.path}/${FilmImageCacheService.indexFileName}')
          .create(recursive: true);

      expect(await service.shouldResetIndex(), isTrue);
    });

    test('индекс рядом с файлами — всё в порядке', () async {
      await File('${cacheRoot.path}/${FilmImageCacheService.indexFileName}')
          .create(recursive: true);
      await writeFile('poster.jpg', 'poster');

      expect(await service.shouldResetIndex(), isFalse);
    });

    test('без индекса обнулять нечего', () async {
      expect(await service.shouldResetIndex(), isFalse);
    });
  });

  group('clearCache', () {
    test('удаляет и файлы, и каталог кэша', () async {
      await service.init();
      await writeFile('poster.jpg', 'poster');

      await service.clearCache();

      expect(await service.getCacheSizeBytes(), 0);
    });

    test('после очистки отложенная запись индекса не падает', () async {
      await service.init();
      await writeFile('poster.jpg', 'poster');
      await indexRepository.updateOrInsert(
        CacheObject(
          'https://example.com/poster.jpg',
          relativePath: 'poster.jpg',
          validTill: DateTime.now().add(const Duration(days: 7)),
        ),
      );

      await service.clearCache();

      // CacheManager пишет индекс с задержкой в несколько секунд. Если
      // каталог к этому моменту удалён, запись падает с PathNotFoundException:
      // необработанное исключение в таймере вешает приложение.
      await Future<void>.delayed(const Duration(seconds: 4));

      expect(await service.getCacheSizeBytes(), 0);
    });
  });
}
