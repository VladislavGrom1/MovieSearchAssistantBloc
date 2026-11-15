import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/data/models/ai_film_recommendation_model.dart';
import 'package:movie_search_assistant_bloc/data/repository_impl/ai_film_repository_impl.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/ai_film_remote_data_source.dart';

class MockAiFilmRemoteDataSource extends Mock implements AiFilmRemoteDataSource {}

void main() {
  late MockAiFilmRemoteDataSource dataSource;
  late AiFilmRepositoryImpl repository;

  setUp(() {
    dataSource = MockAiFilmRemoteDataSource();
    repository = AiFilmRepositoryImpl(dataSource);
  });

  test('маппит модели в сущности и пробрасывает описание', () async {
    when(() => dataSource.getRecommendations('комедия', false, const [], const []))
        .thenAnswer(
      (_) async => const [
        AiFilmRecommendationModel(
          nameEn: 'The Grand Budapest Hotel',
          nameRu: null,
          year: null,
          description: 'История консьержа.',
          kinopoiskId: 7,
          posterUrl: null,
          rating: null,
        ),
      ],
    );

    final result =
        await repository.getRecommendations('комедия', false, const [], const []);

    expect(result, hasLength(1));
    expect(result.first.film.nameOriginal, 'The Grand Budapest Hotel');
    expect(result.first.film.kinopoiskId, 7);
    expect(result.first.description, 'История консьержа.');
  });

  test('пустой список моделей даёт пустой список сущностей', () async {
    when(() => dataSource.getRecommendations(any(), any(), any(), any()))
        .thenAnswer((_) async => []);

    final result =
        await repository.getRecommendations('что угодно', false, const [], const []);

    expect(result, isEmpty);
  });

  test('пробрасывает режим, сохранённые id и названия в источник', () async {
    when(() => dataSource.getRecommendations(any(), any(), any(), any()))
        .thenAnswer((_) async => const []);

    await repository.getRecommendations(
      'q',
      true,
      const [1, 2],
      const ['Интерстеллар', null],
    );

    final arguments = verify(
      () => dataSource.getRecommendations(
        captureAny(),
        captureAny(),
        captureAny(),
        captureAny(),
      ),
    ).captured;

    expect(arguments, ['q', true, [1, 2], ['Интерстеллар', null]]);
  });
}
