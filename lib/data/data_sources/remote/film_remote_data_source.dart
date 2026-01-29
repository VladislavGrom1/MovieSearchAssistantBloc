
import 'package:dio/dio.dart';
import 'package:generated/generated.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/film_card_model.dart';

class FilmRemoteDataSource {
  final Dio dio;
  FilmRemoteDataSource({required this.dio});

  Future<List<FilmCardModel>?> getCollectionFilms(String apiKey, String collectionName, int page) async {
    FilmsApi filmsApi = FilmsApi(dio, standardSerializers);
    List<FilmCardModel> collectionFilms = [];
    try{
      Response<FilmCollectionResponse> responseData = await filmsApi.apiV22FilmsCollectionsGet(
        type: collectionName,
        page: page
      );
      if(responseData.data != null){
        for(var film in responseData.data!.items){
          collectionFilms.add(FilmCardModel.fromObject(film));
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

}