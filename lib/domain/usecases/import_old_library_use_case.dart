import 'dart:convert';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/file_service/file_service.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/image_storage_service.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_base_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_collection_link.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class ImportOldLibraryUseCase {
  final FileService fileService;
  final ImageStorageService imageStorageService;
  final FilmRepository filmRepository;
  final CollectionRepository collectionRepository;
  final FilmCollectionRepository filmCollectionRepository;

  ImportOldLibraryUseCase({
    required this.imageStorageService,
    required this.fileService,
    required this.filmRepository,
    required this.collectionRepository,
    required this.filmCollectionRepository
  });

  Future<bool?> call({Function(int current, int total)? onProgress}) async {
    try{
      final file = await fileService.pickJsonFile();
      if (file == null) return null;

      final jsonString = await file.readAsString(encoding: utf8);
      final jsonData = jsonDecode(jsonString);

      if (jsonData is! List) {
        throw Exception("Old format must be List");
      }
      await _importOldFormat(jsonData, onProgress);
      return true;
    } on RemoteDataSourceException{
      rethrow;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  Future<void> _importOldFormat(List<dynamic> jsonList, Function(int current, int total)? onProgress) async {
    try{
      final total = jsonList.length;
      int current = 0;

      final collections = await _getOrCreateImportCollections();

      final plannedCollection = collections["planned"]!;
      final watchedCollection = collections["watched"]!;

      final existingLinks = await filmCollectionRepository.getAllFilmCollectionLinks();

      for (final item in jsonList) {
        current++;
        onProgress?.call(current, total);
        await Future.delayed(const Duration(milliseconds: 10));

        final filmId = item["kinopoiskId"];
        if (filmId == null) continue;

        final exists = await filmRepository.filmIsSaved(filmId);

        final status = item["watchStatus"]?.toString();

        CollectionModel targetCollection;

        if (status == "Просмотрено") {
          targetCollection = watchedCollection;
        } else {
          targetCollection = plannedCollection;
        }

        final posterUrl = item["posterUrl"];

        final screenshotsRaw = (item["imagesFilm"] as List?)?.cast<String>();

        final screenshots = screenshotsRaw
            ?.take(5)
            .map((url) => url.replaceAll("/orig", "/preview"))
            .toList();

        String? localPosterPath;
        List<String>? localScreenshots;

        if (!exists) {
          (localPosterPath, localScreenshots) =
              await imageStorageService.saveFilmImagesInDirectory(
            posterUrl,
            screenshots,
            filmId,
          );
        }

        final film = FilmDetailModel(
          filmBaseModel: FilmBaseModel(
            kinopoiskId: filmId,
            nameRu: item["nameRu"],
            nameOriginal: item["nameOriginal"],
            countries: (item["countries"] as List?)?.map((e) => e.toString()).toList(),
            genres: (item["genres"] as List?)?.map((e) => e.toString()).toList(),
            ratingKinopoisk: item["ratingKinopoisk"],
            ratingImbd: item["ratingImdb"],
            year: item["year"],
            posterUrl: posterUrl,
            userComment: null,
            userRating: null,
            localPosterImagePath: localPosterPath,
            localScreenshotPaths: localScreenshots,
          ),
          description: item["description"],
          slogan: item["slogan"],
          webUrl: item["webUrl"],
          serial: item["serial"],
          startYear: item["startYear"],
          endYear: item["endYear"],
        );

        if (!exists) {
          await filmRepository.addFilmInLocalDataSource(film);
        }

        final linkExists = existingLinks.any((e) =>
            e.filmId == filmId &&
            e.collectionId == targetCollection.id);

        if (!linkExists) {
          await filmCollectionRepository.addFilmCollectionLink(
            FilmCollectionLink(
              filmId: filmId,
              collectionId: targetCollection.id!,
            ),
          );
        }
      }
       
    } on RemoteDataSourceException{
      rethrow;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
    
  }

  Future<Map<String, CollectionModel>> _getOrCreateImportCollections() async {
    try{
      final collections = await collectionRepository.getAllCollections();

      CollectionModel? planned;
      CollectionModel? watched;

      for (final c in collections) {
        if (c.name == "Буду смотреть") {
          planned = CollectionModel.fromCollectionEntity(c);
        } else if (c.name == "Просмотрено") {
          watched = CollectionModel.fromCollectionEntity(c);
        }
      }

      if (planned == null) {
        final entity = CollectionEntity.create("Буду смотреть");
        planned = CollectionModel.fromCollectionEntity(entity);
        await collectionRepository.addCollection(planned);
      }

      if (watched == null) {
        final entity = CollectionEntity.create("Просмотрено");
        watched = CollectionModel.fromCollectionEntity(entity);
        await collectionRepository.addCollection(watched);
      }

      return {
        "planned": planned,
        "watched": watched,
      };
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}
