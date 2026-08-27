import 'package:movie_search_assistant_bloc/app/api/dio_api_client.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/user_repository.dart';

class UseSharedApiKeyUseCase {
  final UserRepository userRepository;
  final DioApiClient apiClient;

  UseSharedApiKeyUseCase({
    required this.userRepository,
    required this.apiClient,
  });

  static const String sharedAccountType = "shared";

  Future<UserEntity> call() async {
    try {
      const userEntity = UserEntity(
        apiKey: null,
        accountType: sharedAccountType,
        limitCount: null,
        useCount: null,
      );
      await userRepository.addUserApiKeyInfoInStorage(userEntity);
      apiClient.updateApiKeyHeaders(null);
      return userEntity;
    } on LocalDataSourceException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
