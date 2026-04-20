import 'dart:convert';
import 'dart:io';
import 'package:movie_search_assistant_bloc/app/file_service/file_service.dart';
import 'package:movie_search_assistant_bloc/app/file_service/zip_service.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/image_storage_service.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:movie_search_assistant_bloc/data/models/export_data_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:path_provider/path_provider.dart';

class ExportLibraryUseCase {
  final FilmRepository filmRepository;
  final CollectionRepository collectionRepository;
  final FilmCollectionRepository filmCollectionRepository;
  final ImageStorageService imageStorageService;
  final FileService fileManagerService;
  final ZipService zipService;

  ExportLibraryUseCase({
    required this.filmRepository, 
    required this.collectionRepository, 
    required this.filmCollectionRepository,
    required this.imageStorageService,
    required this.fileManagerService,
    required this.zipService
  });

  Future<String?> call() async {
    final tempDir = await getTemporaryDirectory();
    final exportDir = Directory("${tempDir.path}/export_temp");

    try{
      final filmEntities = await filmRepository.getAllFilmsFromLocalDataSource();
      final collectionEntities = await collectionRepository.getAllCollections();
      final links = await filmCollectionRepository.getAllFilmCollectionLinks();

      if (filmEntities.isEmpty) {
        return "Нет сохранённых фильмов";
      }

      final exportData = ExportDataModel(
        films: filmEntities.map((f) => FilmDetailModel.fromFilmEntity(f)).toList(),
        collections: collectionEntities.map((c) => CollectionModel.fromCollectionEntity(c)).toList(),
        links: links,
      );

      if (await exportDir.exists()) {
        await exportDir.delete(recursive: true);
      }
      await exportDir.create();

      final jsonFile = File("${exportDir.path}/data.json");
      final jsonString = jsonEncode(exportData.toJson());
      await jsonFile.writeAsString(jsonString);

      final imagesDir = Directory("${exportDir.path}/images");
      await imagesDir.create();

      await imageStorageService.copyAllImagesTo(imagesDir.path);

      final zipPath = await zipService.zipDirectory(exportDir.path);

      final zipBytes = await File(zipPath).readAsBytes();

      await File(zipPath).delete();

      final date = DateTime.now();

      final savedPath = await fileManagerService.saveFile(
        zipBytes,
        "FilmLibrary_${date.day}_${date.month}_${date.year}_${date.hour}${date.minute}${date.second}.zip",
      );

      return savedPath;
    } catch(e){
      rethrow;
    } finally{
      if (await exportDir.exists()) {
        await exportDir.delete(recursive: true);
      }
    }
  }
}