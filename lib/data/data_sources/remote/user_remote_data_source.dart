import 'package:dio/dio.dart';
import 'package:generated/generated.dart';
import 'package:movie_search_assistant_bloc/app/api/dio_api_client.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/user_model.dart';

class UserRemoteDataSource {
  final Dio dio;
  UserRemoteDataSource({required this.dio});

  Future<UserModel?> getUserApiKeyInfo(String apiKey) async {    
    ApiKeysApi apiKeysApi = ApiKeysApi(dio, standardSerializers);
    try{
      DioApiClient().updateApiKeyHeaders(apiKey);
      Response<ApiKeyResponse> response = await apiKeysApi.apiV1ApiKeysApiKeyGet(apiKey: apiKey);
      if(response.data != null){
        return UserModel.fromObject(response.data!, apiKey);
      }
      return null;
    } on DioException catch(e){
      throw RemoteDataSourceException(e.type, e.response?.statusCode);
    }
  }
}