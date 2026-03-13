import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/film_collection_names.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_collections_films_use_case.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/search_films_bloc.dart';

class MockDisplayFilmCollectionsUseCase extends Mock implements GetCollectionsFilmsUseCase {}

FilmEntity _buildFilmCardEntity({
  int? kinopoiskId = 0,
  String? nameRu = "Фильм №1",
  String? nameEn = "Film №1",
  String? nameOriginal = "Film №1",
  num? ratingKinopoisk = 7.9
}) => FilmEntity(
  kinopoiskId: kinopoiskId,
  nameRu: nameRu,
  nameEn: nameEn,
  nameOriginal: nameOriginal,
  ratingKinopoisk: ratingKinopoisk
);

void main(){
  group("SearchFilmsBloc", () {

    final Map<String, List<FilmEntity>?> testfilmCardEntityList = {
      FilmCollectionNames.topPopularMovies: List.filled(2, _buildFilmCardEntity()),
      FilmCollectionNames.popularSeries: List.filled(2, _buildFilmCardEntity()),
      FilmCollectionNames.top250movies: List.filled(2, _buildFilmCardEntity()),
      FilmCollectionNames.top250tvShows: List.filled(2, _buildFilmCardEntity())
    };

    final mockDisplayFilmCollectionsUseCase = MockDisplayFilmCollectionsUseCase();

    setUp(() {
      reset(mockDisplayFilmCollectionsUseCase);
    });

    blocTest<SearchFilmsBloc, SearchFilmsState>(
      "emit CollectionsFilmsLoadedSuccesful when DisplayFilmCollectionsUseCase returns Map<String, List<FilmCardEntity>?>?",
      setUp: () {
        when(() => mockDisplayFilmCollectionsUseCase.call(FilmCollectionNames.filmCollectionNames)).thenAnswer((_) async => testfilmCardEntityList);
      },
      build: () => SearchFilmsBloc(displayFilmCollectionsUseCase: mockDisplayFilmCollectionsUseCase),
      act: (bloc) => bloc.add(DisplayFilmCollectionsEvent()),
      expect: () => <SearchFilmsState>[
        SearchFilmsLoading(),
        CollectionsFilmsLoadedSuccessful(filmCollectionsMap: testfilmCardEntityList)
      ],
      verify: (_) {
        verify(() => mockDisplayFilmCollectionsUseCase.call(FilmCollectionNames.filmCollectionNames)).called(1);
      }  
    );

    blocTest<SearchFilmsBloc, SearchFilmsState>(
      "emit CollectionsFilmsLoadedFailure when DisplayFilmCollectionsUseCase returns NULL",
      setUp: () {
        when(() => mockDisplayFilmCollectionsUseCase.call(FilmCollectionNames.filmCollectionNames)).thenAnswer((_) async => null);
      },
      build: () => SearchFilmsBloc(displayFilmCollectionsUseCase: mockDisplayFilmCollectionsUseCase),
      act: (bloc) => bloc.add(DisplayFilmCollectionsEvent()),
      expect: () => [
        SearchFilmsLoading(),
        isA<CollectionsFilmsLoadedFailure>()
      ],
      verify: (_) {
        verify(() => mockDisplayFilmCollectionsUseCase.call(FilmCollectionNames.filmCollectionNames)).called(1);
      } 
    );

    blocTest<SearchFilmsBloc, SearchFilmsState>(
      "emit CollectionsFilmsLoadedFailure when DisplayFilmCollectionsUseCase rethrow RemoteDataSourceException",
      setUp: () {
        when(() => mockDisplayFilmCollectionsUseCase.call(FilmCollectionNames.filmCollectionNames)).thenThrow(RemoteDataSourceException(
          DioExceptionType.values.first,
          HttpStatus.badRequest
        ));
      },
      build: () => SearchFilmsBloc(displayFilmCollectionsUseCase: mockDisplayFilmCollectionsUseCase),
      act: (bloc) => bloc.add(DisplayFilmCollectionsEvent()),
      expect: () => [
        SearchFilmsLoading(),
        isA<CollectionsFilmsLoadedFailure>()
      ],
      verify: (_) {
        verify(() => mockDisplayFilmCollectionsUseCase.call(FilmCollectionNames.filmCollectionNames)).called(1);
      } 
    );

    blocTest<SearchFilmsBloc, SearchFilmsState>(
      "emit CollectionsFilmsLoadedFailure when DisplayFilmCollectionsUseCase rethrow Exception",
      setUp: () {
        when(() => mockDisplayFilmCollectionsUseCase.call(FilmCollectionNames.filmCollectionNames)).thenThrow(Exception());
      },
      build: () => SearchFilmsBloc(displayFilmCollectionsUseCase: mockDisplayFilmCollectionsUseCase),
      act: (bloc) => bloc.add(DisplayFilmCollectionsEvent()),
      expect: () => [
        SearchFilmsLoading(),
        isA<CollectionsFilmsLoadedFailure>()
      ],
      verify: (_) {
        verify(() => mockDisplayFilmCollectionsUseCase.call(FilmCollectionNames.filmCollectionNames)).called(1);
      } 
    );

  });
}