import 'package:dio/dio.dart';
import 'package:generated/generated.dart';
import 'package:movie_search_assistant_bloc/app/api/dio_api_client.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/api_exception.dart';

class UserDataSource {
  final Dio dio;
  UserDataSource({required this.dio});

  Future<Response<ApiKeyResponse>> getUserApiKeyInfo(String apiKey) async {    
    ApiKeysApi apiKeysApi = ApiKeysApi(dio, standardSerializers);
    try{
      DioApiClient().updateApiKeyHeaders(apiKey);
      Response<ApiKeyResponse> responseData = await apiKeysApi.apiV1ApiKeysApiKeyGet(apiKey: apiKey);
      return responseData;
    } on DioException catch(e){
      throw ApiException(e.type, e.response?.statusCode);
    }
  }
}