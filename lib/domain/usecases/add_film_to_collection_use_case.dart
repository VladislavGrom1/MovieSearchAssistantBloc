import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class AddFilmToCollectionUseCase {
  final FilmRepository filmRepository;

  AddFilmToCollectionUseCase({
    required this.filmRepository
  });

  Future<FilmEntity> call(FilmEntity film, String collectionId) async {
    try{
      final updatedCollectionIds = List<String>.from(film.collectionIds ?? []);
      updatedCollectionIds.add(collectionId);
      final updatedFilm = film.copyWith(updatedCollectionIds: updatedCollectionIds);
      await filmRepository.addFilmInLocalDataSource(FilmDetailModel.fromFilmEntity(updatedFilm));
      return updatedFilm;
    } on LocalDataSourceException{
      rethrow; 
    } catch(e){
      rethrow;
    }
  }
}