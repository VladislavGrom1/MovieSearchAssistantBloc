import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class RemoveCollectionUseCase {
  final CollectionRepository collectionRepository;
  final FilmRepository filmRepository;
  final FilmCollectionRepository filmCollectionRepository;

  RemoveCollectionUseCase({
    required this.collectionRepository,
    required this.filmRepository,
    required this.filmCollectionRepository
  });

  Future<void> call(String collectionId) async {
    try{
    
      final allFilmCollectionLinks = await filmCollectionRepository.getAllFilmCollectionLinks();
      final filmIdsIncludedInCollection = allFilmCollectionLinks.where((link) => link.collectionId == collectionId).map((link) => link.filmId).toList();

      await filmCollectionRepository.removeAllLinksByCollectionId(collectionId);
      await collectionRepository.removeCollection(collectionId);
      
      for(final filmId in filmIdsIncludedInCollection){
        final filmHasOtherLinks = allFilmCollectionLinks.any((link) => link.filmId == filmId && link.collectionId != collectionId);

        if(!filmHasOtherLinks){
          await filmRepository.removeFilmFromLocalDataSource(filmId);
        }
      }
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}