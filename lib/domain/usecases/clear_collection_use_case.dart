
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class ClearCollectionUseCase {
  final FilmRepository filmRepository;

  const ClearCollectionUseCase({required this.filmRepository});

  Future<void> call(String collectionId) async {
    try{
      final savedFilms = await filmRepository.getFilmsFromLocalDataSource(collectionId);
      if(savedFilms != null) {
        for(var film in savedFilms){
          if(film.collectionIds?.contains(collectionId) ?? false){
            final updatedCollectionIds = List<String>.from(film.collectionIds ?? []);
            updatedCollectionIds.remove(collectionId);
            if(updatedCollectionIds.isEmpty){
              await filmRepository.removeFilmFromLocalDataSource(film.kinopoiskId!);
            } else{
              FilmDetailModel filmDetailModelUpdated = FilmDetailModel.fromFilmEntity(film.copyWith(updatedCollectionIds: updatedCollectionIds));
              await filmRepository.addFilmInLocalDataSource(filmDetailModelUpdated);
            }
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