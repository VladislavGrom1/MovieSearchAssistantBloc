import 'package:dio/dio.dart';

class RemoteDataSourceException implements Exception{
  final DioExceptionType exceptionType;
  final int? statusCode;
  RemoteDataSourceException(this.exceptionType, this.statusCode);
}