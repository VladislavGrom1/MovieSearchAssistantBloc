import 'package:movie_search_assistant_bloc/app/exceptions/api_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/user_repository.dart';

class AuthenticationUseCase {
  final UserRepository userRepository;
  AuthenticationUseCase({required this.userRepository});
  
  Future<UserEntity> call({required String apiKey}) {
    // TODO: Добавить функцию для сохранения ApiKey в LocalStorage и обновления в headers Dio
    try{
      return userRepository.getUserApiKeyInfo(apiKey);
    } on ApiException{
      rethrow;
    }
  }
}