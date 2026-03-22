import 'package:movie_search_assistant_bloc/app/api/dio_api_client.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/user_repository.dart';

class GetFilmInformationUseCase {
  final UserRepository userRepository;
  final FilmRepository filmRepository;
  final FilmCollectionRepository filmCollectionRepository;
  final DioApiClient apiClient;

  GetFilmInformationUseCase({
    required this.userRepository,
    required this.filmRepository,
    required this.filmCollectionRepository,
    required this.apiClient
  });

  Future<(FilmEntity?, List<String> collectionIds)> call(int idFilm) async{
    try{
      List<String> collectionIds = [];
      UserEntity? userEntity = await userRepository.getUserApiKeyInfoFromStorage();
      if(userEntity != null){
        apiClient.updateApiKeyHeaders(userEntity.apiKey!);
        FilmEntity? filmEntity = await filmRepository.getFilmInformation(idFilm);
        collectionIds = await filmCollectionRepository.getCollectionIdsByFilmId(idFilm);
        return (filmEntity, collectionIds);
      } 
      return (null, collectionIds);
    } on RemoteDataSourceException{
      rethrow;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}