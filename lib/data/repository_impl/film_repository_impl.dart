import 'dart:async';
import 'package:built_collection/built_collection.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/flim_local_data_source.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/film_remote_data_source.dart';
import 'package:movie_search_assistant_bloc/data/models/film_base_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_images_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_images_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class FilmRepositoryImpl implements FilmRepository{
  final FilmRemoteDataSource filmRemoteDataSource;
  final FilmLocalDataSource filmLocalDataSource;

  FilmRepositoryImpl({
    required this.filmRemoteDataSource,
    required this.filmLocalDataSource
  });

  @override
  Stream<List<FilmEntity>> watchFilms() {
    try{
      return filmLocalDataSource.watchFilms().map((filmModels) {
        return filmModels.map((model) {
          return FilmEntity.fromFilmDetailModel(model);
        }).toList();
      });
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<List<FilmEntity>?> getCollectionFilms(String collectionName, int page) async {
    try{
      List<FilmEntity> collectionFilmsEntity = [];
      List<FilmBaseModel>? filmBaseModels = await filmRemoteDataSource.getCollectionFilms(collectionName, page);
      if(filmBaseModels != null){
        for(var filmBaseModel in filmBaseModels){
          final filmBaseModelWithUserData = await initUserDataForFilmBaseModel(filmBaseModel);
          collectionFilmsEntity.add(FilmEntity.fromFilmBaseModel(filmBaseModelWithUserData));
        }
        return collectionFilmsEntity;
      }
      return null;
    } on RemoteDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<List<FilmEntity>?> getFilterFilms(String? keyword, List<int>? countries, List<int>? genres, int? yearFrom, int? yearTo, int page) async{
    try{
      List<FilmEntity> filterFilmsEntity = [];
      BuiltList<int>? builtCountries = countries != null ? BuiltList<int>.from(countries) : null;
      BuiltList<int>? builtGenres = genres != null ? BuiltList<int>.from(genres) : null;
      List<FilmBaseModel>? filmBaseModels = await filmRemoteDataSource.getFilterFilms(keyword, builtCountries, builtGenres, yearFrom, yearTo, page);
      if(filmBaseModels != null){
        for(var filmBaseModel in filmBaseModels){
          final filmBaseModelWithUserData = await initUserDataForFilmBaseModel(filmBaseModel);
          filterFilmsEntity.add(FilmEntity.fromFilmBaseModel(filmBaseModelWithUserData));
        }
        return filterFilmsEntity;
      }
      return null;
    } on RemoteDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<FilmEntity?> getFilmInformation(int idFilm) async{
    try{
      FilmDetailModel? filmDetailModel = await filmRemoteDataSource.getFilmInformation(idFilm);
      if(filmDetailModel != null){
        final filmDetailModelWithUserData = await initUserDataForFilmDetailModel(filmDetailModel);
        return FilmEntity.fromFilmDetailModel(filmDetailModelWithUserData);
      } 
      return null;
    } on RemoteDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<bool> filmIsSaved(int idFilm) async{
    try{
      return await filmLocalDataSource.filmIsSaved(idFilm);
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override 
  Future<void> addFilmInLocalDataSource(FilmDetailModel film) async {
    try{
      await filmLocalDataSource.addFilm(film);
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<FilmEntity?> getFilmFromLocalDataSource(int idFilm) async{
    try{
      FilmDetailModel? savedFilm = await filmLocalDataSource.getFilm(idFilm);
      if(savedFilm != null){
        return FilmEntity.fromFilmDetailModel(savedFilm);
      }
      return null;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<List<FilmEntity>> getFilmsFromLocalDataSource(List<int> filmIds) async{
    try{
      List<FilmEntity> savedFilmsEntity = [];
      List<FilmDetailModel>? savedFilmsModel = await filmLocalDataSource.getFilmsByIds(filmIds);
      if(savedFilmsModel != null){
        for(final film in savedFilmsModel){
          savedFilmsEntity.add(FilmEntity.fromFilmDetailModel(film));
        }
      }
      return savedFilmsEntity;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<List<FilmEntity>> getAllFilmsFromLocalDataSource() async {
    try{
      List<FilmEntity> savedFilmsEntity = [];
      List<FilmDetailModel>? savedFilmsModel = await filmLocalDataSource.getAllFilms();
      if(savedFilmsModel != null){
        for(final film in savedFilmsModel){
          savedFilmsEntity.add(FilmEntity.fromFilmDetailModel(film));
        }
      }
      return savedFilmsEntity;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<void> removeFilmFromLocalDataSource(int idFilm) async {
    try{
      await filmLocalDataSource.removeFilm(idFilm);
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override 
  Future<void> removeAllFilmsFromLocalDataSource() async {
    try{
      await filmLocalDataSource.removeAllFilms();
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<FilmImagesEntity?> getFilmImages(int idFilm) async{
    try{
      FilmImagesModel? filmImagesModel = await filmRemoteDataSource.getFilmImageUrls(idFilm);
      if(filmImagesModel != null){
        return FilmImagesEntity.fromModel(filmImagesModel);
      }
      return null;
    } on RemoteDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<FilmBaseModel> initUserDataForFilmBaseModel(FilmBaseModel filmBaseModel) async {
    Map<String, dynamic>? userDataAboutFilm = await filmLocalDataSource.getUserDataAboutFilm(filmBaseModel.kinopoiskId!);
    if(userDataAboutFilm != null){
      //filmBaseModel.collectionIds = userDataAboutFilm["collectionTag"];
      filmBaseModel.userComment = userDataAboutFilm["userComment"];
      filmBaseModel.userRating = userDataAboutFilm["userRating"];
    }
    return filmBaseModel;
  }

  @override
  Future<FilmDetailModel> initUserDataForFilmDetailModel(FilmDetailModel filmDetailModel) async {
    Map<String, dynamic>? userDataAboutFilm = await filmLocalDataSource.getUserDataAboutFilm(filmDetailModel.filmBaseModel.kinopoiskId!);
    if(userDataAboutFilm != null){
      //filmDetailModel.filmBaseModel.collectionIds = userDataAboutFilm["collectionTag"];
      filmDetailModel.filmBaseModel.userComment = userDataAboutFilm["userComment"];
      filmDetailModel.filmBaseModel.userRating = userDataAboutFilm["userRating"];
    }
    return filmDetailModel;
  }
}