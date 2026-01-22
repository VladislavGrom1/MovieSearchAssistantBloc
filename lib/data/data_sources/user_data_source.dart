import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:generated/generated.dart';

class UserDataSource {
  final Dio dio;
  UserDataSource({required this.dio});

  Future<Response<ApiKeyResponse>> getUserApiKeyInfo(String apiKey) async {
    dio.options.headers = {"X-API-KEY": apiKey};
    ApiKeysApi apiKeysApi = ApiKeysApi(dio, standardSerializers);
    try{
      Response<ApiKeyResponse> responseData = await apiKeysApi.apiV1ApiKeysApiKeyGet(apiKey: apiKey);
      return responseData;
    } on DioException catch(e){
      log(e.toString());
      rethrow;
    }
  }
}