import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:media_store_plus/media_store_plus.dart';
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
  final MediaStore mediaStore;
 
  ExportLibraryUseCase({
    required this.filmRepository, 
    required this.collectionRepository, 
    required this.filmCollectionRepository,
    required this.imageStorageService,
    required this.zipService,
    required this.mediaStore,
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

      final saveInfo = await mediaStore.saveFile(
        tempFilePath: zipPath,
        dirType: DirType.download,
        dirName: DirName.download,
      );

      log("saveInfo: $saveInfo");

      if (saveInfo != null) {
        log(
          "Saved URI: ${saveInfo.uri}",
        );

        log(
          "Saved name: ${saveInfo.name}",
        );

        log(
          "Save status: ${saveInfo.saveStatus}",
        );

        return saveInfo.uri.toString();
      }

      final exists = await mediaStore.isFileExist(
        fileName: fileName,
        dirType: DirType.download,
        dirName: DirName.download,
      );

      log(
        "File exists after saveFile: $exists",
      );

      if (exists) {
        final uri = await mediaStore.getFileUri(
          fileName: fileName,
          dirType: DirType.download,
          dirName: DirName.download,
        );

        if (uri != null) {
          log(
            "Recovered URI: $uri",
          );

          return uri.toString();
        }
      }

      throw Exception(
        "MediaStore не смог подтвердить сохранение файла",
      );
    } finally {
      if (await exportDir.exists()) {
        await exportDir.delete(recursive: true);
      }
    }
  }
}