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
  final _savedFilmsController = StreamController<List<FilmDetailModel>>.broadcast();

  FilmRepositoryImpl({
    required this.filmRemoteDataSource,
    required this.filmLocalDataSource
  });

  
  @override
  Future<List<FilmEntity>?> getCollectionFilms(String collectionName, int page) async {
    try{
      List<FilmEntity> collectionFilmsEntity = [];
      List<FilmBaseModel>? filmBaseModels = await filmRemoteDataSource.getCollectionFilms(collectionName, page);
      if(filmBaseModels != null){
        for(var filmBaseModel in filmBaseModels){
          filmBaseModel.isSaved = await filmIsSaved(filmBaseModel.kinopoiskId!);
          collectionFilmsEntity.add(FilmEntity.fromFilmBaseModel(filmBaseModel));
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
          filmBaseModel.isSaved = await filmIsSaved(filmBaseModel.kinopoiskId!);
          filterFilmsEntity.add(FilmEntity.fromFilmBaseModel(filmBaseModel));
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
        return FilmEntity.fromFilmDetailModel(filmDetailModel);
      } 
      return null;
    } on RemoteDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Stream<List<FilmDetailModel>> watchSavedFilms(){
    return _savedFilmsController.stream;
  }

  @override 
  Future<void> addFilmInLocalDataSource(FilmDetailModel film) async {
    try{
      await filmLocalDataSource.addFilm(film);
      
      final updatedSavedFilms = await getAllFilmsFromLocalDataSource();
      if (updatedSavedFilms != null) {
        _savedFilmsController.add(updatedSavedFilms);
      }
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<FilmDetailModel?> getFilmFromLocalDataSource(int idFilm) async{
    try{
      FilmDetailModel? savedFilm = await filmLocalDataSource.getFilm(idFilm);
      return savedFilm;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<List<FilmDetailModel>?> getAllFilmsFromLocalDataSource() async{
    try{
      List<FilmDetailModel>? savedFilms = await filmLocalDataSource.getAllFilms();
      return savedFilms;
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

      final updatedSavedFilms = await getAllFilmsFromLocalDataSource();
      if (updatedSavedFilms != null) {
        _savedFilmsController.add(updatedSavedFilms);
      }
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
      _savedFilmsController.add([]);
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
  Future<bool> filmIsSaved(int idFilm) async {
    try{
      return await filmLocalDataSource.filmIsSaved(idFilm);
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  void dispose() {
    _savedFilmsController.close();
  }
}