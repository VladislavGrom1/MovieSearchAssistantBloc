import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/image_storage_service.dart';
import 'package:movie_search_assistant_bloc/data/models/film_collection_link.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_images_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class AddFilmToCollectionUseCase {
  final FilmRepository filmRepository;
  final FilmCollectionRepository filmCollectionRepository;
  final ImageStorageService imageStorageService;

  AddFilmToCollectionUseCase({
    required this.filmRepository,
    required this.filmCollectionRepository,
    required this.imageStorageService
  });

  Future<void> call(FilmEntity film, FilmImagesEntity? filmImages, String collectionId) async {
    try{
      final idFilm = film.kinopoiskId!;
      final filmIsSaved = await filmRepository.filmIsSaved(idFilm);
      if(!filmIsSaved){
        String? posterImagePath;
        List<String>? screenshotPaths;
        (posterImagePath, screenshotPaths) = await imageStorageService.saveFilmImagesInDirectory(film.posterUrl, filmImages?.imageUrls, film.kinopoiskId!);
        final updatedFilmWithImagePaths = film.copyWith(localPosterImagePath: posterImagePath, localScreenshotPaths: screenshotPaths);
        await filmRepository.addFilmInLocalDataSource(FilmDetailModel.fromFilmEntity(updatedFilmWithImagePaths));
      }
      await filmCollectionRepository.addFilmCollectionLink(FilmCollectionLink(filmId: idFilm, collectionId: collectionId));
    } on LocalDataSourceException{
      rethrow; 
    } catch(e){
      rethrow;
    }
  }
}