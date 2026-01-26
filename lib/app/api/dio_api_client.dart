import 'dart:developer';
import 'package:dio/dio.dart';

class DioApiClient {
  static final DioApiClient _instance = DioApiClient._internal();
  late final Dio _dio;
  String? _apiKey;
  
  factory DioApiClient() => _instance;
  Dio get dio => _dio;
  
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
  
  void updateApiKeyHeaders(String? newApiKey){
    _apiKey = newApiKey;
  }

}