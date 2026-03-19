import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/hive_storage_keys.dart';
import 'package:movie_search_assistant_bloc/data/models/user_model.dart';

class UserLocalDataSource {

  UserModel? getUserApiKeyInfo() {
    UserModel? userApiKeyInfo;
    try{
      final storageBox = Hive.box<UserModel>(HiveStorageKeys.userModelBox);
      userApiKeyInfo = storageBox.get(HiveStorageKeys.userModelKey);
      return userApiKeyInfo;
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<void> addUserApiKeyInfo(UserModel userModel) async {
    try{
      final storageBox = Hive.box<UserModel>(HiveStorageKeys.userModelBox);
      await storageBox.put(HiveStorageKeys.userModelKey, userModel);
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }

  Future<void> removeUserApiKeyInfo() async{
    try{
      final storageBox = Hive.box<UserModel>(HiveStorageKeys.userModelBox);
      await storageBox.delete(HiveStorageKeys.userModelKey);
    } on HiveError catch(e){
      throw LocalDataSourceException(message: e.message);
    } catch(e){
      rethrow;
    }
  }
}
