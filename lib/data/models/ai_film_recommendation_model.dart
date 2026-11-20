import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';


class AiFilmRecommendationModel {
  final String nameEn;
  final String? nameRu;
  final int? year;
  final String description;
  final int? kinopoiskId;
  final String? posterUrl;
  final String? rating;
  final List<String> genres;

  const AiFilmRecommendationModel({
    required this.nameEn,
    required this.description,
    this.nameRu,
    this.year,
    this.kinopoiskId,
    this.posterUrl,
    this.rating,
    this.genres = const <String>[],
  });

  factory AiFilmRecommendationModel.fromJson(Map<String, dynamic> json) {
    return AiFilmRecommendationModel(
      nameEn: json['nameEn'] as String? ?? '',
      nameRu: json['nameRu'] as String? ?? '',
      year: (json['year'] as num?)?.toInt(),
      description: json['reason'] as String? ?? '',
      kinopoiskId: (json['kinopoiskId'] as num?)?.toInt(),
      posterUrl: json['posterUrl'] as String?,
      rating: json['rating']?.toString(),
      genres: _parseGenres(json['genres']),
    );
  }

  AiFilmRecommendation toEntity() {
    return AiFilmRecommendation(
      film: FilmEntity(
        kinopoiskId: kinopoiskId,
        nameOriginal: nameEn,
        nameRu: nameRu,
        year: year,
        posterUrl: posterUrl,
        posterUrlPreview: posterUrl,
        ratingKinopoisk: _parseRating(rating),
        genres: genres.isEmpty ? null : genres,
      ),
      description: description,
    );
  }

  static List<String> _parseGenres(Object? value) {
    if (value is! List) return const <String>[];

    final List<String> genres = [];

    for (final item in value) {
      final String? genre = switch (item) {
        final Map<Object?, Object?> map => _readGenre(map),
        final String string => string.trim(),
        _ => null,
      };

      if (genre != null && genre.isNotEmpty) {
        genres.add(genre);
      }
    }

    return genres;
  }

  static String? _readGenre(Map<Object?, Object?> map) {
    final Object? genre = map['genre'] ?? map['name'];

    if (genre is! String) return null;

    final String trimmedGenre = genre.trim();

    return trimmedGenre.isEmpty ? null : trimmedGenre;
  }

  static num? _parseRating(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = num.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return null;
    return parsed % 1 == 0 ? parsed.toInt() : parsed;
  }
}
