import 'package:built_collection/built_collection.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/film_remote_data_source.dart';
import 'package:movie_search_assistant_bloc/data/models/film_card_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_information_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_card_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_information_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class FilmRepositoryImpl implements FilmRepository{
  final FilmRemoteDataSource filmRemoteDataSource;

  FilmRepositoryImpl({required this.filmRemoteDataSource});
  
  @override
  Future<List<FilmCardEntity>?> getCollectionFilms(String collectionName, int page) async {
    try{
      List<FilmCardEntity> collectionFilmsEntity = [];
      List<FilmCardModel>? collectionFilmsModel = await filmRemoteDataSource.getCollectionFilms(collectionName, page);
      if(collectionFilmsModel != null){
        for(var filmCardModel in collectionFilmsModel){
          collectionFilmsEntity.add(FilmCardEntity.fromModel(filmCardModel));
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
  Future<List<FilmCardEntity>?> getFilterFilms(String? keyword, List<int>? countries, List<int>? genres, int? yearFrom, int? yearTo, int page) async{
    try{
      List<FilmCardEntity> filterFilmsEntity = [];
      BuiltList<int>? builtCountries = countries != null ? BuiltList<int>.from(countries) : null;
      BuiltList<int>? builtGenres = genres != null ? BuiltList<int>.from(genres) : null;
      List<FilmCardModel>? filterFilmsModel = await filmRemoteDataSource.getFilterFilms(keyword, builtCountries, builtGenres, yearFrom, yearTo, page);
      if(filterFilmsModel != null){
        for(var filmCardModel in filterFilmsModel){
          filterFilmsEntity.add(FilmCardEntity.fromModel(filmCardModel));
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
  Future<FilmInformationEntity?> getFilmInformation(int idFilm) async{
    try{
      FilmInformationModel? filmInformationModel = await filmRemoteDataSource.getFilmInformation(idFilm);
      if(filmInformationModel != null){
        return FilmInformationEntity.fromModel(filmInformationModel);
      } 
      return null;
    } on RemoteDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}