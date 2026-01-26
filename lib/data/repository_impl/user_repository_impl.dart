import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/user_local_data_source.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/user_remote_data_source.dart';
import 'package:movie_search_assistant_bloc/data/models/user_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource userApiService;
  final UserLocalDataSource userLocalStorage;

  UserRepositoryImpl({required this.userApiService, required this.userLocalStorage});
  
  @override
  Future<UserEntity?> getUserApiKeyInfoFromService(String apiKey) async {
    try{
      UserModel? userModel = await userApiService.getUserApiKeyInfo(apiKey);
      if(userModel != null){
        return UserEntity(
          apiKey: apiKey,
          accountType: userModel.accountType,
          limitCount: userModel.limitCount,
          useCount: userModel.useCount
        );
      }
      return null;
    } on RemoteDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getUserApiKeyInfoFromStorage() async {
    try{
      UserModel? userModel = userLocalStorage.getUserApiKeyInfo();
      if(userModel == null){
        return null;
      } else{
        return UserEntity(
          apiKey: userModel.apiKey,
          accountType: userModel.accountType,
          limitCount: userModel.limitCount,
          useCount: userModel.useCount
        );
      }
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<void> addUserApiKeyInfoInStorage(UserEntity userEntity) async{
    try{
      UserModel userModel = UserModel(
        apiKey: userEntity.apiKey,
        accountType: userEntity.accountType,
        limitCount: userEntity.limitCount,
        useCount: userEntity.useCount
      );
      await userLocalStorage.addUserApiKeyInfo(userModel);
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  @override
  Future<void> removeUserApiKeyInfoFromStorage() async{
    try{
      await userLocalStorage.removeUserApiKeyInfo();
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}