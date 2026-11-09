import 'package:dio/dio.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/exception_mapper.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/ai_film_recommendation_model.dart';

/// Абсолютный адрес AI-воркера. Отдельный от `baseUrl` кинопрокси;
/// см. ADR-0002 про переиспользование общего `Dio`.
const String aiFilmsEndpoint =
    'https://ai-movie-assistant.vladislav-vaganov-dev.workers.dev/';

class AiFilmRemoteDataSource {
  final Dio dio;

  AiFilmRemoteDataSource({required this.dio});

  Future<List<AiFilmRecommendationModel>> getRecommendations(String query) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        aiFilmsEndpoint,
        data: {'query': query},
      );

      final movies = response.data?['movies'] as List<dynamic>? ?? const [];
      return movies
          .whereType<Map<String, dynamic>>()
          .map(AiFilmRecommendationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  RemoteDataSourceException _mapError(DioException e) {
    final statusCode = e.response?.statusCode;

    switch (statusCode) {
      case 404:
        return AiServiceFailure('Фильмы не найдены. Попробуйте описать иначе.');
      case 502:
        return AiServiceFailure('Модель не смогла ответить. Попробуйте позже.');
      case 400:
      case 405:
      case 500:
        return AiServiceFailure(
          'Сервис подбора временно недоступен. Попробуйте позже.',
        );
    }

    final serverMessage = _serverErrorMessage(e);
    if (serverMessage != null && statusCode != null) {
      return AiServiceFailure(serverMessage);
    }

    return AiServiceFailure(ExceptionMapper.mapDioException(e).message);
  }

  String? _serverErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final error = data['error'];
      if (error is String && error.trim().isNotEmpty) {
        return error;
      }
    }
    return null;
  }
}
