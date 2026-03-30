import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/film_collection_link.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class RemoveFilmFromCollectionUseCase {
  final FilmRepository filmRepository;
  final FilmCollectionRepository filmCollectionRepository;

  RemoveFilmFromCollectionUseCase({
    required this.filmRepository,
    required this.filmCollectionRepository
  });

  // TODO: Реализовать удаление рейтинга/комментария при удалении фильма из локального хранилища

  Future<void> call(FilmEntity film, String collectionId) async {
    try{
      final filmId = film.kinopoiskId!;

      await filmCollectionRepository.removeFilmCollectionLink(FilmCollectionLink(filmId: film.kinopoiskId!, collectionId: collectionId));

      final allFilmCollectionLinks = await filmCollectionRepository.getAllFilmCollectionLinks();

      bool filmHasOtherLinks = allFilmCollectionLinks.any((link) => link.filmId == filmId);

      if(!filmHasOtherLinks){
        await filmRepository.removeFilmFromLocalDataSource(filmId);
      }
    } on LocalDataSourceException{
      rethrow; 
    } catch(e){
      rethrow;
    }
  }
}