import 'dart:async';
import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/hive_storage_keys.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';

class FilmLocalDataSource{

  Stream<FilmDetailModel?> watchFilmById(int idFilm) {
    try{
      final storageBox = Hive.box<FilmDetailModel>(HiveStorageKeys.filmDetailModelKeyBox);
      return storageBox.watch(key: idFilm.toString()).map((event) {
        if (event.deleted) return null;
        return event.value as FilmDetailModel?;
      });
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Stream<List<FilmDetailModel>> watchFilms(){
    try{
      final storageBox = Hive.box<FilmDetailModel>(HiveStorageKeys.filmDetailModelKeyBox);
      return storageBox.watch().map((event) {
        return storageBox.values.toList();
      });
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<void> addFilm(FilmDetailModel film) async {
    try{
      final storageBox = Hive.box<FilmDetailModel>(HiveStorageKeys.filmDetailModelKeyBox);
      await storageBox.put(film.filmBaseModel.kinopoiskId.toString(), film);
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<FilmDetailModel?> getFilm(int idFilm) async {
    try{
      final storageBox = Hive.box<FilmDetailModel>(HiveStorageKeys.filmDetailModelKeyBox);
      FilmDetailModel? savedFilm = storageBox.get(idFilm.toString());
      return savedFilm;
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<List<FilmDetailModel>?> getAllFilms() async {
    try{
      final storageBox = Hive.box<FilmDetailModel>(HiveStorageKeys.filmDetailModelKeyBox);
      List<FilmDetailModel>? savedFilms = storageBox.values.toList();
      return savedFilms;
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<void> removeFilm(int idFilm) async {
    try{
      final storageBox = Hive.box<FilmDetailModel>(HiveStorageKeys.filmDetailModelKeyBox);
      await storageBox.delete(idFilm.toString());
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<void> removeAllFilms() async {
    try{
      final storageBox = Hive.box<FilmDetailModel>(HiveStorageKeys.filmDetailModelKeyBox);
      await storageBox.clear();
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserDataAboutFilm(int idFilm) async {
    Map<String, dynamic> userDataAboutFilm = {};
    try{
      final film = await getFilm(idFilm);
      if(film != null){
        userDataAboutFilm['collectionTag'] = film.filmBaseModel.collectionIds;
        userDataAboutFilm['userComment'] = film.filmBaseModel.userComment;
        userDataAboutFilm['userRating'] = film.filmBaseModel.userRating;
        return userDataAboutFilm;
      }
      return null;
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  } 
}