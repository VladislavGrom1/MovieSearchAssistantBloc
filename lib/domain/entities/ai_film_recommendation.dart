import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';

/// Рекомендация AI-вкладки: фильм и описание его сюжета.
///
/// Живёт только в памяти экрана подбора: не сохраняется в Hive, не попадает
/// в коллекции и не передаётся на экран деталей.
class AiFilmRecommendation extends Equatable {
  final FilmEntity film;
  final String description;

  const AiFilmRecommendation({
    required this.film,
    required this.description,
  });

  @override
  List<Object?> get props => [film, description];
}
