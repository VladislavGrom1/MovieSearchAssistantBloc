
import 'package:movie_search_assistant_bloc/data/models/film_base_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_images_entity.dart';

abstract class FilmRepository {

  Stream<List<FilmEntity>> watchFilms();
  
  Future<List<FilmEntity>?> getCollectionFilms(String collectionName, int page);

  Future<List<FilmEntity>?> getFilterFilms(String? keyword, List<int>? countries, List<int>? genres, int? yearFrom, int? yearTo, int page);

  Future<FilmEntity?> getFilmInformation(int idFilm);

  Future<bool> filmIsSaved(int idFilm);

  Future<FilmImagesEntity?> getFilmImages(int idFilm);

  Future<void> addFilmInLocalDataSource(FilmDetailModel film);

  Future<FilmBaseModel> initUserDataForFilmBaseModel(FilmBaseModel filmBaseModel);
    
  Future<FilmDetailModel> initUserDataForFilmDetailModel(FilmDetailModel filmDetailModel);

  Future<FilmEntity?> getFilmFromLocalDataSource(int idFilm);

  Future<List<FilmEntity>> getFilmsFromLocalDataSource(List<int> filmIds);

  Future<void> removeFilmFromLocalDataSource(int idFilm);

  Future<void> removeAllFilmsFromLocalDataSource();
}