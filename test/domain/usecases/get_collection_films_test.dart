import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/api/dio_api_client.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/user_repository.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_collections_films_use_case.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockFilmRepository extends Mock implements FilmRepository {}

class MockDioApiClient extends Mock implements DioApiClient {}

void main() {
  late MockUserRepository userRepository;
  late MockFilmRepository filmRepository;
  late MockDioApiClient apiClient;
  late GetCollectionsFilmsUseCase useCase;

  setUp(() {
    userRepository = MockUserRepository();
    filmRepository = MockFilmRepository();
    apiClient = MockDioApiClient();
    useCase = GetCollectionsFilmsUseCase(
      userRepository: userRepository,
      filmRepository: filmRepository,
      apiClient: apiClient,
    );
  });

  const collectionNames = ['TOP_POPULAR_MOVIES', 'POPULAR_SERIES'];
  const filmA = FilmEntity(kinopoiskId: 1, nameRu: 'Film A');
  const filmB = FilmEntity(kinopoiskId: 2, nameRu: 'Film B');

  test('returns a map keyed by collection name with the films for each collection', () async {
    when(() => filmRepository.getCollectionFilms('TOP_POPULAR_MOVIES', 1))
        .thenAnswer((_) async => [filmA]);
    when(() => filmRepository.getCollectionFilms('POPULAR_SERIES', 1))
        .thenAnswer((_) async => [filmB]);

    final result = await useCase.call(collectionNames);

    expect(result, isNotNull);
    expect(result!['TOP_POPULAR_MOVIES'], [filmA]);
    expect(result['POPULAR_SERIES'], [filmB]);
    verify(() => filmRepository.getCollectionFilms('TOP_POPULAR_MOVIES', 1)).called(1);
    verify(() => filmRepository.getCollectionFilms('POPULAR_SERIES', 1)).called(1);
  });

  test('preserves a null entry for a collection that returned no films', () async {
    when(() => filmRepository.getCollectionFilms('TOP_POPULAR_MOVIES', 1))
        .thenAnswer((_) async => null);
    when(() => filmRepository.getCollectionFilms('POPULAR_SERIES', 1))
        .thenAnswer((_) async => [filmB]);

    final result = await useCase.call(collectionNames);

    expect(result!['TOP_POPULAR_MOVIES'], isNull);
    expect(result['POPULAR_SERIES'], [filmB]);
  });

  test('rethrows RemoteDataSourceException raised by the repository', () async {
    when(() => filmRepository.getCollectionFilms(any(), any()))
        .thenThrow(NetworkFailure());

    expect(
      () => useCase.call(collectionNames),
      throwsA(isA<RemoteDataSourceException>()),
    );
  });

  test('rethrows LocalDataSourceException raised by the repository', () async {
    when(() => filmRepository.getCollectionFilms(any(), any()))
        .thenThrow(LocalDataSourceException(message: 'local error'));

    expect(
      () => useCase.call(collectionNames),
      throwsA(isA<LocalDataSourceException>()),
    );
  });

  test('calls the repository once per requested collection name', () async {
    when(() => filmRepository.getCollectionFilms(any(), any()))
        .thenAnswer((_) async => []);

    await useCase.call(collectionNames);

    verify(() => filmRepository.getCollectionFilms(any(), any())).called(collectionNames.length);
  });
}