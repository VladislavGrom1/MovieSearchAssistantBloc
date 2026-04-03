
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/image_storage_service.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class ClearCollectionUseCase {
  final ImageStorageService imageStorageService;
  final FilmRepository filmRepository;
  final FilmCollectionRepository filmCollectionRepository;

  const ClearCollectionUseCase({
    required this.imageStorageService,
    required this.filmRepository,
    required this.filmCollectionRepository
  });

  Future<void> call(String collectionId) async {
    try{
      final allFilmCollectionLinks = await filmCollectionRepository.getAllFilmCollectionLinks();
      final filmIdsIncludedInCollection = allFilmCollectionLinks.where((link) => link.collectionId == collectionId).map((link) => link.filmId).toList();

      await filmCollectionRepository.removeAllLinksByCollectionId(collectionId);

      for(final filmId in filmIdsIncludedInCollection){
        final filmHasOtherLinks = allFilmCollectionLinks.any((link) => link.filmId == filmId && link.collectionId != collectionId);
        if(!filmHasOtherLinks){
          imageStorageService.deleteFilmImages(filmId);
          filmRepository.removeFilmFromLocalDataSource(filmId);
        }
      }
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}