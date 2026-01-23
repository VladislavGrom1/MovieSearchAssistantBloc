import 'dart:developer';
import 'package:dio/dio.dart';

class DioApiClient {
  static final DioApiClient _instance = DioApiClient._internal();
  late final Dio _dio;
  String? _apiKey;
  
  factory DioApiClient() => _instance;
  
  DioApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: "https://kinopoiskapiunofficial.tech/",
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers["X-API-KEY"] = _apiKey;
        return handler.next(options);
      },
    ));
  }
  
  Dio get dio => _dio;
  
  void updateApiKeyHeaders(String newApiKey){
    _apiKey = newApiKey;
    log(_apiKey.toString());
  }

  String getApiKeyFromStorage(){
    // TODO: Получение ApiKey из LocalStorage
    return "";
  }
}