import 'dart:convert';
import 'dart:io';
import 'package:movie_search_assistant_bloc/app/file_manager.dart/file_manager_service.dart';
import 'package:movie_search_assistant_bloc/app/file_manager.dart/zip_service.dart';
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

  ExportLibraryUseCase({
    required this.filmRepository, 
    required this.collectionRepository, 
    required this.filmCollectionRepository
  });

  Future<String?> call() async {
    try{
      final filmEntities = await filmRepository.getAllFilmsFromLocalDataSource();
      final collectionEntities = await collectionRepository.getAllCollections();
      final links = await filmCollectionRepository.getAllFilmCollectionLinks();

      if (filmEntities.isEmpty &&
          collectionEntities.isEmpty &&
          links.isEmpty) {
        return null;
      }

      final exportData = ExportDataModel(
        films: filmEntities.map((f) => FilmDetailModel.fromFilmEntity(f)).toList(),
        collections: collectionEntities.map((c) => CollectionModel.fromCollectionEntity(c)).toList(),
        links: links,
      );

      final tempDir = await getTemporaryDirectory();
      final exportDir = Directory("${tempDir.path}/export_temp");

      if (await exportDir.exists()) {
        await exportDir.delete(recursive: true);
      }
      await exportDir.create();

      final jsonFile = File("${exportDir.path}/data.json");
      final jsonString = jsonEncode(exportData.toJson());
      await jsonFile.writeAsString(jsonString);

      final imagesDir = Directory("${exportDir.path}/images");
      await imagesDir.create();

      await ImageStorageService().copyAllImagesTo(imagesDir.path);

      final zipPath = await ZipService.zipDirectory(exportDir.path);

      final zipBytes = await File(zipPath).readAsBytes();

      final date = DateTime.now();

      final savedPath = await FileManagerService.saveFile(
        zipBytes,
        "FilmLibrary_${date.day}_${date.month}_${date.year}_${date.hour}${date.minute}${date.second}.zip",
      );

      return savedPath;
    } catch(e){
      rethrow;
    }
  }
}