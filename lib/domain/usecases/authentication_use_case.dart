import 'package:movie_search_assistant_bloc/app/api/dio_api_client.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/user_repository.dart';

class AuthenticationUseCase {
  final UserRepository userRepository;
  final DioApiClient apiClient;
  
  AuthenticationUseCase({
    required this.userRepository, 
    required this.apiClient
  });
  
  Future<UserEntity?> call({required String apiKey}) async {
    try{
      UserEntity? userEntity = await userRepository.getUserApiKeyInfoFromService(apiKey);
      if(userEntity == null){
        return null;
      }
      await userRepository.addUserApiKeyInfoInStorage(userEntity);
      apiClient.updateApiKeyHeaders(userEntity.apiKey!);
      return userEntity;
    } on RemoteDataSourceException{
      rethrow;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}