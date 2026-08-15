import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/image_storage_service.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class ClearLibraryUseCase {
  final FilmRepository filmRepository;
  final CollectionRepository collectionRepository;
  final FilmCollectionRepository filmCollectionRepository;
  final ImageStorageService imageStorageService;

  ClearLibraryUseCase({
    required this.filmRepository,
    required this.collectionRepository,
    required this.filmCollectionRepository,
    required this.imageStorageService 
  });

  Future<void> call() async {
    try{
      await filmRepository.removeAllFilmsFromLocalDataSource();
      await collectionRepository.removeAllCollection();
      await filmCollectionRepository.removeAllLinks();
      await imageStorageService.deleteAllFilmImages();
      await imageStorageService.deleteAllCollectionImages();
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}