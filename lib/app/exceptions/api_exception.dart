import 'package:dio/dio.dart';

class ApiException implements Exception{
  final DioExceptionType exceptionType;
  final int? statusCode;
  ApiException(this.exceptionType, this.statusCode);
}