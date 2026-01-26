
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getUserApiKeyInfoFromService(String apiKey);

  Future<UserEntity?> getUserApiKeyInfoFromStorage();

  Future<void> addUserApiKeyInfoInStorage(UserEntity userEntity);

  Future<void> removeUserApiKeyInfoFromStorage();
  //Future<bool> validateApiKey(String apiKey);
}