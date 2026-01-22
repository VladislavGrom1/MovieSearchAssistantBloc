import 'package:dio/dio.dart';

class DioApiClient {
  Dio getDio(){
    Dio dio = Dio();
    dio.options.baseUrl = "https://kinopoiskapiunofficial.tech/";
    return dio;
  }
}