import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:movie_search_assistant_bloc/app/file_service/export_destination_service.dart';
import 'package:movie_search_assistant_bloc/app/file_service/zip_service.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/image_storage_service.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:movie_search_assistant_bloc/data/models/export_data_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
 
class ExportLibraryUseCase {
  final FilmRepository filmRepository;
  final CollectionRepository collectionRepository;
  final FilmCollectionRepository filmCollectionRepository;
  final ImageStorageService imageStorageService;
  final ZipService zipService;
  final ExportDestinationService exportDestinationService;
 
  ExportLibraryUseCase({
    required this.filmRepository, 
    required this.collectionRepository, 
    required this.filmCollectionRepository,
    required this.imageStorageService,
    required this.zipService,
    required this.exportDestinationService,
  });
 
  Future<String> call() async {
    final tempDir = await getTemporaryDirectory();
    final exportDir = Directory("${tempDir.path}/export_temp");

    try {
      final filmEntities =
          await filmRepository.getAllFilmsFromLocalDataSource();

      final collectionEntities =
          await collectionRepository.getAllCollections();

      final links =
          await filmCollectionRepository.getAllFilmCollectionLinks();

      if (filmEntities.isEmpty) {
        return "Нет сохранённых фильмов";
      }

      final exportData = ExportDataModel(
        films: filmEntities
            .map((f) => FilmDetailModel.fromFilmEntity(f))
            .toList(),
        collections: collectionEntities
            .map((c) => CollectionModel.fromCollectionEntity(c))
            .toList(),
        links: links,
      );

      if (await exportDir.exists()) {
        await exportDir.delete(recursive: true);
      }

      await exportDir.create(recursive: true);

      final jsonFile = File("${exportDir.path}/data.json");

      await jsonFile.writeAsString(
        jsonEncode(exportData.toJson()),
      );

      final imagesDir = Directory("${exportDir.path}/images");

      await imagesDir.create(recursive: true);

      await imageStorageService.copyAllImagesTo(
        imagesDir.path,
      );

      final zipPath = await zipService.zipDirectory(
        exportDir.path,
      );

      log("ZIP created: $zipPath");

      final zipFile = File(zipPath);

      if (!await zipFile.exists()) {
        throw Exception(
          "ZIP файл не существует: $zipPath",
        );
      }

      final fileName = p.basename(zipPath);

      log("ZIP name: $fileName");
      log(
        "ZIP size: ${await zipFile.length()} bytes",
      );

      final result = await exportDestinationService.saveZip(
        zipPath: zipPath,
        fileName: fileName,
      );

      return result;
    } finally {
      if (await exportDir.exists()) {
        await exportDir.delete(recursive: true);
      }
    }
  }
}