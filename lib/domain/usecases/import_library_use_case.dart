import 'dart:convert';
import 'dart:io';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/file_service/file_service.dart';
import 'package:movie_search_assistant_bloc/app/file_service/import_data_migrator.dart';
import 'package:movie_search_assistant_bloc/app/file_service/zip_service.dart';
import 'package:movie_search_assistant_bloc/data/models/export_data_model.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImportLibraryUseCase {
  final FileService fileService;
  final ZipService zipService;
  final FilmRepository filmRepository;
  final CollectionRepository collectionRepository;
  final FilmCollectionRepository filmCollectionRepository;

  final ImportDataMigrator _migrator = ImportDataMigrator();
 
  ImportLibraryUseCase({
    required this.fileService,
    required this.zipService,
    required this.filmRepository,
    required this.collectionRepository,
    required this.filmCollectionRepository,
  });
 
  Future<bool?> call({Function(int current, int total)? onProgress}) async {
    final tempDir = await getTemporaryDirectory();
    final extractDir = Directory(
      p.join(tempDir.path, "import_${DateTime.now().millisecondsSinceEpoch}"),
    );
 
    try {
      final zipFile = await fileService.pickZipFile();
      if (zipFile == null) return null;
 
      await extractDir.create(recursive: true);
 
      await zipService.unzipToDirectory(zipFile.path, extractDir.path);
 
      final jsonFile = File(p.join(extractDir.path, "data.json"));
      if (!await jsonFile.exists()) {
        throw Exception("data.json not found");
      }
 
      final jsonString = await jsonFile.readAsString();
      final jsonMap = jsonDecode(jsonString);

      final migratedJson = await _migrator.migrate(jsonMap, extractDir);

      final exportData = ExportDataModel.fromJson(migratedJson);
 
      final appDir = await getApplicationDocumentsDirectory();
      final importedImagesDir = Directory(p.join(extractDir.path, "images"));

      final categoryDirs = (await importedImagesDir.exists())
        ? (await importedImagesDir
            .list()
            .where((e) => e is Directory)
            .cast<Directory>()
            .toList())
        : <Directory>[];

      final entityDirs = <MapEntry<String, Directory>>[];
      for (final categoryDir in categoryDirs) {
        final category = p.basename(categoryDir.path);
        final entities = await categoryDir
            .list()
            .where((e) => e is Directory)
            .cast<Directory>()
            .toList();
        for (final entityDir in entities) {
          entityDirs.add(MapEntry(category, entityDir));
        }
      }
 
      int currentStep = 0;
 
      final totalSteps =
          1 +
          entityDirs.length +
          exportData.films.length +
          exportData.collections.length +
          exportData.links.length;
 
      void step() {
        currentStep++;
        onProgress?.call(currentStep, totalSteps);
      }
 
      step();
 
      for (final entry in entityDirs) {
        final category = entry.key;
        final entityDir = entry.value;
        final entityId = p.basename(entityDir.path);
        
        if (category.contains('..') || entityId.contains('..')) continue;

        final targetDir = Directory(p.join(appDir.path, category, entityId));
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }

        final existingFiles = <String>{};
        if (await targetDir.exists()) {
          await for (final f in targetDir.list()) {
            if (f is File) existingFiles.add(p.basename(f.path));
          }
        }

        await for (final file in entityDir.list()) {
          if (file is File) {
            final fileName = p.basename(file.path);
            
            if (!existingFiles.contains(fileName)) {
              await file.copy(p.join(targetDir.path, fileName));
            }
          }
        }
        
        step();
        if (currentStep % 10 == 0) await Future.delayed(const Duration(milliseconds: 1));
      }
 
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
 
      for (final collection in exportData.collections) {
        final exists =
            await collectionRepository.collectionIsExist(collection.id!);
 
        if (!exists) {
          await collectionRepository.addCollection(collection);
        }
 
        step();
      }
 
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
    } finally {
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
    }
  }
}