import 'package:movie_search_assistant_bloc/app/api/dio_api_client.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_card_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/user_repository.dart';

class SearchFilterFilmsUseCase {
  final UserRepository userRepository;
  final FilmRepository filmRepository;
  final DioApiClient apiClient;

  SearchFilterFilmsUseCase({required this.userRepository, required this.filmRepository, required this.apiClient});

  Future<List<FilmCardEntity>?>? call(String? keyword, List<int>? countries, List<int>? genres, int? yearFrom, int? yearTo, int page) async{
    List<FilmCardEntity>? filterFilms = [];
    try{
      UserEntity? userEntity = await userRepository.getUserApiKeyInfoFromStorage();
      if(userEntity != null){
        apiClient.updateApiKeyHeaders(userEntity.apiKey!);
        filterFilms = await filmRepository.getFilterFilms(keyword, countries, genres, yearFrom, yearTo, page);
        return filterFilms;
      }
      return null;
    } on RemoteDataSourceException{
      rethrow;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}