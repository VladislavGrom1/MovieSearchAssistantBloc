import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/image_storage_service.dart';

void main() {
  late Directory documentsRoot;
  late ImageStorageService service;

  setUp(() async {
    documentsRoot = await Directory.systemTemp.createTemp('image_storage_test');
    service = ImageStorageService(documentsRoot: () async => documentsRoot);
  });

  tearDown(() async {
    if (await documentsRoot.exists()) {
      await documentsRoot.delete(recursive: true);
    }
  });

  Future<File> writeFile(String relativePath, String contents) async {
    final file = File('${documentsRoot.path}/$relativePath');
    await file.parent.create(recursive: true);
    await file.writeAsString(contents);
    return file;
  }

  group('getLibrarySizeInBytes', () {
    test('без каталогов библиотеки размер нулевой', () async {
      expect(await service.getLibrarySizeInBytes(), 0);
    });

    test('считает постеры, скриншоты и обложки коллекций', () async {
      await writeFile('films/1/poster.jpg', '0123456789');
      await writeFile('films/1/screenshot_0.jpg', '01234');
      await writeFile('collections/c-1/cover_1.jpg', '0123456');

      expect(await service.getLibrarySizeInBytes(), 22);
    });

    test('не считает постеры AI-сессий: это не библиотека', () async {
      await writeFile('films/1/poster.jpg', '0123456789');
      await writeFile('sessions/7/1/poster.jpg', '0123456789012345678');

      expect(await service.getLibrarySizeInBytes(), 10);
    });

    test('считает файлы, оставшиеся без записи в базе', () async {
      await writeFile('films/404/poster.jpg', '0123');

      expect(await service.getLibrarySizeInBytes(), 4);
    });
  });
}
