import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/film_collection_link.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class AddFilmToCollectionUseCase {
  final FilmRepository filmRepository;
  final FilmCollectionRepository filmCollectionRepository;

  AddFilmToCollectionUseCase({
    required this.filmRepository,
    required this.filmCollectionRepository
  });

  Future<FilmEntity> call(FilmEntity film, String collectionId) async {
    try{
      final idFilm = film.kinopoiskId!;
      final filmIsSaved = await filmRepository.filmIsSaved(idFilm);
      if(!filmIsSaved){
        await filmRepository.addFilmInLocalDataSource(FilmDetailModel.fromFilmEntity(film));
      }
      await filmCollectionRepository.addFilmCollectionLink(FilmCollectionLink(filmId: idFilm, collectionId: collectionId));
      return film;
    } on LocalDataSourceException{
      rethrow; 
    } catch(e){
      rethrow;
    }
  }
}