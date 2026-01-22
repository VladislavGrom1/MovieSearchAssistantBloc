
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity> getUserApiKeyInfo(String apiKey);
  //Future<bool> validateApiKey(String apiKey);
}