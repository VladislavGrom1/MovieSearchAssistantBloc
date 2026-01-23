import 'package:movie_search_assistant_bloc/app/exceptions/api_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/user_data_source.dart';
import 'package:movie_search_assistant_bloc/data/models/user_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource userApiService;

  UserRepositoryImpl({required this.userApiService});
  
  @override
  Future<UserEntity> getUserApiKeyInfo(String apiKey) async{
    try{
      final response = await userApiService.getUserApiKeyInfo(apiKey);
      final userModel = UserModel.fromObject(response.data!);
      return UserEntity(
        apiKey: null,
        accountType: userModel.accountType,
        limitCount: userModel.limitCount,
        useCount: userModel.useCount
      );
    } on ApiException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}