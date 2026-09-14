import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_collections_films_use_case.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/search_films_bloc.dart';

class MockGetCollectionsFilmsUseCase extends Mock implements GetCollectionsFilmsUseCase {}

void main() {
  late MockGetCollectionsFilmsUseCase useCase;

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    useCase = MockGetCollectionsFilmsUseCase();
  });

  SearchFilmsBloc buildBloc() => SearchFilmsBloc(displayFilmCollectionsUseCase: useCase);

  const film = FilmEntity(kinopoiskId: 1, nameRu: 'Interstellar');
  final filmMap = {
    'TOP_POPULAR_MOVIES': [film],
  };

  test('initial state is SearchFilmsInitial', () {
    expect(buildBloc().state, isA<SearchFilmsInitial>());
  });

  blocTest<SearchFilmsBloc, SearchFilmsState>(
    'emits [Loading, Success] when the use case returns a non-null map',
    build: () {
      when(() => useCase.call(any())).thenAnswer((_) async => filmMap);
      return buildBloc();
    },
    act: (bloc) => bloc.add(DisplayFilmCollections()),
    expect: () => [
      isA<SearchFilmsLoading>(),
      isA<CollectionsFilmsLoadedSuccessful>()
          .having((s) => s.filmCollectionsMap, 'filmCollectionsMap', filmMap),
    ],
  );

  blocTest<SearchFilmsBloc, SearchFilmsState>(
    'emits [Loading, Failure] with an empty-collection message when the use case returns null',
    build: () {
      when(() => useCase.call(any())).thenAnswer((_) async => null);
      return buildBloc();
    },
    act: (bloc) => bloc.add(DisplayFilmCollections()),
    expect: () => [
      isA<SearchFilmsLoading>(),
      isA<CollectionsFilmsLoadedFailure>()
          .having((s) => s.message, 'message', 'Коллекция фильмов пуста'),
    ],
  );

  blocTest<SearchFilmsBloc, SearchFilmsState>(
    'emits [Loading, Failure] with the remote exception message on RemoteDataSourceException',
    build: () {
      when(() => useCase.call(any())).thenThrow(NetworkFailure());
      return buildBloc();
    },
    act: (bloc) => bloc.add(DisplayFilmCollections()),
    expect: () => [
      isA<SearchFilmsLoading>(),
      isA<CollectionsFilmsLoadedFailure>()
          .having((s) => s.message, 'message', NetworkFailure().message),
    ],
  );

  blocTest<SearchFilmsBloc, SearchFilmsState>(
    'emits [Loading, Failure] with the local exception message on LocalDataSourceException',
    build: () {
      when(() => useCase.call(any()))
          .thenThrow(LocalDataSourceException(message: 'disk error'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(DisplayFilmCollections()),
    expect: () => [
      isA<SearchFilmsLoading>(),
      isA<CollectionsFilmsLoadedFailure>()
          .having((s) => s.message, 'message', 'disk error'),
    ],
  );

  blocTest<SearchFilmsBloc, SearchFilmsState>(
    'emits [Loading, Failure] with a generic message for any other error',
    build: () {
      when(() => useCase.call(any())).thenThrow(Exception('boom'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(DisplayFilmCollections()),
    expect: () => [
      isA<SearchFilmsLoading>(),
      isA<CollectionsFilmsLoadedFailure>()
          .having((s) => s.message, 'message', 'Неизвестная ошибка'),
    ],
  );
}