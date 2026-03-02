import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class RemoveCollectionUseCase {
  final CollectionRepository collectionRepository;
  final FilmRepository filmRepository;

  RemoveCollectionUseCase({
    required this.collectionRepository,
    required this.filmRepository
  });

  Future<void> call(String collectionId) async {
    try{
      await collectionRepository.removeCollection(collectionId);
      final savedFilms = await filmRepository.getAllFilmsFromLocalDataSource();
      if(savedFilms != null) {
        for(var film in savedFilms){
          if(film.collectionIds?.contains(collectionId) ?? false){
            final updatedCollectionIds = film.collectionIds;
            film.collectionIds?.remove(collectionId);
            FilmDetailModel filmDetailModelUpdated = FilmDetailModel.fromFilmEntity(film.copyWith(updatedCollectionIds: updatedCollectionIds));
            await filmRepository.addFilmInLocalDataSource(filmDetailModelUpdated);
          }
        }
      }
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}