import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/image_storage_service.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_images_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class UpdateSavedFilmFromServerUseCase {
  final FilmRepository filmRepository;

  UpdateSavedFilmFromServerUseCase({required this.filmRepository});

  Future<FilmEntity> call(FilmEntity oldfilm, FilmEntity newFilm, FilmImagesEntity? filmImages) async {
    try{
      String? posterImagePath;
      List<String>? screenshotPaths;
      (posterImagePath, screenshotPaths) = await ImageStorageService().saveFilmImagesInDirectory(newFilm.posterUrl, filmImages?.imageUrls, newFilm.kinopoiskId!);
      
      FilmEntity updatedFilm = newFilm.copyWith(
        userComment: oldfilm.userComment, 
        userRating: oldfilm.userRating, 
        localPosterImagePath: posterImagePath, 
        localScreenshotPaths: screenshotPaths
      );
      
      await filmRepository.addFilmInLocalDataSource(FilmDetailModel.fromFilmEntity(updatedFilm));
      
      return updatedFilm;
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}