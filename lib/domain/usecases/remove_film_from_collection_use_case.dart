import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class RemoveFilmFromCollectionUseCase {
  final FilmRepository filmRepository;

  RemoveFilmFromCollectionUseCase({
    required this.filmRepository
  });

  Future<FilmEntity> call(FilmEntity film, String collectionId) async {
    try{
      final updatedCollectionIds = List<String>.from(film.collectionIds ?? []);
      updatedCollectionIds.remove(collectionId);
      final updatedFilm = film.copyWith(updatedCollectionIds: updatedCollectionIds);

      if (updatedCollectionIds.isEmpty) {
        await filmRepository.removeFilmFromLocalDataSource(film.kinopoiskId!);
      } else {
        final filmDetailModel = FilmDetailModel.fromFilmEntity(updatedFilm);
        await filmRepository.addFilmInLocalDataSource(filmDetailModel);
      }
      return updatedFilm;
    } on LocalDataSourceException{
      rethrow; 
    } catch(e){
      rethrow;
    }
  }
}