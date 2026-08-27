import 'package:dio/dio.dart';

class DioApiClient {
  static final DioApiClient _instance = DioApiClient._internal();
  late final Dio _dio;
  String? _apiKey;
  
  factory DioApiClient() => _instance;
  Dio get dio => _dio;
  
  DioApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: "https://kinopoisk-proxy.vladislav-vaganov-dev.workers.dev/",
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final apiKey = _apiKey;
        options.headers.remove("X-User-Api-Key");
        if (apiKey != null && apiKey.isNotEmpty) {
          options.headers["X-User-Api-Key"] = apiKey;
        }
        return handler.next(options);
      },
    ));
  }

  void updateApiKeyHeaders(String? newApiKey){
    _apiKey = newApiKey;
  }

  bool get hasUserApiKey => _apiKey != null && _apiKey!.isNotEmpty;
}