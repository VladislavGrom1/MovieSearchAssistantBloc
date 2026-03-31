import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/user_repository.dart';

class GetApiKeyInfoFromStorageUseCase {
  final UserRepository userRepository;

  GetApiKeyInfoFromStorageUseCase({required this.userRepository});

  Future<UserEntity?> call() async {
    try{ 
      UserEntity? userEntity = await userRepository.getUserApiKeyInfoFromStorage();
      return userEntity;
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}