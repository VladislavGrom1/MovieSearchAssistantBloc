import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';

/// Сырой ответ AI-сервиса по одному фильму.
///
/// Поле `reason` сервиса — это описание сюжета с Кинопоиска, а не обоснование
/// выбора, поэтому в домене оно называется `description`.
class AiFilmRecommendationModel {
  final String title;
  final int? year;
  final String description;
  final int? kinopoiskId;
  final String? posterUrl;
  final String? rating;

  const AiFilmRecommendationModel({
    required this.title,
    required this.description,
    this.year,
    this.kinopoiskId,
    this.posterUrl,
    this.rating,
  });

  factory AiFilmRecommendationModel.fromJson(Map<String, dynamic> json) {
    return AiFilmRecommendationModel(
      title: json['title'] as String? ?? '',
      year: (json['year'] as num?)?.toInt(),
      description: json['reason'] as String? ?? '',
      kinopoiskId: (json['kinopoiskId'] as num?)?.toInt(),
      posterUrl: json['posterUrl'] as String?,
      rating: json['rating']?.toString(),
    );
  }

  AiFilmRecommendation toEntity() {
    return AiFilmRecommendation(
      film: FilmEntity(
        kinopoiskId: kinopoiskId,
        nameOriginal: title,
        year: year,
        posterUrl: posterUrl,
        posterUrlPreview: posterUrl,
        ratingKinopoisk: _parseRating(rating),
      ),
      description: description,
    );
  }

  /// `"8.1"` -> `8.1`, `"8.0"` -> `8`, нераспознанное -> `null`.
  ///
  /// Целые значения приводим к `int`, чтобы бейдж рейтинга не показывал `8.0`.
  static num? _parseRating(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = num.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return null;
    return parsed % 1 == 0 ? parsed.toInt() : parsed;
  }
}
