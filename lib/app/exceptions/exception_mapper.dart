import 'package:dio/dio.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';

class ExceptionMapper {
  static RemoteDataSourceException mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return NetworkFailure();

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;

        if (statusCode == 401) {
          return UnauthorizedFailure();
        } else if (statusCode == 402){
          return TooManyRequests();
        } else if (statusCode == 404) {
          return NotFoundFailure();
        } else if (statusCode != null && statusCode >= 500) {
          return ServerFailure();
        }
        return UnknownFailure();

      default:
        return UnknownFailure();
    }
  }
}