
import 'package:movie_search_assistant_bloc/app/api/dio_api_client.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_card_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/user_repository.dart';

class DisplayFilmCollectionsUseCase {
  final UserRepository userRepository;
  final FilmRepository filmRepository;
  final DioApiClient apiClient;

  DisplayFilmCollectionsUseCase({
    required this.userRepository,
    required this.filmRepository, 
    required this.apiClient
  });

  Future<Map<String, List<FilmCardEntity>?>?> call(List<String> collectionNames) async{
    try{
      Map<String, List<FilmCardEntity>?> filmCollectionsMap = {};
      UserEntity? userEntity = await userRepository.getUserApiKeyInfoFromStorage();
      if(userEntity != null){
        apiClient.updateApiKeyHeaders(userEntity.apiKey!);
        for(var collectionName in collectionNames){
          filmCollectionsMap[collectionName] = await filmRepository.getCollectionFilms(userEntity.apiKey!, collectionName, 1);
        }
        return filmCollectionsMap;
      }
      return null;
    } on RemoteDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}