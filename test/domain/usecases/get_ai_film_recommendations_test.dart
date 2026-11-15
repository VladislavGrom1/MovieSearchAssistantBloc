import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/repository/ai_film_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_ai_film_recommendations_use_case.dart';

class MockAiFilmRepository extends Mock implements AiFilmRepository {}

class MockFilmRepository extends Mock implements FilmRepository {}

void main() {
  late MockAiFilmRepository aiFilmRepository;
  late MockFilmRepository filmRepository;
  late GetAiFilmRecommendationsUseCase useCase;

  setUpAll(() {
    registerFallbackValue(<int>[]);
    registerFallbackValue(<String?>[]);
  });

  setUp(() {
    aiFilmRepository = MockAiFilmRepository();
    filmRepository = MockFilmRepository();
    useCase = GetAiFilmRecommendationsUseCase(
      aiFilmRepository: aiFilmRepository,
      filmRepository: filmRepository,
    );
  });

  test('без режима «только новое» не читает сохранённую библиотеку', () async {
    when(() => aiFilmRepository.getRecommendations('комедия', false, const [], const []))
        .thenAnswer((_) async => <AiFilmRecommendation>[]);

    final result = await useCase('комедия', false);

    expect(result, isEmpty);
    verifyNever(() => filmRepository.getSavedIdsAndTitles());
  });

  test('в режиме «только новое» передаёт id и названия сохранённых фильмов',
      () async {
    when(() => filmRepository.getSavedIdsAndTitles()).thenAnswer(
      (_) async => (
        <int>[526, 107],
        <String?>["Ocean's Eleven", null],
      ),
    );
    when(() => aiFilmRepository.getRecommendations(
          'ограбление',
          true,
          const [526, 107],
          const ["Ocean's Eleven", null],
        )).thenAnswer((_) async => <AiFilmRecommendation>[]);

    await useCase('ограбление', true);

    verify(
      () => aiFilmRepository.getRecommendations(
        'ограбление',
        true,
        const [526, 107],
        const ["Ocean's Eleven", null],
      ),
    ).called(1);
  });

  test('пустая библиотека не мешает запросу в режиме «только новое»',
      () async {
    when(() => filmRepository.getSavedIdsAndTitles())
        .thenAnswer((_) async => (<int>[], <String?>[]));
    when(() => aiFilmRepository.getRecommendations('q', true, const [], const []))
        .thenAnswer((_) async => <AiFilmRecommendation>[]);

    final result = await useCase('q', true);

    expect(result, isEmpty);
    verify(() => filmRepository.getSavedIdsAndTitles()).called(1);
  });
}
