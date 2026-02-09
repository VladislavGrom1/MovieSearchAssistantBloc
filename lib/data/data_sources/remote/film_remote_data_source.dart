
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:generated/generated.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/film_card_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_information_model.dart';

class FilmRemoteDataSource {
  final Dio dio;
  FilmRemoteDataSource({required this.dio});

  Future<List<FilmCardModel>?> getCollectionFilms(String collectionName, int page) async {
    FilmsApi filmsApi = FilmsApi(dio, standardSerializers);
    List<FilmCardModel> collectionFilms = [];
    try{
      Response<FilmCollectionResponse> response = await filmsApi.apiV22FilmsCollectionsGet(
        type: collectionName,
        page: page
      );
      if(response.data != null){
        for(var film in response.data!.items){
          collectionFilms.add(FilmCardModel.fromFilmCollectionResponseItems(film));
        }
        return collectionFilms;
      }
      return null; 
    } on DioException catch(e){
      throw RemoteDataSourceException(e.type, e.response?.statusCode);
    } catch(e){
      rethrow;
    }
  }

  Future<List<FilmCardModel>?> getFilterFilms(String? keyword, BuiltList<int>? builtCountries, BuiltList<int>? builtGenres, int? yearFrom, int? yearTo, int page) async{
    FilmsApi filmsApi = FilmsApi(dio, standardSerializers);
    List<FilmCardModel> filterFilms = [];
    try{
      Response<FilmSearchByFiltersResponse?> response = await filmsApi.apiV22FilmsGet(
        keyword: keyword,
        countries: builtCountries,
        genres: builtGenres,
        yearFrom: yearFrom,
        yearTo: yearTo,
        page: page
      );
      if(response.data != null){
        for(var film in response.data!.items){
          filterFilms.add(FilmCardModel.fromFilmSearchByFiltersResponseItems(film));
        }
        return filterFilms;
      }
      return null;
    } on DioException catch(e){
      throw RemoteDataSourceException(e.type, e.response?.statusCode);
    } catch(e){
      rethrow;
    }
  }

  Future<FilmInformationModel?> getFilmInformation(int idFilm) async{
    FilmsApi filmsApi = FilmsApi(dio, standardSerializers);
    try{
      Response<Film> response = await filmsApi.apiV22FilmsIdGet(
        id: idFilm
      );
      if(response.data != null){
        return FilmInformationModel.fromFilm(response.data!);
      }
      return null;
    } on DioException catch(e){
      throw RemoteDataSourceException(e.type, e.response?.statusCode);
    } catch(e){
      rethrow;
    }
  }

}