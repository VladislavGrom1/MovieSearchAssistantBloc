import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/search_collection_films_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/search_films_by_keyword_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/search_filter_films_use_case.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/searched_films/searched_films_bloc.dart';

class MockSearchFilterFilmsUseCase extends Mock
    implements SearchFilterFilmsUseCase {}

class MockSearchFilmsByKeywordUseCase extends Mock
    implements SearchFilmsByKeywordUseCase {}

class MockSearchCollectionFilmsUseCase extends Mock
    implements SearchCollectionFilmsUseCase {}

void main() {
  const film = FilmEntity(kinopoiskId: 301, nameOriginal: 'The Matrix');

  late MockSearchFilterFilmsUseCase filterUseCase;
  late MockSearchFilmsByKeywordUseCase keywordUseCase;
  late MockSearchCollectionFilmsUseCase collectionUseCase;

  setUp(() {
    filterUseCase = MockSearchFilterFilmsUseCase();
    keywordUseCase = MockSearchFilmsByKeywordUseCase();
    collectionUseCase = MockSearchCollectionFilmsUseCase();
  });

  SearchedFilmsBloc buildBloc() => SearchedFilmsBloc(
        searchFilterFilmsUseCase: filterUseCase,
        searchFilmsByKeywordUseCase: keywordUseCase,
        searchCollectionFilmsUseCase: collectionUseCase,
      );

  blocTest<SearchedFilmsBloc, SearchedFilmsState>(
    'фильтры не выбраны — идём в фильтры v2.2 без параметров, а не в поиск '
    'по ключевому слову с пустой строкой',
    build: () {
      when(() => filterUseCase.call(null, null, null, null, null, 1))
          .thenAnswer((_) async => [film]);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadSearchedFilms()),
    expect: () => [
      isA<SearchedFilmsLoading>(),
      isA<SearchedFilmsLoadedSuccessful>()
          .having((s) => s.searchedFilms, 'searchedFilms', [film]),
    ],
    verify: (_) {
      verify(() => filterUseCase.call(null, null, null, null, null, 1))
          .called(1);
      verifyNever(() => keywordUseCase.call(any(), any()));
    },
  );

  blocTest<SearchedFilmsBloc, SearchedFilmsState>(
    'ключевое слово без фильтров — идём в поиск по ключевому слову',
    build: () {
      when(() => keywordUseCase.call('matrix', 1))
          .thenAnswer((_) async => [film]);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadSearchedFilms(keyword: 'matrix')),
    expect: () => [
      isA<SearchedFilmsLoading>(),
      isA<SearchedFilmsLoadedSuccessful>(),
    ],
    verify: (_) {
      verify(() => keywordUseCase.call('matrix', 1)).called(1);
      verifyNever(() => filterUseCase.call(any(), any(), any(), any(), any(), any()));
    },
  );

  blocTest<SearchedFilmsBloc, SearchedFilmsState>(
    'v2.1 упал — то же слово ищется через v2.2, экран без пустоты',
    build: () {
      when(() => keywordUseCase.call('паук', 1)).thenThrow(ServerFailure());
      when(() => filterUseCase.call('паук', null, null, null, null, 1))
          .thenAnswer((_) async => [film]);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadSearchedFilms(keyword: 'паук')),
    expect: () => [
      isA<SearchedFilmsLoading>(),
      isA<SearchedFilmsLoadedSuccessful>()
          .having((s) => s.searchedFilms, 'searchedFilms', [film]),
    ],
    verify: (_) {
      verify(() => keywordUseCase.call('паук', 1)).called(1);
      verify(() => filterUseCase.call('паук', null, null, null, null, 1))
          .called(1);
    },
  );

  blocTest<SearchedFilmsBloc, SearchedFilmsState>(
    'v2.1 вернул пустой список — резервный v2.2 всё равно даёт фильмы',
    build: () {
      when(() => keywordUseCase.call('zzz', 1)).thenAnswer((_) async => []);
      when(() => filterUseCase.call('zzz', null, null, null, null, 1))
          .thenAnswer((_) async => [film]);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadSearchedFilms(keyword: 'zzz')),
    expect: () => [
      isA<SearchedFilmsLoading>(),
      isA<SearchedFilmsLoadedSuccessful>()
          .having((s) => s.searchedFilms, 'searchedFilms', [film]),
    ],
    verify: (_) {
      verify(() => keywordUseCase.call('zzz', 1)).called(1);
      verify(() => filterUseCase.call('zzz', null, null, null, null, 1))
          .called(1);
    },
  );

  blocTest<SearchedFilmsBloc, SearchedFilmsState>(
    'пробельное ключевое слово не считается поиском и не даёт пустой films',
    build: () {
      when(() => filterUseCase.call(null, null, null, null, null, 1))
          .thenAnswer((_) async => [film]);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadSearchedFilms(keyword: '   ')),
    expect: () => [
      isA<SearchedFilmsLoading>(),
      isA<SearchedFilmsLoadedSuccessful>(),
    ],
    verify: (_) {
      verify(() => filterUseCase.call(null, null, null, null, null, 1))
          .called(1);
      verifyNever(() => keywordUseCase.call(any(), any()));
    },
  );

  blocTest<SearchedFilmsBloc, SearchedFilmsState>(
    'выбран один фильтр — в v2.2 уходит только он, keyword остаётся null',
    build: () {
      when(() => filterUseCase.call(null, [2], null, null, null, 1))
          .thenAnswer((_) async => [film]);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadSearchedFilms(countries: [2])),
    expect: () => [
      isA<SearchedFilmsLoading>(),
      isA<SearchedFilmsLoadedSuccessful>(),
    ],
    verify: (_) {
      verify(() => filterUseCase.call(null, [2], null, null, null, 1))
          .called(1);
      verifyNever(() => keywordUseCase.call(any(), any()));
    },
  );

  blocTest<SearchedFilmsBloc, SearchedFilmsState>(
    'пустой список стран не считается фильтром',
    build: () {
      when(() => filterUseCase.call(null, null, null, null, null, 1))
          .thenAnswer((_) async => [film]);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadSearchedFilms(countries: [])),
    expect: () => [
      isA<SearchedFilmsLoading>(),
      isA<SearchedFilmsLoadedSuccessful>(),
    ],
    verify: (_) {
      verify(() => filterUseCase.call(null, null, null, null, null, 1))
          .called(1);
    },
  );

  blocTest<SearchedFilmsBloc, SearchedFilmsState>(
    'ключевое слово вместе с фильтрами — v2.2 поддерживает оба параметра',
    build: () {
      when(() => filterUseCase.call('matrix', null, null, 1999, null, 1))
          .thenAnswer((_) async => [film]);
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      const LoadSearchedFilms(keyword: 'matrix', yearFrom: 1999),
    ),
    expect: () => [
      isA<SearchedFilmsLoading>(),
      isA<SearchedFilmsLoadedSuccessful>(),
    ],
    verify: (_) {
      verify(() => filterUseCase.call('matrix', null, null, 1999, null, 1))
          .called(1);
      verifyNever(() => keywordUseCase.call(any(), any()));
    },
  );
}
