import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/file_service/file_service.dart';
import 'package:movie_search_assistant_bloc/data/models/export_data_model.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImportLibraryUseCase {
  final FileService fileService;
  final FilmRepository filmRepository;
  final CollectionRepository collectionRepository;
  final FilmCollectionRepository filmCollectionRepository;

  ImportLibraryUseCase({
    required this.fileService,
    required this.filmRepository,
    required this.collectionRepository,
    required this.filmCollectionRepository,
  });

  Future<bool?> call({Function(int current, int total)? onProgress}) async {
    try {
      final zipFile = await fileService.pickZipFile();
      if (zipFile == null) return null;

      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final tempDir = await getTemporaryDirectory();
      final extractDir = Directory(
        p.join(tempDir.path, "import_${DateTime.now().millisecondsSinceEpoch}"),
      );

      await extractDir.create(recursive: true);

      /// ---------- 1. РАСПАКОВКА ----------
      for (final file in archive) {
        final filePath = p.join(extractDir.path, file.name);

        if (file.isFile) {
          final outFile = File(filePath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(filePath).create(recursive: true);
        }
      }

      /// ---------- 2. ЧТЕНИЕ JSON ----------
      final jsonFile = File(p.join(extractDir.path, "data.json"));
      if (!await jsonFile.exists()) {
        throw Exception("data.json not found");
      }

      final jsonString = await jsonFile.readAsString();
      final jsonMap = jsonDecode(jsonString);
      final exportData = ExportDataModel.fromJson(jsonMap);

      /// ---------- 3. ПОДГОТОВКА ДАННЫХ ----------
      final appDir = await getApplicationDocumentsDirectory();
      final filmsDir = Directory('${appDir.path}/films');

      if (!await filmsDir.exists()) {
        await filmsDir.create(recursive: true);
      }

      final importedFilmsDir = Directory(p.join(extractDir.path, "images"));

      final imageDirs = (await importedFilmsDir.exists())
        ? (await importedFilmsDir
            .list()
            .where((e) => e is Directory)
            .cast<Directory>()
            .toList())
        : <Directory>[];

      /// ---------- 4. TOTAL ----------
      int currentStep = 0;

      final totalSteps =
          archive.length +
          imageDirs.length +
          exportData.films.length +
          exportData.collections.length +
          exportData.links.length;

      void step() {
        currentStep++;
        onProgress?.call(currentStep, totalSteps);
      }

      /// ---------- 5. РАСПАКОВКА С ПРОГРЕССОМ ----------
      for (final file in archive) {
        final filePath = p.join(extractDir.path, file.name);

        if (file.isFile) {
          final outFile = File(filePath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(filePath).create(recursive: true);
        }

        step();
        await Future.delayed(const Duration(milliseconds: 1));
      }

      /// ---------- 6. КОПИРОВАНИЕ КАРТИНОК ----------
      for (final entity in imageDirs) {
        final filmId = p.basename(entity.path);
        final targetDir = Directory('${filmsDir.path}/$filmId');

        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }

        for (final file in entity.listSync()) {
          if (file is File) {
            final fileName = p.basename(file.path);
            final newPath = '${targetDir.path}/$fileName';

            final newFile = File(newPath);
            if (!await newFile.exists()) {
              await file.copy(newPath);
            }
          }
        }

        step();
        await Future.delayed(const Duration(milliseconds: 1));
      }

      /// ---------- 7. ФИЛЬМЫ ----------
      for (final film in exportData.films) {
        final exists = await filmRepository.filmIsSaved(
          film.filmBaseModel.kinopoiskId!,
        );

        if (!exists) {
          await filmRepository.addFilmInLocalDataSource(film);
        }

        step();
        await Future.delayed(const Duration(milliseconds: 1));
      }

      /// ---------- 8. КОЛЛЕКЦИИ ----------
      for (final collection in exportData.collections) {
        final exists =
            await collectionRepository.collectionIsExist(collection.id!);

        if (!exists) {
          await collectionRepository.addCollection(collection);
        }

        step();
      }

      /// ---------- 9. СВЯЗИ ----------
      final existingLinks =
          await filmCollectionRepository.getAllFilmCollectionLinks();

      for (final link in exportData.links) {
        final exists = existingLinks.any((e) =>
            e.filmId == link.filmId &&
            e.collectionId == link.collectionId);

        if (!exists) {
          await filmCollectionRepository.addFilmCollectionLink(link);
        }

        step();
      }

      return true;
    } on LocalDataSourceException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}