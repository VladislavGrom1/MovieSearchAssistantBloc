
import 'package:hive/hive.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/hive_storage_keys.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';

class FilmLocalDataSource{
  
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

  Future<bool> filmIsSaved(int idFilm) async {
    try{
      final storageBox = Hive.box<FilmDetailModel>(HiveStorageKeys.filmDetailModelKeyBox);
      return storageBox.containsKey(idFilm.toString());
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  } 
}